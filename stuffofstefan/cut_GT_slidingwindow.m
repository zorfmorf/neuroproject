clear all, clc;

%% Settings
% Recommendation: Only import images with high density of spots, especially
% if the output-dimension of the images is choosen quite small

% dimension of input-images
DIM = 512;

% which categories of GT shall be used to generate GT?
% For further information about existing categories, see CATEGORIES.txt
% in folder 'stuffofstefan'.
% CATEGORY is NOT SNR !!!
cat = [4 7 10];

% select image path and files of images. Preferably in .tif-format,
% otherwiese just change code
path_im = 'GTRUTH/all/images/';

% select data path. Data has to be provided as cell array containing
% in each cell the 3D-coordinates of all spots of one frame
path_gt = 'GTRUTH/all/raw_data';

% +++ IMPORTANT +++ 
% choose here the kind of GT wished and its labeling. Following kinds of GT
% can be provided:
%   1. Images without any spots
%   2. Images with exactly one spot in space
%   3. Images with exactly two spots in space
%   4. Images with one spot in center and anything around it
%   5. Images without spots in the center region, but anything around it
%   6. Images with exactly one spot at an edge
%   7. Images with exactly two spots, one at an edge and one in space
% Please type the numbers of the desired kinds of GT in the following
% vector:
GT_kinds = [1 2 3];
% In the same order as the kinds of GT in GT_kinds, type the desired labels
% of each kind of GT in the following vector:
GT_labels = [0 1 2];

% How many pictures (at least) for each label? (actual number may differ)
N_im = 1000;

% Number of template-image to import for each category
% Not so important. Only if you need LOTS of GT-data, choose some more
% images, as from each image several random cut-outs are generated. Maybe
% at least 1/500 of N_im, maximum 20.
number_images = 10;

% dimension of output-images
dim = 16;

% Set z-settings
% To be able to use the z-selectio-mechanism, you need to import images
% from only the correct heigth, named z. This is done automatically.
% z_lim determines the range around z (z +- z_lim), in which spots are
% taken as true, as existing. Outside of this range, spots are ignored, as
% they may be to far out of focus.
% Exception: For images without any spots, all spots from all heigths are
% taken into account, so not even a vanished spot is in the images.
z = 6;
z_lim = 1;

% choose name of GT-stack
% This will only set the name of the folder, if a specific name for the
% output in form of an .mat-file is desired, this has to be changed at the
% end of the code where results are saved.
name = '012_simple_snr247_z1/test_set';



%% Initialization----------------------------------------------------------

if length(GT_kinds) ~= length(GT_labels)
    error("The number of kinds of GT and the number of given labels do not fit, please check your settings for GT and labels!");
end

for i = 1:length(cat)
    catvec{i} = strcat('cat',num2str(cat(i)));
end

% initialize datastack for images
datastack_im = zeros(DIM,DIM, number_images, length(cat));

% import images
for j = 1:length(cat)
    fpath = strcat(path_im,catvec{j});
    files = dir(fullfile(fpath,strcat('*z0',num2str(z-1),'.tif')));
    for k = 1:number_images
        F = fullfile(fpath,files(k).name);
        datastack_im(:,:,k,j) = imread(F);
    end
end

% load label data (coordinates of spots in each label)
for j = 1:length(cat)
    load(strcat(path_gt,'/gtruth_',catvec{j},'.mat'));
end

% NEW VERSION, selects a fixed number of images for each LABEL
[nb_labels, which_labels] = hist(GT_labels, unique(GT_labels));
%     Says, how many different labels there are and which labels
n_perim = ceil((N_im/(length(cat)*number_images))./nb_labels);
%     Says, how many images have to be generated out of one templage-image
N = n_perim*number_images*length(cat)*nb_labels';
%     Is needed to initialize datastores
for i = 1:length(nb_labels)
    N_IM(GT_labels==which_labels(i)) = n_perim(i);
%         Vector, which contains for each kind of GT the number of images
%         to be generated out of one template-image
end



% handle number of cut-outs (per category, per image, in total)
% n_percat = ceil(N_im/length(cat));
% n_perim = ceil(n_percat/number_images);
% N = n_perim*number_images*length(cat);

% path for GT (create if necessary)
mkdir('GTRUTH\sliding_window',name);
path_cutGT = strcat('GTRUTH\sliding_window\',name);

% initialization
imagestack = uint8(zeros(dim, dim, 1, N));
labelstack = zeros(N,1);

% stack-counter
stack_cnt = 1;
gt_cnt = 1;

% VERY INCONVENIENT, HAS TO BE CHANGED ASAP!!!
if length(cat) == 2
    GT{1} = gtruth_cat7;
    GT{2} = gtruth_cat10;
elseif length(cat) == 3
    GT{1} = gtruth_cat4;
    GT{2} = gtruth_cat7;
    GT{3} = gtruth_cat10;
else
    error("Your super cool initialization of GT is not working");
end

%% Generating GT-data

if any(GT_kinds == 1)
    % images without any spots -> works
    disp("Images without spots...");
    z_lim_0 = 10;
    for i = 1:length(cat)
        for j = 1:number_images
            k = 1;
            while k <= N_IM(gt_cnt)
                % get random x- and y-position
                x_low = round(unifrnd(0.5,DIM+0.49-dim));
                y_low = round(unifrnd(0.5,DIM+0.49-dim));
                % determine image-boundaries
                x_up = x_low+dim-1;
                y_up = y_low+dim-1;
                % check whether there are spots in actual boundaries
                trues_x = (GT{i}{j}(:,1)>x_low & GT{i}{j}(:,1)<x_up);
                trues_y = (GT{i}{j}(:,2)>y_low & GT{i}{j}(:,2)<y_up);
                trues_z = (GT{i}{j}(:,3)>z-z_lim_0 & GT{i}{j}(:,3)<z+z_lim_0);
                trues = trues_x & trues_y & trues_z;
                if any(trues) == false
                    imagestack(:,:,1,stack_cnt) = ...
                        uint8(datastack_im(y_low:y_up,x_low:x_up,j,i));
                    labelstack(stack_cnt) = GT_labels(gt_cnt);
                    stack_cnt = stack_cnt +1;
                    k = k+1;
                end
            end
        end
    end
    gt_cnt = gt_cnt+1;
end

if any(GT_kinds == 2)
    % images with exactly one spot in space -> works
    disp("Images with one spot in space...");
    for i = 1:length(cat)
        for j = 1:number_images
            k = 1;
            while k <= N_IM(gt_cnt)
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
                if sum(trues) == 1
                    imagestack(:,:,1,stack_cnt) = ...
                        uint8(datastack_im(y_low:y_up,x_low:x_up,j,i));
                    labelstack(stack_cnt) = GT_labels(gt_cnt);
                    stack_cnt = stack_cnt +1;
                    k = k+1;
                end
            end
        end
    end
    gt_cnt = gt_cnt+1;
end

if any(GT_kinds == 3)
    % images with exactly two spots -> works
    disp("Images with two spots in space...");
    for i = 1:length(cat)
        for j = 1:number_images
            k = 1;
            while k <= N_IM(gt_cnt) 
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
                trues_x = (GT{i}{j}(:,1)>x_low+2 & GT{i}{j}(:,1)<x_up-2);
                trues_y = (GT{i}{j}(:,2)>y_low+2 & GT{i}{j}(:,2)<y_up-2);
                trues_z = (GT{i}{j}(:,3)>z-z_lim & GT{i}{j}(:,3)<z+z_lim);
                trues = trues_x & trues_y & trues_z;
                if sum(trues) == 2
                    imagestack(:,:,1,stack_cnt) = ...
                        uint8(datastack_im(y_low:y_up,x_low:x_up,j,i));
                    labelstack(stack_cnt) = GT_labels(gt_cnt);
                    stack_cnt = stack_cnt +1;
                    k = k+1;
                end
            end
        end
    end
    gt_cnt = gt_cnt+1;
end

if any(GT_kinds == 4)
    % images with one spot exactly in center
    disp("Images with one spot exactly in center...");
    for i = 1:length(cat)
        for j = 1:number_images
            k = 1;
            while k <= N_IM(gt_cnt)
                % select spot from GT
                nb_spots = size(GT{i}{j},1);
                spot = randperm(nb_spots,1);
                % get x,y,z-coordinates of spot and image-cutout
                pos = round(GT{i}{j}(spot,:));
                x_low = pos(1)-(dim/2-1);
                y_low = pos(2)-(dim/2-1);
                x_up = x_low+dim-1;
                y_up = y_low+dim-1;
                if x_low<1 || y_low<1 || x_up>512 || y_up>512
                    continue;
                end
                imagestack(:,:,1,stack_cnt) = ...
                    uint8(datastack_im(y_low:y_up,x_low:x_up,j,i));
                labelstack(stack_cnt) = GT_labels(gt_cnt);
                stack_cnt = stack_cnt +1;
                k = k+1;
            end
        end
    end
    gt_cnt = gt_cnt+1;
end

if any(GT_kinds == 5)
    % images without spots in center -> works
    disp("Images without spots in center...");
    % define "radius" of inner area
    r = 2;
    for i = 1:length(cat)
        for j = 1:number_images
            k = 1;
            while k <= N_IM(gt_cnt)
                % get random x- and y-position
                x_low = round(unifrnd(0.5,DIM+0.49-dim));
                y_low = round(unifrnd(0.5,DIM+0.49-dim));
                % determine image-boundaries
                x_up = x_low+dim-1;
                y_up = y_low+dim-1;
                % check whether there are spots in actual boundaries
                trues_x = (GT{i}{j}(:,1)>x_low+(dim/2-1-r) & GT{i}{j}(:,1)<x_up-(dim/2-r));
                trues_y = (GT{i}{j}(:,2)>y_low+(dim/2-1-r) & GT{i}{j}(:,2)<y_up-(dim/2-r));
                trues_z = (GT{i}{j}(:,3)>z-z_lim & GT{i}{j}(:,3)<z+z_lim);
                trues = trues_x & trues_y & trues_z;
                if any(trues) == false
                    imagestack(:,:,1,stack_cnt) = ...
                        uint8(datastack_im(y_low:y_up,x_low:x_up,j,i));
                    labelstack(stack_cnt) = GT_labels(gt_cnt);
                    stack_cnt = stack_cnt +1;
                    k = k+1;
                end
            end
        end
    end
    gt_cnt = gt_cnt+1;
end

if any(GT_kinds == 6)
    % images with only one spot at the edge
    disp("Images with only one spot at the edge...");
    for i = 1:length(cat)
        for j = 1:number_images
            k = 1;
            while k <= N_IM(gt_cnt)
                % select spot from GT
                nb_spots = size(GT{i}{j},1);
                spot = randperm(nb_spots,1);
                % get x,y,z-coordinates of spot and image-cutout
                pos = round(GT{i}{j}(spot,:));
                x_low = pos(1);
                y_low = pos(2)-randperm(dim,1)-1;
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
                % introduce random rotation to have spots at all possible edges
                rot = randperm(4,1)-1;
                if sum(trues) == 1
                    imagestack(:,:,1,stack_cnt) = imrotate(uint8(...
                        datastack_im(y_low:y_up,x_low:x_up,j,i)),rot*90);
                    labelstack(stack_cnt) = GT_labels(gt_cnt);
                    stack_cnt = stack_cnt +1;
                    k = k+1;
                end
            end
        end
    end
    gt_cnt = gt_cnt+1;
end

if any(GT_kinds == 7)
    % images with one spot at the edge and second in space
    disp("Images with only one spot at the edge and second in space...");
    for i = 1:length(cat)
        for j = 1:number_images
            k = 1;
            while k <= N_IM(gt_cnt)
                % select spot from GT
                nb_spots = size(GT{i}{j},1);
                spot = randperm(nb_spots,1);
                % get x,y,z-coordinates of spot and image-cutout
                pos = round(GT{i}{j}(spot,:));
                x_low = pos(1);
                y_low = pos(2)-randperm(dim,1)-1;
                x_up = x_low+dim-1;
                y_up = y_low+dim-1;
                if x_low<1 || y_low<1 || x_up>512 || y_up>512
                    continue;
                end
                % check whether there are spots in actual boundaries
                trues_x = (GT{i}{j}(:,1)>x_low & GT{i}{j}(:,1)<x_up);
                trues_inner_x = (GT{i}{j}(:,1)>x_low+2 & GT{i}{j}(:,1)<x_up-2);
                trues_y = (GT{i}{j}(:,2)>y_low & GT{i}{j}(:,2)<y_up);
                trues_inner_y = (GT{i}{j}(:,2)>y_low+2 & GT{i}{j}(:,2)<y_up-2);
                trues_z = (GT{i}{j}(:,3)>z-z_lim & GT{i}{j}(:,3)<z+z_lim);
                trues = trues_x & trues_y & trues_z;
                trues_inner = trues_inner_x & trues_inner_y & trues_z;
                % introduce random rotation to have spots at all possible edges
                rot = randperm(4,1)-1;
                if sum(trues) == 2 && sum(trues_inner)==1
                    imagestack(:,:,1,stack_cnt) = imrotate(uint8(...
                        datastack_im(y_low:y_up,x_low:x_up,j,i)),rot*90);
                    labelstack(stack_cnt) = GT_labels(gt_cnt);
                    stack_cnt = stack_cnt +1;
                    k = k+1;
                end
            end
        end
    end
    gt_cnt = gt_cnt+1;
end

if length(GT_kinds) ~= gt_cnt-1
    warning("Somehow not all kinds of GT have been generated :/");
end
if stack_cnt-1 ~= N
    warning("Not all images have been generated, stack-counter did not arrive at the end of stack.");
end

%% Save generated data to file
save(strcat(path_cutGT,'/imagestack.mat'),'imagestack');
save(strcat(path_cutGT,'/labelstack.mat'),'labelstack');

