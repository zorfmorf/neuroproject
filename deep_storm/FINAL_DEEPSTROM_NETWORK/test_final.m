%load("cat7_000z05.tif");
im = glu(:,1:32);%cat7_000z05;
%lb = load("z05w20r10_cat7_000_lb.png");
lb = z05w20r10_cat7_000_lb;

x = floor(rand(1) * 480);
y = floor(rand(1) * 480);

im_snippet = glu(:,1:32);%im(x:x+31, y:y+31);
lb_snippet = lb(x:x+31, y:y+31);
res_snippet = final_deepstorm.predict(im_snippet);
figure(1)
subplot(1,3,1)
imshow(im_snippet)
subplot(1,3,2)
imshow(res_snippet)
subplot(1,3,3)
imshow(lb_snippet)