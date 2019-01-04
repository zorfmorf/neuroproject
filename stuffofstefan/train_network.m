% Load the training data.
close all
clc
clear all
%dataSetDir = fullfile(toolboxdir('vision'),'visiondata','triangleImages');
%dataSetDir = dir('/Users/zorfmorf/Projects/uni/neuroproject/semsegex/');
%imageDir = fullfile(dataSetDir,'trainingImages');
%labelDir = fullfile(dataSetDir,'trainingLabels');
imageDir = fullfile('GTRUTH/z05w20r10_cut/images');
labelDir = fullfile('GTRUTH/z05w20r10_cut/labels');

% Create an image datastore for the images.

imds = imageDatastore(imageDir);

% Create a pixelLabelDatastore for the ground truth pixel labels.

classNames = ["o","x"];
labelIDs   = [255 0];
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

% Reshape data for image-regression-network:

% path = 'GTRUTH/z05w20r10_cut/images';
% files = dir(fullfile(path,'*.tif'));
% imagestore = zeros(32,32,1,numel(files));
% for k = 1:numel(files)
%     F = fullfile(path,files(k).name);
%     I = imread(F);
%     imagestore(:,:,:,k) = I;
% end
% 
% path_ = 'GTRUTH/z05w20r10_cut/labels';
% files_ = dir(fullfile(path_,'*.png'));
% labelstore = zeros(32,32,1,numel(files_));
% for k = 1:numel(files)
%     G = fullfile(path_, files_(k).name);
%     J = imread(G);
%     labelstore(:,:,:,k) = J;
% end

% Create a semantic segmentation network. This network uses a simple semantic segmentation network based on a downsampling and upsampling design. 

numFilters = 64;
filterSize = 3;
numClasses = 2;
layers1 = [
    imageInputLayer([32 32 1])
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1)
    convolution2dLayer(1,numClasses);
    softmaxLayer()
    pixelClassificationLayer()
    ];

% scratch of deep-storm-network
upsample2x2Layer = transposedConv2dLayer(2,1,'Stride',2, 'WeightLearnRateFactor',0,'BiasLearnRateFactor',0);
upsample2x2Layer.Weights = ones(2,2,1,512);
upsample2x2Layer.Bias = 0;
layers_ds = [
    imageInputLayer([32 32 1])
    convolution2dLayer(filterSize, 32, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(filterSize, 64, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(filterSize, 128, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(filterSize, 512, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
    upsample2x2Layer
    convolution2dLayer(filterSize, 128, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
    upsample2x2Layer
    convolution2dLayer(filterSize, 64, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
    upsample2x2Layer
    convolution2dLayer(filterSize, 32, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
    fullyConnectedLayer(32)
    regressionLayer
    ];

% Layers of mathworks-question
layers = [
    imageInputLayer([32 32 1])
    convolution2dLayer(filterSize, 32, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
    maxPooling2dLayer(2,'Stride',2) %
    convolution2dLayer(filterSize, 64, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
    upsample2x2Layer                                   %
    convolution2dLayer(filterSize, 32, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
    fullyConnectedLayer(32)
    regressionLayer
    ];
    
% Layers of sliding-window-paper
layers_sw = [
    imageInputLayer([29 29 1])
    convolution2dLayer(9, 32)
    reluLayer()
    maxPooling2dLayer(2,'Stride',1)
    convolution2dLayer(7, 64)
    reluLayer()
    maxPooling2dLayer(2, 'Stride',1)
    convolution2dLayer(5, 80)
    reluLayer()
    maxPooling2dLayer(2, 'Stride', 1)
    fullyConnectedLayer(128)
    reluLayer()
    dropoutLayer()
    fullyConnectedLayer(128)
    reluLayer()
    dropoutLayer()
    fullyConnectedLayer(2)
    softmaxLayer()
    pixelClassificationLayer()];

analyzeNetwork(layers_ds);

% Setup training options.

opts = trainingOptions('adam', ...
    'Plots', 'training-progress',...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',100, ...
    'ExecutionEnvironment','parallel',...
    'MiniBatchSize',64);

% Create a pixel label image datastore that contains training data.

trainingData = pixelLabelImageDatastore(imds,pxds);

% Improve the results
% The network failed to segment the triangles and classified every pixel as "background".  
% The training appeared to be going well with training accuracies greater than 90%. However, 
% the network only learned to classify the background class. To understand why this happened, 
% you can count the occurrence of each pixel label across the dataset.

tbl = countEachLabel(trainingData);

% The majority of pixel labels are for the background. The poor results are due to the 
% class imbalance. Class imbalance biases the learning process in favor of the dominant class. 
% That's why every pixel is classified as "background". To fix this, use class weighting to
% balance the classes. There are several methods for computing class weights. One common 
% method is inverse frequency weighting where the class weights are the inverse of the class
% frequencies. This increases weight given to under-represented classes.
 
totalNumberOfPixels = sum(tbl.PixelCount);
frequency = tbl.PixelCount / totalNumberOfPixels;
classWeights = 1./frequency;

% Class weights can be specified using the pixelClassificationLayer. Update the 
% last layer to use a pixelClassificationLayer with inverse class weights.

layers1(end) = pixelClassificationLayer('Classes',tbl.Name,'ClassWeights',classWeights);

% Train network again.
disp("training neural network...");
net = trainNetwork(imagestore,labelstore,layers,opts);

% Try to segment the test image again.

testImage = imread('cat7_083.tif');
C = semanticseg(testImage,net);
B = labeloverlay(testImage,C);
imshow(B)

% Using class weighting to balance the classes produced a better segmentation result. 
% Additional steps to improve the results include increasing the number of epochs used
% for training, adding more training data, or modifying the network.