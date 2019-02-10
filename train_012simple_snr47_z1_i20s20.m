
% setup network to use
layers_sw_small = [
    imageInputLayer([16 16 1])
    convolution2dLayer(3, 32)
    reluLayer()
    maxPooling2dLayer(2,'Stride',1)
    convolution2dLayer(3, 64)
    reluLayer()
    maxPooling2dLayer(2, 'Stride',1)
    convolution2dLayer(3, 80)
    reluLayer()
    maxPooling2dLayer(2, 'Stride', 1)
    fullyConnectedLayer(128)
    reluLayer()
    dropoutLayer()
    fullyConnectedLayer(128)
    reluLayer()
    dropoutLayer()
    fullyConnectedLayer(3)
    softmaxLayer()
    pixelClassificationLayer()];

layers_sw = [
    imageInputLayer([28 28 1])
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
    fullyConnectedLayer(3)
    softmaxLayer()
    pixelClassificationLayer()];


opts = trainingOptions('adam', ...
    'Plots', 'training-progress',...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',50, ...
    'ExecutionEnvironment','parallel',...
    'MiniBatchSize',64);

 
name = "012simple_snr47_z1_i20s20";
prefix = "ScalInv";

disp("Training network " + name)
load(prefix + "/" + name + "/imagestack.mat");
X = imagestack;
load(prefix + "/" + name + "/labelstack.mat");
Y = labelstack;
net = trainNetwork(X, categorical(Y), layers_sw, opts);
save(prefix + "_" + name + ".net", "net");

