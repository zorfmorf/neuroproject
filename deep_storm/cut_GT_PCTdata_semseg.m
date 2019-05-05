%%
% This code takes from a very specific path a number of images and
% ground-truth with very specific names. From these, it cuts out pieces of 
% 32x32 px to generate smaller training-data. They are stored in cell-arrays. 
% At the end, the images are written to another specific folder.
%%
clear, close, clc

%
%   ADAPTED FOR DEEPSTORM
%

% Take the first ...
limit = 60;
offset = 0; % maximal offset: 10
% pictures of each category and from each create ...
N = 20000;
% small pictures (12*limit*N)
% Dimensions of big pictures:
dim_large = 512;
% Dimension of small pictures:
dim_small = 32;

imstack = zeros(32,32,N);
lbstack = zeros(32,32,N);
% stackCounter = 1;

path = 'gtruthDS\OnePointLabels\cat8\';
[lbstack(:,:,1:N/4), imstack(:,:,1:N/4)] = cutNothing(path, 50, 5000);
path = 'gtruthDS\OnePointLabels\cat11\';
[lbstack(:,:,N/4+1:N/2), imstack(:,:,N/4+1:N/2)] = cutNothing(path, 50, 5000);
path = 'gtruthDS\OnePointLabels\cat9\';
[lbstack(:,:,N/2+1:3*N/4), imstack(:,:,N/2+1:3*N/4)] = cutSomething(path, 50, 5000);
path = 'gtruthDS\OnePointLabels\cat12\';
[lbstack(:,:,3*N/4+1:N), imstack(:,:,3*N/4+1:N)] = cutSomething(path, 50, 5000);

imstack = uint8(imstack);
lbstack = uint8(lbstack);




function [labelstack,imagestack] = cutNothing(path, NumImages, NumPics)

PicsPerImage = ceil(NumPics/NumImages);

disp("loading images and labels...");
path_im = path + "image\";
path_lb = path + "label\";
files_im = dir(fullfile(path_im,'*.tif'));
files_lb = dir(fullfile(path_lb,'*.png'));
store_im = zeros(512,512,NumImages);
store_lb = zeros(512,512,NumImages);
for k = 1:NumImages
    Im = fullfile(path_im,files_im(k).name);
    store_im(:,:,k) = imread(Im);
end
for k = 1:NumImages
    Lb = fullfile(path_lb,files_lb(k).name);
    store_lb(:,:,k) = imread(Lb);
end

labelstack = zeros(32,32,NumPics);
imagestack = zeros(32, 32, NumPics);
stackCounter = 1;

disp("cut images...");
for i=1:NumImages

    k = 1;
    while k <= PicsPerImage % take N small pics out of image
        random_xpos = round(unifrnd(0.5, 512-32+0.49));
        random_ypos = round(unifrnd(0.5, 512-32+0.49));

        pic_label = store_lb(random_xpos:random_xpos+32-1,...
            random_ypos:random_ypos+32-1, i);

        if (sum(sum(pic_label)) == 0)

            pic_image = store_im(random_xpos:random_xpos+32-1,...
                random_ypos:random_ypos+32-1, i);
            labelstack(:,:,stackCounter) = pic_label;
%             figure(1)
%             hold on
%             subplot(1,2,1)
%             imshow(uint8(pic_label));
%             subplot(1,2,2)
%             imshow(uint8(pic_image));
%             hold off
            imagestack(:,:,stackCounter) = pic_image;
            k = k+1;
            stackCounter = stackCounter+1;
            if (stackCounter == NumPics+1) return; end
        end
    end
end

end

function [labelstack,imagestack] = cutSomething(path, NumImages, NumPics)

PicsPerImage = ceil(NumPics/NumImages);

disp("loading images and labels...");
path_im = path + "image\";
path_lb = path + "label\";
files_im = dir(fullfile(path_im,'*.tif'));
files_lb = dir(fullfile(path_lb,'*.png'));
store_im = zeros(512,512,NumImages);
store_lb = zeros(512,512,NumImages);
for k = 1:NumImages
    Im = fullfile(path_im,files_im(k).name);
    store_im(:,:,k) = imread(Im);
end
for k = 1:NumImages
    Lb = fullfile(path_lb,files_lb(k).name);
    store_lb(:,:,k) = imread(Lb);
end

labelstack = zeros(32,32,NumPics);
imagestack = zeros(32, 32, NumPics);
stackCounter = 1;

disp("cut images...");
for i=1:NumImages

    k = 1;
    while k <= PicsPerImage % take N small pics out of image
        random_xpos = round(unifrnd(0.5, 512-32+0.49));
        random_ypos = round(unifrnd(0.5, 512-32+0.49));

        pic_label = store_lb(random_xpos:random_xpos+32-1,...
            random_ypos:random_ypos+32-1, i);

        if (sum(sum(pic_label)) > 0)

            pic_image = store_im(random_xpos:random_xpos+32-1,...
                random_ypos:random_ypos+32-1, i);
%             figure(1)
%             hold on
%             subplot(1,2,1)
%             imshow(uint8(pic_label));
%             subplot(1,2,2)
%             imshow(uint8(pic_image));
%             hold off
            labelstack(:,:,stackCounter) = pic_label;
            imagestack(:,:,stackCounter) = pic_image;
            k = k+1;
            stackCounter = stackCounter+1;
            if (stackCounter == NumPics+1) return; end

        end
    end
end

end

        
