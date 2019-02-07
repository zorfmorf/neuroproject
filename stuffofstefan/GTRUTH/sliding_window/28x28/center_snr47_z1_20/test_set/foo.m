k = 580;
figure(1)
hold on
for i = k+1:k+9*18
    subplot(9,18,i-k)
    imshow(imagestack(:,:,1,i));
    title(num2str(i));
end
hold off