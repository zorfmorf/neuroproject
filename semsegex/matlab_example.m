% Load the training data.
close all
clc
clear
%dataSetDir = fullfile(toolboxdir('vision'),'visiondata','triangleImages');
%dataSetDir = dir('/Users/zorfmorf/Projects/uni/neuroproject/semsegex/');
%imageDir = fullfile(dataSetDir,'trainingImages');
%labelDir = fullfile(dataSetDir,'trainingLabels');
imageDir = fullfile('/Users/zorfmorf/Projects/uni/neuroproject/semsegex/trainingImages');
labelDir = fullfile('/Users/zorfmorf/Projects/uni/neuroproject/semsegex/trainingLabels');

% Create an image datastore for the images.

imds = imageDatastore(imageDir);

% Create a pixelLabelDatastore for the ground truth pixel labels.

classNames = ["blop","background"];
labelIDs   = [255 0];
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

% Visualize training images and ground truth pixel labels.

I = read(imds);
C = read(pxds);

I = imresize(I,5);
L = imresize(uint8(C),5);
imshowpair(I,L,'montage')

% Create a semantic segmentation network. This network uses a simple semantic segmentation network based on a downsampling and upsampling design. 

numFilters = 64;
filterSize = 3;
numClasses = 2;
layers = [
    imageInputLayer([32 32 1])
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
    convolution2dLayer(1,numClasses);
    softmaxLayer()
    pixelClassificationLayer()
    ]

% Setup training options.

opts = trainingOptions('sgdm', ...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',100, ...
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