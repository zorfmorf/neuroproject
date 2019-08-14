k = 1525;
figure(1)
hold on
for i = k+1:k+10
    subplot(2,5,i-k)
    imshow(imagestack(:,:,1,i));
%     subplot(2,5,i-k+5)
%     imshow(labelstackDeepstormGaussian(:,:,1,i));
end
hold off