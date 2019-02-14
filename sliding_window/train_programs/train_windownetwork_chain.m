% Basically what's in train_network, just chained so it can calculate all
% in one go

% list of all networks to train paths to train
path = "GTRUTH/sliding_window/";
prefix = "16x16";
names = [ 
         "center_snr47_z1_00", "center_snr47_z1_20", "center_snr47_z1_20_s30", "center_snr47_z3_00"
         %"012simple_snr47_z1_i20s20", "012simple_snr47_z1_s20"
        ];

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
    fullyConnectedLayer(2)
    softmaxLayer()
    pixelClassificationLayer()];

% Layers of sliding-window-paper
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
    'MaxEpochs',5, ...
    'ExecutionEnvironment','parallel',...
    'MiniBatchSize',64);

    
for id = 1:numel(names)
    name = names(id);
    disp("Now training network " + prefix + "_" + name)
    
    load("../GTRUTH/sliding_window/" + prefix + "/" + name + "/imagestack.mat");
    X = imagestack;
    load("../GTRUTH/sliding_window/" + prefix + "/" + name + "/labelstack.mat");
    Y = labelstack;
    
    net = trainNetwork(X, categorical(Y), layers_sw_small, opts);
    
    save(prefix + "_" + name, "net");
    disp("Finished training network " + prefix + "_" + name)
end

