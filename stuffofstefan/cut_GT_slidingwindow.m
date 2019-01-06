%function [image_stack, label_stack] = cut_GT_slidingwindow(

% Gegeben soll sein: Große GT Matrizen. Daraus sollen kleine passend herausgeschnitten
% werden. Benötigt werden folgende Kategorieen:
% 1. Einzelner Spot im Zentrum 
% 2. Einzelner Spot im Zwischenraum
% 3. Einzelner Spot am Rand (leicht abgeschnitten)
% 4. Zwei Spots irgendwo im Raum
% 5. Zwei Spots, einer davon am Rand abgeschnitten
% 6. Zwei Spots, beide am Rand abgeschnitten
% 7. Gar kein Spot

clear all, clc;
%% Input
% Recommendation: Only import images with high density of spots

% dimension of input-images and input gound-truth
DIM = 512;

% diameter of spots in ground-truth in pixels
D = 5;
% area of spots in pixels^2
switch D
    case 1 
        a = 1;
    case 3
        a = 5;
    case 5
        a = 13;
end

% which categories?
cat = [4, 7, 10];
for i = 1:length(cat)
    catvec{i} = strcat('cat',num2str(cat(i)));
end

% Number of image/gt-pairs to import for each category
number_images = 20;

% initialize images/gt-labels-datastacks
datastack_im = zeros(DIM,DIM, number_images, length(cat));
datastack_lb = zeros(DIM,DIM, number_images, length(cat));

% select image path and files of images
path = 'GTRUTH/all/images/';
for j = 1:length(cat)
    fpath = strcat(path,catvec{j});
    files = dir(fullfile(fpath,'*z05.tif'));
    for k = 1:number_images
        F = fullfile(fpath,files(k).name);
        datastack_im(:,:,k,j) = imread(F);
    end
end

% select ground-truth-path
path = 'GTRUTH/all/raw_data';
for j = 1:length(cat)
    % load label data (coordinates of spots in each label)
    load(strcat(path,'/gtruth_',catvec{j},'.mat'));
end
%% GT generation

% vector of kinds of GT to be created
% GT_kinds = [1,2,3,4,5,6,7];
% vector of labels of kinds of GT
% GT_labels = [1,1,1,2,2,2,0];
GT_kinds = ones(1,3);

% How many pictures (at least) from each kind
N = 10000;
% -> take N/categories pictures from each category
n_percat = ceil(N/length(cat));
% -> take n_percat/number_images from each image
n_perim = ceil(n_percat/number_images);
N = n_perim*number_images*length(cat);

% dimension of output-images
dim = 10;

z = 6;
% choose z-range
z_lim = 9;

% choose name of GT-stack
name = '012_simple';

% path for GT (make sure folder exists before running)
mkdir('GTRUTH\sliding_window',name);
path_cutGT = strcat('GTRUTH\sliding_window\',name);

% initialization
imagestack = uint8(zeros(dim, dim, N*length(GT_kinds)));
labelstack = zeros(N*length(GT_kinds),1);

%% Following part only determines number of spots in image from list

GT{1} = gtruth_cat4;
GT{2} = gtruth_cat7;
GT{3} = gtruth_cat10;

stack_cnt = 1;

% images without any spots -> works
disp("Images without spots...");
for i = 1:length(cat)
%     disp(num2str(i));
    for j = 1:number_images
%         disp(num2str(j));
        k = 1;
        while k <= n_perim
            % get random x- and y-position
            x_low = round(unifrnd(0.5,DIM+0.49-dim));
            y_low = round(unifrnd(0.5,DIM+0.49-dim));
            % determine image-boundaries
            x_up = x_low+dim-1;
            y_up = y_low+dim-1;
            % check whether there are spots in actual boundaries
            trues_x = (GT{i}{j}(:,1)>x_low & GT{i}{j}(:,1)<x_up);
            trues_y = (GT{i}{j}(:,2)>y_low & GT{i}{j}(:,2)<y_up);
            trues_z = (GT{i}{j}(:,3)>z-z_lim & GT{i}{j}(:,3)<z+z_lim);
            trues = trues_x & trues_y & trues_z;
            if any(trues) == false
%                 imwrite(uint8(datastack_im(y_low:y_up,x_low:x_up,j,i)),...
%                     strcat(path_cutGT,'/',num2str(i),'_',num2str(j),'_',num2str(k),...
%                     '_',num2str(x_low),'-',num2str(y_low),'.tif'));
                imagestack(:,:,stack_cnt) = ...
                    uint8(datastack_im(y_low:y_up,x_low:x_up,j,i));
                labelstack(stack_cnt) = 0;
                stack_cnt = stack_cnt +1;
                k = k+1;
            end
        end
    end
end

% images with exactly one spots -> works
disp("Images with one spot...");
% set z_lim another time, as there may be lots of spots to far away in
% depth to be seen, so pic is empty
z_lim = 3;
for i = 1:length(cat)
%     disp(num2str(i));
    for j = 1:number_images
%         disp(num2str(j));
        k = 1;
        while k <= n_perim
            % select spot from GT
            nb_spots = size(GT{i}{j},1);
            spot = randperm(nb_spots,1);
            % get x,y,z-coordinates of spot and image-cutout
            pos = round(GT{i}{j}(spot,:));
            x_low = pos(1)-randperm(dim-4,1)-1;
            y_low = pos(2)-randperm(dim-4,1)-1;
            x_up = x_low+dim-1;
            y_up = y_low+dim-1;
            if x_low<1 || y_low<1 || x_up>512 || y_up>512
                continue;
            end
%             z = pos(3);

            % check whether there are spots in actual boundaries
            trues_x = (GT{i}{j}(:,1)>x_low & GT{i}{j}(:,1)<x_up);
            trues_y = (GT{i}{j}(:,2)>y_low & GT{i}{j}(:,2)<y_up);
            trues_z = (GT{i}{j}(:,3)>z-z_lim & GT{i}{j}(:,3)<z+z_lim);
            trues = trues_x & trues_y & trues_z;
            if sum(trues) == 1
%                 imwrite(uint8(datastack_im(y_low:y_up,x_low:x_up,j,i)),...
%                     strcat(path_cutGT,'/',num2str(i),'_',num2str(j),'_',num2str(k),...
%                     '_',num2str(x_low),'-',num2str(y_low),'.tif'));
                imagestack(:,:,stack_cnt) = ...
                    uint8(datastack_im(y_low:y_up,x_low:x_up,j,i));
                labelstack(stack_cnt) = 1;
                stack_cnt = stack_cnt +1;
                k = k+1;
            end
        end
    end
end

% images with exactly two spots -> works
disp("Images with two spots...");
z_lim = 3;
for i = 1:length(cat)
%     disp(num2str(i));
    for j = 1:number_images
%         disp('-----');
%         disp(num2str(j));
        k = 1;
        while k <= n_perim 
            
%             disp(num2str(k));
            % select spot from GT
            nb_spots = size(GT{i}{j},1);
            spot = randperm(nb_spots,1);
            % get x,y,z-coordinates of spot and image-cutout
            pos = round(GT{i}{j}(spot,:));
            x_low = pos(1)-randperm(dim-4,1)-1;
            y_low = pos(2)-randperm(dim-4,1)-1;
            x_up = x_low+dim-1;
            y_up = y_low+dim-1;
            if x_low<1 || y_low<1 || x_up>512 || y_up>512
                continue;
            end

            % check whether there are spots in actual boundaries
            trues_x = (GT{i}{j}(:,1)>x_low & GT{i}{j}(:,1)<x_up);
            trues_y = (GT{i}{j}(:,2)>y_low & GT{i}{j}(:,2)<y_up);
            trues_z = (GT{i}{j}(:,3)>z-z_lim & GT{i}{j}(:,3)<z+z_lim);
            trues = trues_x & trues_y & trues_z;
            if sum(trues) == 2
%                 imwrite(uint8(datastack_im(y_low:y_up,x_low:x_up,j,i)),...
%                     strcat(path_cutGT,'/',num2str(i),'_',num2str(j),'_',num2str(k),...
%                     '_',num2str(x_low),'-',num2str(y_low),'.tif'));
                imagestack(:,:,stack_cnt) = ...
                    uint8(datastack_im(y_low:y_up,x_low:x_up,j,i));
                labelstack(stack_cnt) = 2;
                stack_cnt = stack_cnt +1;
                k = k+1;
            end
        end
    end
end

save(strcat(path_cutGT,'/imagestack.mat'),'imagestack');
save(strcat(path_cutGT,'/labelstack.mat'),'labelstack');

