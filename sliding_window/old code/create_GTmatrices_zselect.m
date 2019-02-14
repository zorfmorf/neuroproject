
%% Skript

clear all, close all, clc

% select z-component, if multiple, give vector
Z = 6;

disp("Selecting particles...");
% load gtruth-data
cat = "cat12";
load(strcat("GTRUTH\all\raw_data\gtruth_",cat,".mat"));
spots_true = gtruth_cat12;
% spots_true contains ALL particles with all z-values
% all particles in Z +- z_limit of this category are added to ground-truth

% Will contain for each cat a 3D-array of matrices/labels
gtruth_store = cell(1,max(Z));

% Create here labels
for z = Z
    [gtruth_store{z}, particles_for_z] = create_GTmatrices_PTCdata(spots_true, z);
    for i=1:length(spots_true)
        spots_true{i} = spots_true{i}(particles_for_z{i},:);
    end
end
% save the list with particles for this z-configuration here:
gtruth_cat12_z05 = spots_true;
save(strcat("GTRUTH\z05\",cat,"\gtruth_",cat,"_z05"),strcat("gtruth_",cat,"_z05"));

disp('Writing images...');
for z=Z
    number_frames = size(gtruth_store{z},3);
    for i = 1:number_frames
        name = strcat('GTRUTH\z05\',cat,...
            '/',cat,'_',sprintf('%03d',i-1),...
            'z', sprintf('%02d',z-1),'_lb.png');
        imwrite(gtruth_store{z}(:,:,i),name, 'PNG');
    end
end