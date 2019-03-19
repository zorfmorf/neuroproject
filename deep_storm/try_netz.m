n = 6117;
bild = imagestack(:,:,:,n);
result = net.predict(bild);
figure(1)
subplot(1,2,1)
imshow(bild);
subplot(1,2,2)
imshow(result);