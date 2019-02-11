clear, clc, close all;

%% Settings
% Recommendation: Only import images with high density of spots, especially
% if the output-dimension of the images is choosen quite small

% dimension of input-images
DimInput = 512;

% which categories of GT shall be used to generate GT?
% For further information about existing categories, see CATEGORIES.txt
% in folder 'stuffofstefan'.
% CATEGORY is NOT SNR !!!
cat = [7 10];

% select image path and files of images. Preferably in .tif-format,
% otherwiese just change code
path_im = 'GTRUTH/all/images/';

% select data path. Data has to be provided as cell array containing
% in each cell the 3D-coordinates of all spots of one frame
path_gt = 'GTRUTH/all/raw_data';

% +++ IMPORTANT +++ 
% choose here the type of GT wished and its labeling. Following types of GT
% can be provided:
%   1. Images without any spots
%   2. Images with exactly one spot in space
%   3. Images with exactly two spots in space
%   4. Images with one/more spots in center and anything around it
%   5. Images without spots in the center region, but anything around it
%   6. Images with exactly one spot at an edge
%   7. Images with exactly two spots, one at an edge and one in space
% Please type the numbers of the desired types of GT in the following
% vector:
gtTypes = [1 4 5];
% In the same order as the types of GT in gtTypes, type the desired labels
% of each type of GT in the following vector:
GT_labels = [0 1 0];

% Further settings for types 4, 5:
% - Choose radius of the center-region (square of (2*r+1)^2):
    r = 2;
% - Choose number of rotations (1-4) of images with More spots:
%   (as there will be very few, it may be necessary to rotate them)
    rot = 3;
% - Choose ratio, how many training-pictures should have more than one
%   spot in center (! should not be too high, as there are only few)
%       - keep it at maximum 0.2 -
    ratioMore = 0.0;

% How many pictures (at least) for each label? (actual number may differ)
nPerLabel = 10000;

% Number of template-image to import for each category
% Not so important. Only if you need LOTS of GT-data, choose some more
% images, as from each image several random cut-outs are generated. Maybe
% at least 1/500 of nPerLabel, maximum 100.
numberModels = 50;

% dimension of output-images
DimOutput = 16;

% Set z-settings
% To be able to use the z-selection-mechanism, you need to import images
% from only the correct heigth, named z. This is done automatically.
% z_lim determines the range around z (z +- z_lim), in which spots are
% taken as true, as existing. Outside of this range, spots are ignored, as
% they may be to far out of focus.
% Exception: For images without any spots, all spots from all heigths are
% taken into account, so not even a vanished spot is in the images.
z = 6;
z_lim = 3;

% Inverting and Scaling
% Set the corresponding values to 1 if you want to invert or scale your
% images, respectively. Give also a ratio, how many images should be 
% inverted or scaled
inverting = 0;
ratioInverting = 0.2;
scaling = 0;
ratioScaling = 0.3;
% For scaling, choose furthermore the limits of a factor. This works as follows:
% If the factor is equal 0, nothing changes. If it is equal 1, the highest
% value in the image is scaled up to 255, all other values correspondingly
% such that ratios are conserved.
scalingFactor = [0.1, 0.8]; 
% For inverting, values are mirrored. 0 becomes 255, and vice versa.

% choose name of GT-stack
% This will only set the name of the folder, if a specific name for the
% output in form of an .mat-file is desired, this has to be changed at the
% end of the code where results are saved.
name = '16x16/center_snr47_z3_00';



%% Initialization----------------------------------------------------------

disp("Initialization...");
if length(gtTypes) ~= length(GT_labels)
    error("The number of types of GT and the number of given labels do not fit, please check your settings for GT and labels!");
end

for i = 1:length(cat)
    catvec{i} = strcat('cat',num2str(cat(i)));
end

% initialize datastack for images
datastack_im = zeros(DimInput,DimInput, numberModels, length(cat));

% import images
for j = 1:length(cat)
    fpath = strcat(path_im,catvec{j});
    files = dir(fullfile(fpath,strcat('*z0',num2str(z-1),'.tif')));
    for k = 1:numberModels
        F = fullfile(fpath,files(k).name);
        datastack_im(:,:,k,j) = imread(F);
    end
end

% load label data (coordinates of spots in each label)
for j = 1:length(cat)
    load(strcat(path_gt,'/gtruth_',catvec{j},'.mat'));
end

% NEW VERSION, selects a fixed number of images for each LABEL
which_labels = unique(GT_labels);
for i = 1:length(which_labels)
    nb_labels(i) = sum(GT_labels==which_labels(i));
end
%     Says, how many different labels there are and which labels
n_permod = ceil((nPerLabel/(length(cat)*numberModels))./nb_labels);
%     Says, how many images have to be generated out of one templage-image
N = n_permod*numberModels*length(cat)*nb_labels';
%     Is needed to initialize datastores
for i = 1:length(nb_labels)
    nPerModel(GT_labels==which_labels(i)) = n_permod(i);
%         Vector, which contains for each type of GT the number of images
%         to be generated out of one template-image
end
nPerCat = nPerModel*numberModels;
nPerType = nPerCat*length(cat);



% handle number of cut-outs (per category, per image, in total)
% n_percat = ceil(nPerLabel/length(cat));
% n_perim = ceil(n_percat/numberModels);
% N = n_perim*numberModels*length(cat);

% path for GT (create if necessary)
mkdir('GTRUTH\sliding_window',name);
path_cutGT = strcat('GTRUTH\sliding_window\',name);

% initialization
imagestack = uint8(zeros(DimOutput, DimOutput, 1, N));
labelstack = zeros(N,1);

% stack-counter
stack_cnt = 1;
gt_cnt = 1;

% VERY INCONVENIENT, HAS TO BE CHANGED!!!
if length(cat) == 2
    GT{1} = gtruth_cat7;
    GT{2} = gtruth_cat10;
elseif length(cat) == 3
    GT{1} = gtruth_cat4;
    GT{2} = gtruth_cat7;
    GT{3} = gtruth_cat10;
elseif length(cat) == 1
    GT{1} = gtruth_cat10;
else
    error("Your super cool initialization of GT is not working");
end

%% Generating GT-data -----------------------------------------------------

if any(gtTypes == 1)
    % images without any spots
    disp("Images without spots...");
    z_lim_0 = 10;
    for i = 1:length(cat)
        for j = 1:numberModels
            k = 1;
            while k <= nPerModel(gt_cnt)
                % get random x- and y-position
                x_low = round(unifrnd(0.5,DimInput+0.49-DimOutput));
                y_low = round(unifrnd(0.5,DimInput+0.49-DimOutput));
                % determine image-boundaries
                x_up = x_low+DimOutput-1;
                y_up = y_low+DimOutput-1;
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

if any(gtTypes == 2)
    % images with exactly one spot in space 
    disp("Images with one spot in space...");
    for i = 1:length(cat)
        for j = 1:numberModels
            k = 1;
            while k <= nPerModel(gt_cnt)
                % select spot from GT
                nb_spots = size(GT{i}{j},1);
                spot = randperm(nb_spots,1);
                % get x,y,z-coordinates of spot and image-cutout
                pos = round(GT{i}{j}(spot,:));
                x_low = pos(1)-randperm(DimOutput-4,1)-1;
                y_low = pos(2)-randperm(DimOutput-4,1)-1;
                x_up = x_low+DimOutput-1;
                y_up = y_low+DimOutput-1;
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

if any(gtTypes == 3)
    % images with exactly two spots
    disp("Images with two spots in space...");
    for i = 1:length(cat)
        for j = 1:numberModels
            k = 1;
            while k <= nPerModel(gt_cnt) 
                % select spot from GT
                nb_spots = size(GT{i}{j},1);
                spot = randperm(nb_spots,1);
                % get x,y,z-coordinates of spot and image-cutout
                pos = round(GT{i}{j}(spot,:));
                x_low = pos(1)-randperm(DimOutput-4,1)-1;
                y_low = pos(2)-randperm(DimOutput-4,1)-1;
                x_up = x_low+DimOutput-1;
                y_up = y_low+DimOutput-1;
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

if any(gtTypes == inf)
    % images with one spot exactly in center
    disp("Images with one spot exactly in center...");
    for i = 1:length(cat)
        for j = 1:numberModels
            k = 1;
            while k <= nPerModel(gt_cnt)
                % select spot from GT
                nb_spots = size(GT{i}{j},1);
                spot = randperm(nb_spots,1);
                % get x,y,z-coordinates of spot and image-cutout
                pos = round(GT{i}{j}(spot,:));
                if pos(3)>z+z_lim || pos(3)<z-z_lim
                    continue
                end
                x_low = pos(1)-(DimOutput/2-1);
                y_low = pos(2)-(DimOutput/2-1);
                x_up = x_low+DimOutput-1;
                y_up = y_low+DimOutput-1;
                if x_low<1 || y_low<1 || x_up>512 || y_up>512
                    continue;
                end
                % trues only care about center-window
                trues_x = (GT{i}{j}(:,1)>pos(1)-r-1 & GT{i}{j}(:,1)<pos(1)+r+1);
                trues_y = (GT{i}{j}(:,2)>pos(2)-r-1 & GT{i}{j}(:,2)<pos(2)+r+1);
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

if any(gtTypes == 4)
    % images with one/more than spots in center
    disp("Images with one/more ("+num2str(1-ratioMore)+"|"+num2str(ratioMore)+") spots in center...");
    
    % Find number of Ones, fitting to the number of cats and models
    nOneTmp = floor((1-ratioMore)*nPerType(gt_cnt));
    nOne = nOneTmp - mod(nOneTmp,length(cat)*numberModels);
    nOnePerCat = nOne/length(cat);
    nOnePerModel = nOnePerCat/numberModels;
   
    % Find number of Mores, being just the rest, fills up to nPerType
    nMore = nPerType(gt_cnt)-nOne;
    nMorePerCatTmp = nPerCat(gt_cnt)-nOnePerCat;
    nMorePerCat = nMorePerCatTmp*ones(1,length(cat));
    if sum(nMorePerCat) ~= nMore
        error("nMorePerCat");
    end

    for i = 1:length(cat)
        more_cnt = 0;   % Count number of Mores found
        image_cnt = 1;  % Count images
        J = randperm(numberModels); % Just give random indices to select images
        searchMore = 1; % Just setting to quit while loop 
        while searchMore == 1
            j = J(image_cnt);   % Choose random index 
%             disp("image "+num2str(image_cnt));
            spots = GT{i}{j}((GT{i}{j}(:,3)>z-z_lim & GT{i}{j}(:,3)<z+z_lim),:);
                % Reduce GT to valid spots after z-value
            nb_spots = length(spots);   % Give number of valid spots
            spots_rand = spots(randperm(nb_spots),:); % Shuffle spots
            spot_cnt = 1;   % Count which spot we are looking at
            for k = 1:nb_spots  % Go through all spots
                pos = round(spots_rand(spot_cnt,:));    % Take pos of first spot
                trues_x = (spots(:,1)>pos(1)-r-1 & spots(:,1)<pos(1)+r+1);  % Check number of spots in relevant regions
                trues_y = (spots(:,2)>pos(2)-r-1 & spots(:,2)<pos(2)+r+1);
                trues_z = (spots(:,3)>z-z_lim & spots(:,3)<z+z_lim);
                trues = trues_x & trues_y & trues_z;
                if sum(trues) > 1   % if More than one spot, take it
                    x_low = pos(1)-(DimOutput/2-1); % Determine limits of cutouts
                    y_low = pos(2)-(DimOutput/2-1);
                    x_up = x_low+DimOutput-1;
                    y_up = y_low+DimOutput-1;
                    if x_low<1 || y_low<1 || x_up>512 || y_up>512   % Drop it if it is to near to the edge
                        spot_cnt = spot_cnt+1;  % go to next spot
                        continue;
                    end
                    ROT = randperm(4,4)-1;  % random index for eventual rotation
                    for l = 1:min(rot,nMorePerCat(i)-more_cnt)   % do multiple rotations, but not more than needed
                        imagestack(:,:,1,stack_cnt) = imrotate(...
                            uint8(datastack_im(y_low:y_up,x_low:x_up,j,i))...
                            ,ROT(l)*90);
                        labelstack(stack_cnt) = GT_labels(gt_cnt);
                        stack_cnt = stack_cnt +1;   % Move Stack-pointer
                        more_cnt = more_cnt+1;  % Success! 1 More found
                    end
                end
                spot_cnt = spot_cnt+1;  % Go to next spot
                if more_cnt == nMorePerCat(i)   % if we have enough spots, quit for loop
                    searchMore = 0;     % ... and while loop
                    break;
                end
            end
            
%             disp("end while");
            if image_cnt >= numberModels     % If we checked all images, but dont have enough... shitty
                error("There are not enough suitible spots in all pictures. Try to import more images or to increase number of rotations.");
            end
            image_cnt = image_cnt+1; % Take next image, as there were not enough suitible spots in this one
        end
    end % end for cat
    % START now to look for the Ones
    for i = 1:length(cat)
        for j = 1:numberModels
            k = 1;
            nb_spots = size(GT{i}{j},1);
            while k <= nOnePerModel
                % select spot from GT
                spot = randperm(nb_spots,1);
                % get x,y,z-coordinates of spot and image-cutout
                pos = round(GT{i}{j}(spot,:));
                if pos(3)>z+z_lim || pos(3)<z-z_lim
                    continue
                end
                x_low = pos(1)-(DimOutput/2-1);
                y_low = pos(2)-(DimOutput/2-1);
                x_up = x_low+DimOutput-1;
                y_up = y_low+DimOutput-1;
                if x_low<1 || y_low<1 || x_up>512 || y_up>512
                    continue;
                end
                % trues only care about center-window
                trues_x = (GT{i}{j}(:,1)>pos(1)-r-1 & GT{i}{j}(:,1)<pos(1)+r+1);
                trues_y = (GT{i}{j}(:,2)>pos(2)-r-1 & GT{i}{j}(:,2)<pos(2)+r+1);
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

    
if any(gtTypes == 5)
    % images without spots in center
    disp("Images without spots in center...");
    % Set z_lim high to keep out all kinds of spots
    z_lim_0 = 10;
    for i = 1:length(cat)
        for j = 1:numberModels
            k = 1;
            while k <= nPerModel(gt_cnt)
                % get random x- and y-position
                x_low = round(unifrnd(0.5,DimInput+0.49-DimOutput));
                y_low = round(unifrnd(0.5,DimInput+0.49-DimOutput));
                % determine image-boundaries
                x_up = x_low+DimOutput-1;
                y_up = y_low+DimOutput-1;
                % check whether there are spots in actual boundaries
                trues_x = (GT{i}{j}(:,1)>x_low+(DimOutput/2-1-r) & GT{i}{j}(:,1)<x_up-(DimOutput/2-r));
                trues_y = (GT{i}{j}(:,2)>y_low+(DimOutput/2-1-r) & GT{i}{j}(:,2)<y_up-(DimOutput/2-r));
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


if any(gtTypes == 6)
    % images with only one spot at the edge
    disp("Images with only one spot at the edge...");
    for i = 1:length(cat)
        for j = 1:numberModels
            k = 1;
            while k <= nPerModel(gt_cnt)
                % select spot from GT
                nb_spots = size(GT{i}{j},1);
                spot = randperm(nb_spots,1);
                % get x,y,z-coordinates of spot and image-cutout
                pos = round(GT{i}{j}(spot,:));
                x_low = pos(1);
                y_low = pos(2)-randperm(DimOutput,1)-1;
                x_up = x_low+DimOutput-1;
                y_up = y_low+DimOutput-1;
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

if any(gtTypes == 7)
    % images with one spot at the edge and second in space
    disp("Images with only one spot at the edge and second in space...");
    for i = 1:length(cat)
        for j = 1:numberModels
            k = 1;
            while k <= nPerModel(gt_cnt)
                % select spot from GT
                nb_spots = size(GT{i}{j},1);
                spot = randperm(nb_spots,1);
                % get x,y,z-coordinates of spot and image-cutout
                pos = round(GT{i}{j}(spot,:));
                x_low = pos(1);
                y_low = pos(2)-randperm(DimOutput,1)-1;
                x_up = x_low+DimOutput-1;
                y_up = y_low+DimOutput-1;
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

if length(gtTypes) ~= gt_cnt-1
    warning("Somehow not all types of GT have been generated :/");
end
if stack_cnt-1 ~= N
    warning("Not all images have been generated, stack-counter did not arrive at the end of stack.");
end

%% Scaling, Inverting

disp("Scaling and inverting...");
if scaling == 1
    for i=1:N
        index = rand(1) < ratioScaling;
        if index == 1
            height = max(max(imagestack(:,:,1,i)));
            diff = 255 - height;
            factor = scalingFactor(1)+(scalingFactor(2)-scalingFactor(1))*rand(1);
            finalFactor = ((diff*factor)+height)/height;
            imagestack(:,:,1,i) = finalFactor*imagestack(:,:,1,i);
        end
    end
end
        

if inverting == 1
    for i=1:N
        index = rand(1) < ratioInverting;
        if index == 1
            top = max(max(imagestack(:,:,1,i)))+min(min(imagestack(:,:,1,i)));
            imagestack(:,:,:,i) = top*uint8(ones(DimOutput))-imagestack(:,:,:,i);
        end
    end
end
    
    

%% Save generated data to file
save(strcat(path_cutGT,'/imagestack.mat'),'imagestack');
save(strcat(path_cutGT,'/labelstack.mat'),'labelstack');
disp("FINISHED!");
% figure
% hold on
% for i = 1:12
%     subplot(4,5,i)
%     imshow(imagestack(:,:,1,i));
% end
% hold off
