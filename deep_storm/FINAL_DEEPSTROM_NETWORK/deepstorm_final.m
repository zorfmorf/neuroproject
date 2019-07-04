% create a local cluster object
pc = parcluster('local')

% explicitly set the JobStorageLocation to the temp directory that
% is unique to each cluster job (and is on local, fast scratch)
pc.JobStorageLocation = getenv('TMPDIR')

% please use (uncomment) this ONLY for bwUniCluster
% pc.JobStorageLocation = getenv('TMP')

% get the number of dedicated cores from environment
num_workers = str2num(getenv('MOAB_PROCCOUNT'))
pc.NumWorkers=num_workers;

% start the parallel pool 
parpool (pc, num_workers) 

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
load("imagestackDeepstormGaussian_UINT8.mat")
load("labelstackDeepstormGaussian_UINT8.mat")

opts = trainingOptions('adam', ...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',80, ...
    'MiniBatchSize',64);

net = trainNetwork(imagestackDeepstormGaussian,labelstackDeepstormGaussian,layers_ds,opts);

 
save("final_deepstorm.net", "net");

