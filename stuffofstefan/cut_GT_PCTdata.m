clear all, close all, clc

% Name path
path = 'C:\Eigene Dokumente\CSE UUlm\4_Projekt\neuroproject\stuffofstefan\GTRUTH_virus_all_z05';
spec = ["1high","1low","1mid","2high","2low","2mid","4high","4low","4mid",...
    "7high","7low","7mid"];
pic_spec = ["1 density high","1 density low","1 density mid",...
    "2 density high","2 density low","2 density mid",...
    "4 density high","4 density low","4 density mid",...
    "7 density high","7 density low","7 density mid"];


% Take the first ...
limit = 10;
% pictures of each setup and from each create ...
N = 9;
% small pictures (12*limit*N)
% Dimensions of big pictures:
dim_large = 512;
% Dimension of small pictures:
dim_small = 32;

% Initialize cell-arrays for labels and images
training_labels = cell(12,1);
training_images = cell(12,1);
for j=1:12
    training_labels{j,1} = zeros(dim_small, dim_small, N*limit);
    training_images{j,1} = zeros(dim_small, dim_small, N*limit);
end

for l = 1:12 % For all setups

    % further path
    fpath = strcat('\gtruth_pcd_virus',spec(l),'_z05');
    fullpath = strcat(path,fpath);

    for i=1:limit % For all images
        label = imread(strcat(fullpath,"\VIRUS snr ",pic_spec(l),...
            " t0",sprintf('%02d',i-1)," z05.png"));
        image = imread(strcat(fullpath,"\VIRUS snr ",pic_spec(l),...
            " t0",sprintf('%02d',i-1)," z05.tif"));

        k = 1;
        while k <= N
            random_xpos = round(unifrnd(0.5, dim_large-dim_small+0,49));
            random_ypos = round(unifrnd(0.5, dim_large-dim_small+0,49));

            small_image_label = label(random_xpos:random_xpos+dim_small-1,...
                random_ypos:random_ypos+dim_small-1);

            % Check wether all edges are =0
            if (all(small_image_label(:,1)==0) && all(small_image_label(:,end)==0) &&...
                    all(small_image_label(1,:)==0) && all(small_image_label(end,:)==0)...
                    && any(any(small_image_label ~= 0)))
                training_labels{l}(:,:,(i-1)*N+k) = small_image_label;
                training_images{l}(:,:,(i-1)*N+k) = image(random_xpos:random_xpos+dim_small-1,...
                random_ypos:random_ypos+dim_small-1);
                k = k+1;
            end
        end
    end
end
save("training_labels_virus_z05.mat", "training_labels");
save("training_images_virus_z05.mat", "training_images");
        
