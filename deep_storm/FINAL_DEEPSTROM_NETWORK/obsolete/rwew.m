imagestackDeepstormGaussian = zeros(32,32,1,20000);
for i = 1:20000
    imagestackDeepstormGaussian(:,:,:,i) = imstack(:,:,i);
end