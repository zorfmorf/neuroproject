%%
% This code takes from a very specific path a number of images and
% ground-truth with very specific names. From these, it cuts out pieces of 
% 32x32 px to generate smaller training-data. They are stored in cell-arrays. 
% At the end, the images are written to another specific folder.
%%
clear all, close all, clc


% Take the first ...
limit = 10;
offset = 0; % maximal offset: 10
% pictures of each category and from each create ...
N = 12;
% small pictures (12*limit*N)
% Dimensions of big pictures:
dim_large = 512;
% Dimension of small pictures:
dim_small = 32;

% Initialize cell-arrays for labels and images
% training_labels = cell(12,1);
% training_images = cell(12,1);
% for j=1:12
%     training_labels{j,1} = zeros(dim_small, dim_small, N*limit);
%     training_images{j,1} = zeros(dim_small, dim_small, N*limit);
% end

for l = 1:12 % For all setups/categories

    % path
    cat = strcat("cat",num2str(l));
    path = strcat("GTRUTH\z05w20r10\",cat);
    

    for i=1+offset:limit+offset % For the first 'limit' images
        label = imread(strcat(path,"\z05w20r10_",cat,"_",...
            sprintf('%03d',i-1),"_lb.png"));
        image = imread(strcat("GTRUTH\all\images\",cat,"\",cat,...
            "_",sprintf('%03d',i-1),"z05.tif"));

        k = 1;
        while k <= N % take N small pics out of image
            random_xpos = round(unifrnd(0.5, dim_large-dim_small+0,49));
            random_ypos = round(unifrnd(0.5, dim_large-dim_small+0,49));

            small_image_label = label(random_xpos:random_xpos+dim_small-1,...
                random_ypos:random_ypos+dim_small-1);

            % Check wether all edges are =0 and if a spot is in image
            if (all(small_image_label(:,1)==0) && all(small_image_label(:,end)==0) &&...
                    all(small_image_label(1,:)==0) && all(small_image_label(end,:)==0)...
                    && any(any(small_image_label ~= 0)))
                %training_labels{l}(:,:,(i-1)*N+k) = small_image_label;
                %training_images{l}(:,:,(i-1)*N+k)
                a = image(random_xpos:random_xpos+dim_small-1,...
                    random_ypos:random_ypos+dim_small-1);
                imwrite(small_image_label,strcat("GTRUTH\validation_data\labels\",...
                    "w20r10_",cat,"_",sprintf('%03d',(i-1-offset)*N+k),"_val.png"),"PNG");
                imwrite(uint8(a),strcat("GTRUTH\validation_data\images\",...
                    "w20r10_",cat,"_",sprintf('%03d',(i-1-offset)*N+k),"_val.tif"),"TIF");
                k = k+1;
            end
        end
    end
end

        
