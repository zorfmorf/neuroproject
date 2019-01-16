figure(1)
hold on
for i = 1:48
    subplot(7,10,i)
    imshow(imagestack(:,:,49000+i));
end