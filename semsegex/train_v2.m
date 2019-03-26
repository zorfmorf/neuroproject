close all
clc
clear all

disp("initializing...");

% create image data store and save to file
%%imds = imageDatastore('VIRUS_snr_7_density_mid')
%%save('virus_snr7_mid', 'imds')

% load imds (image data store)
load('trainingData_v2/virus_snr7_mid.mat');
c = xml2struct('trainingData_v2/virus_snr7_mid.xml');
counter = 1;
max = length(imds.Files);

% generate pixelLabelDataStore
disp("Creating pixel label data store");
while hasdata(imds)
    
    % read next image from datastore
    [data, info] = read(imds);
    [path,name,fileType] = fileparts(info.Filename);
    
    % extract time (t) and z layer (z) from image name
    [startIndex,endIndex] = regexp(name,'t\d\d\d');
    t = str2num(string(extractBetween(name,startIndex+1,endIndex)));
    [startIndex,endIndex] = regexp(name,'z\d\d');
    z = str2num(string(extractBetween(name,startIndex+1,endIndex)));

    gt_all = zeros(max,length(data),length(data));
    gt = zeros(length(data));
    
    % read xml data and find all matching points
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
                gt(floor(py + 1.5),floor(px + 1.5)) = 255;
            end
        end
    end
    
    % add gt to stack
    gt_all(counter,:,:) = gt;
    counter = counter + 1;
    if mod(counter, 10) == 0
        disp(num2str(counter/max * 100) + "%");
    end
end

% Create a pixelLabelDatastore for the ground truth pixel labels.

classNames = ["blop","background"];
labelIDs   = [255 0];
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

% Visualize training images and ground truth pixel labels.

%I = read(imds);
%C = read(pxds);
%
%I = imresize(I,5);
%L = imresize(uint8(C),5);
%imshowpair(I,L,'montage')

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
    ]

% Setup training options.

opts = trainingOptions('sgdm', ...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',1, ...
    'MiniBatchSize',64);

% Create a pixel label image datastore that contains training data.

trainingData = pixelLabelImageDatastore(imds,pxds);

% Train the network.

% disabled because this network doesn't work properly anyway
%net = trainNetwork(trainingData,layers,opts);

% Read and display a test image.

%imshow(testImage)

% Segment the test image and display the results.

%C = semanticseg(testImage,net);
%B = labeloverlay(testImage,C);
%imshow(B)

% Improve the results
% The network failed to segment the triangles and classified every pixel as "background".  
% The training appeared to be going well with training accuracies greater than 90%. However, 
% the network only learned to classify the background class. To understand why this happened, 
% you can count the occurrence of each pixel label across the dataset.

tbl = countEachLabel(trainingData)

% The majority of pixel labels are for the background. The poor results are due to the 
% class imbalance. Class imbalance biases the learning process in favor of the dominant class. 
% That's why every pixel is classified as "background". To fix this, use class weighting to
% balance the classes. There are several methods for computing class weights. One common 
% method is inverse frequency weighting where the class weights are the inverse of the class
% frequencies. This increases weight given to under-represented classes.
 
totalNumberOfPixels = sum(tbl.PixelCount);
frequency = tbl.PixelCount / totalNumberOfPixels;
classWeights = 1./frequency

% Class weights can be specified using the pixelClassificationLayer. Update the 
% last layer to use a pixelClassificationLayer with inverse class weights.

layers(end) = pixelClassificationLayer('Classes',tbl.Name,'ClassWeights',classWeights);

% Train network again.

net = trainNetwork(trainingData,layers,opts);

% Try to segment the test image again.

testImage = imread('bloptest.tif');
C = semanticseg(testImage,net);
B = labeloverlay(testImage,C);
imshow(B)

% Using class weighting to balance the classes produced a better segmentation result. 
% Additional steps to improve the results include increasing the number of epochs used
% for training, adding more training data, or modifying the network.