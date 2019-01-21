% Basically what's in train_network, just chained so it can calculate all
% in one go

% list of all networks to train paths to train
path = "GTRUTH/sliding_window/";
names = [ 
            "012_simple_snr47_z1" "012_simple_snr47_z3" "012_simple_snr47_z5"
            "012_simple_snr247_z1" "012_simple_snr247_z3" "012_simple_snr247_z5"
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
    fullyConnectedLayer(3)
    softmaxLayer()
    pixelClassificationLayer()];

opts = trainingOptions('adam', ...
    'Plots', 'training-progress',...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',100, ...
    'ExecutionEnvironment','parallel',...
    'MiniBatchSize',64);

    
for id = 1:numel(names)
    name = names(id);
    disp("Now training network " + name)
    
    load("GTRUTH/sliding_window/" + name + "/imagestack.mat");
    X = imagestack;
    load("GTRUTH/sliding_window/" + name + "/labelstack.mat");
    Y = labelstack;
    
    net = trainNetwork(X, categorical(Y), layers_sw_small, opts);
    
    save(name, "net");
end

