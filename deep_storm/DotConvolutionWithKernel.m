% Takes a labelstack, where single pixels mark spots and applies a
% convolution with a Kernel, s.t. for example a gaussian marks a spot

totalNumOfImages = 20000;
dimOfImages = 32;

GaussianKernel = [
    0.22, 0.47, 0.22;
    0.47, 1, 0.47;
    0.22, 0.47, 0.22
    ];

labelstackKernel = uint8(zeros(dimOfImages,dimOfImages,totalNumOfImages));

for i = 1:totalNumOfImages
    labelstackKernel(:,:,i) = uint8(conv2(labelstack(:,:,i),GaussianKernel,'same'));
end