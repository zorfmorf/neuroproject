n = 6981;
figure(1)
subplot(1,3,1)
imshow(imagestack(:,:,:,n));
subplot(1,3,2)
imshow(deepstorm.predict(imagestack(:,:,:,n)));
subplot(1,3,3)
imshow(labelstack(:,:,:,n));
