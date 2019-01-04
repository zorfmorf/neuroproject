figure(1)
hold on
for i = 1:48
    subplot(6,8,i)
    imshow(imagestack(:,:,500+i));
end