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

analyzeNetwork(layers_sw)