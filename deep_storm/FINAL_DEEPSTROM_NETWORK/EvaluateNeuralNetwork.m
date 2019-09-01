function testNNetwork(net, imagestack, name)

dimensions = size(imagestack);
numIm = dimensions(4);
dimIm = dimensions(1);

resultImages = zeros(dimIm, dimIm, 1, numIm);

for i = 1:numIm
    resultImages(:,:,:,i) = net.predict(imagestack(:,:,:,i));
end

save(name, 'resultImages');

