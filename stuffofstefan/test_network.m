testImage = imread('GTRUTH/validation_data/images/w20r10_cat12_011_val.tif');
label = imread('GTRUTH/validation_data/labels/w20r10_cat12_011_val.png');

loesung1 = semanticseg(testImage,net1);
loesung2 = semanticseg(testImage,net2);
loesung3 = semanticseg(testImage,net3);
loesung4 = semanticseg(testImage,net4);
overlay1 = labeloverlay(testImage,loesung1);
overlay2 = labeloverlay(testImage,loesung2);
overlay3 = labeloverlay(testImage,loesung3);
overlay4 = labeloverlay(testImage,loesung4);


figure(3)
hold on
subplot(2,3,1)
imshow(testImage);
subplot(2,3,2)
imshow(label);
subplot(2,3,3);
imshow(overlay1);
subplot(2,3,4);
imshow(overlay2);
subplot(2,3,5);
imshow(overlay3);
subplot(2,3,6);
imshow(overlay4);
hold off
