k = 8280;
figure(1)
hold on
for i = k+1:k+5
    subplot(2,5,i-k)
    imshow(labelstack(:,:,1,i));
    subplot(2,5,i-k+5)
    imshow(resultImages(:,:,1,i));
end
hold off