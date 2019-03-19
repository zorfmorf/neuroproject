clear, clc
filterSize = 3;
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
    myUpsamplingLayer("Tick")
    convolution2dLayer(filterSize, 128, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
    myUpsamplingLayer("Trick")
    convolution2dLayer(filterSize, 64, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
    myUpsamplingLayer("Track")
    convolution2dLayer(filterSize, 32, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
%     fullyConnectedLayer(32)
    convolution2dLayer(1, 1)
    regressionLayer
];
% analyzeNetwork(layers_ds);
load("imagestack_trial.mat");
load("labelstack_trial.mat");

opts = trainingOptions('adam', ...
    'Plots', 'training-progress',...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',80, ...
    'ExecutionEnvironment','parallel',...
    'MiniBatchSize',64);

net = trainNetwork(imagestack,labelstack,layers_ds,opts);