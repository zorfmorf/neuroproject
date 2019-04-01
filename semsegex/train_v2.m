close all
clc
clear all

disp("initializing...");

% create image data store and save to file
imds = imageDatastore('trainingData_v2/images/');
%%save('virus_snr7_mid', 'imds')

% load imds (image data store)
% load('trainingData_v2/virus_snr7_mid_images.mat');

% generate pixelLabelDataStore
disp("Creating pixel label data store");

if true
    c = xml2struct('trainingData_v2/virus_snr7_mid.xml');
    max = length(imds.Files);
    gt_all = zeros(max,512,512);
    counter = 1;
    while hasdata(imds)
        % read next image from datastore
        [data, info] = read(imds);
        [path,name,fileType] = fileparts(info.Filename);

        % extract time (t) and z layer (z) from image name
        [startIndex,endIndex] = regexp(name,'t\d\d\d');
        t = str2num(string(extractBetween(name,startIndex+1,endIndex)));
        [startIndex,endIndex] = regexp(name,'z\d\d');
        z = str2num(string(extractBetween(name,startIndex+1,endIndex)));

        % read xml data and find a ll matching points
        len = size(c.root.TrackContestISBI2012.particle, 2);
        for ii=1:len
            part = c.root.TrackContestISBI2012.particle(ii);
            for jj=1:length(part{1}.detection)
                det = part{1}.detection(jj);
                px = str2double(det{1}.Attributes.x);
                py = str2double(det{1}.Attributes.y);
                pz = str2double(det{1}.Attributes.z);
                pt = str2num(det{1}.Attributes.t);
                if pt == t && abs(z - pz) < 3
                    % in image coordinates, x is column index
                    gt_all(counter,floor(py + 1.5),floor(px + 1.5)) = 255;
                end
            end
        end

        counter = counter + 1;
        if mod(counter, 10) == 0
            disp(num2str(counter/max * 100) + "%");
        end
    end

    for ii=1:1000
        img = zeros(512, 512, 1);
        img(:,:,1) = gt_all(ii,:,:);
        imwrite(img, "trainingData_v2/labels/" + ii + ".tif");
    end
    disp("Finished writing data to folder");
end

% Create a pixelLabelDatastore for the ground truth pixel labels.
classNames = ["blop","background"];
labelIDs   = [255 0];
pxds = pixelLabelDatastore("trainingData_v2/labels/",classNames,labelIDs);

% Create a semantic segmentation network. This network uses a simple semantic segmentation network based on a downsampling and upsampling design. 
numFilters = 64;
filterSize = 3;
numClasses = 2;
layers = [
        imageInputLayer([512 512 1])
        convolution2dLayer(filterSize,numFilters,'Padding',1)
        reluLayer()
        maxPooling2dLayer(2,'Stride',2)
        convolution2dLayer(filterSize,numFilters,'Padding',1)
        reluLayer()
        transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
        convolution2dLayer(1,numClasses);
        softmaxLayer()
        pixelClassificationLayer()
    ];

% Setup training options.

opts = trainingOptions('sgdm', ...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',5, ...
    'MiniBatchSize',64);

% Train the network.
trainingData = pixelLabelImageDatastore(imds,pxds);
tbl = countEachLabel(trainingData)
totalNumberOfPixels = sum(tbl.PixelCount);
frequency = tbl.PixelCount / totalNumberOfPixels;
classWeights = 1./frequency
layers(end) = pixelClassificationLayer('Classes',tbl.Name,'ClassWeights',classWeights);

net = trainNetwork(trainingData,layers,opts);
save("semantic_net.m", net);

% Try to segment the test image again.

testImage = imread('bloptest.tif');
C = semanticseg(testImage,net);
B = labeloverlay(testImage,C);
imshow(B)

% Using class weighting to balance the classes produced a better segmentation result. 
% Additional steps to improve the results include increasing the number of epochs used
% for training, adding more training data, or modifying the network.