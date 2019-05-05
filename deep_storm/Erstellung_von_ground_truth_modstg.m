function Erstellung_von_ground_truth()

imsize = 32;
BG = 10000;
sigma = 1;
nr_emitters = 5;
with_noise = true;

[x,y] = meshgrid(1:imsize,1:imsize);
psfFunc = @(x0,y0,A,sigma) A*exp(-(x-x0).^2/(2*sigma^2)-(y-y0).^2/(2*sigma^2));

% Emitters vary in position, brightness and standard deviation.
% em_pos = 5+rand(nr_emitters,2)*(imsize-5); Warum nur links 5 abstand?
em_pos = 1+rand(nr_emitters,2)*(imsize-1);
em_amp = 500+zeros(nr_emitters,1);%+rand(nr_emitters,1)*100;
em_sig = sigma + rand(nr_emitters,1)*0.5;

img = zeros(imsize) + BG;
lb = zeros(imsize);
for iEm = 1:nr_emitters
    img = img + psfFunc(em_pos(iEm,1) , em_pos(iEm,2), em_amp(iEm), em_sig(iEm));
    lb(round(em_pos(iEm,2)),round(em_pos(iEm,1))) = lb(round(em_pos(iEm,2)),round(em_pos(iEm,1))) +255;
end
% figure(2)
% imshow(img,[])
if(with_noise)
    img = poissrnd(img);
end

%gaussKernel3 = [

figure(1)
subplot(1,2,1)
imshow(img,[]);
subplot(1,2,2)
imshow(lb,[]);

img;
end