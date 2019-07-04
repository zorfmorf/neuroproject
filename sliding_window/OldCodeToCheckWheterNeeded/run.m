clear all, close all, clc

% select z-component, if multiple, give vector
Z = 6;

% load gtruth-data
load("GTRUTH\all\raw_data\gtruth_cat1.mat");
% all particles in Z +- z_limit of this category are added to ground-truth

gtruth_store = cell(1,10);
for z = Z
    [gtruth_store{z}, particles_for_z] = create_GTmatrices_PTCdata(gtruth_cat1, z);
end

%%
disp('Writing images...');
for z=Z
    number_frames = size(gtruth_store{z},3);
    for i = 1:number_frames
        name = strcat('gtruth_pcd_virus7high_z',sprintf('%02d',z-1),...
            '/VIRUS snr 7 density high t',...
            sprintf('%03d',i-1),' z', sprintf('%02d',z-1),'.png');
        imwrite(gtruth_store{z}(:,:,i),name, 'PNG');
    end
end


