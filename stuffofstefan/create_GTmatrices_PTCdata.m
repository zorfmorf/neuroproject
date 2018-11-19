function [gtruth_store, particles_for_z] = create_GTmatrices_PTCdata(...
    spots_true, z)
% %%
% This function transforms ground-truth-data from particle challenge to
% ground-truth-data in forms of pixel-wise 0/1-matrices.
% PROBLEM: Radius of spots is guessed here!!
% 
% Input:
%     spots_true: cell-array of arrays containing x- and y-coordinates of
%         all spots of one frame
%     z: z-coordinate, for which ground-truth should be created, -> only
%         particles with z +- z_limit are added to ground-truth
% Output:
%     gtruth_store: 3D-array containing ground-truth as matrices 
%         (x-coordinate, y-coordinate, frame) with weights 0 or 1, 
%         depending on whether there is a spot or not.
%     particles_for_z: Logical array, true for those particles being in the
%         selected range of z
%         
% Written by: Stefan Gerlach, 2018-11-12
% Adapted:
%     2018-11-17, Stefan Gerlach
%         introduced z, such that only particles within z +- z_limit are
%         added to ground-truth

%%

disp("Creating ground-truth matrices...");
% determin number of frames N
N = length(spots_true);

% set radius !!
radius = 2;

% set critical z-limit
% -> currenz z-coordinate +- z-limit
% for ptc-data 2.5 is ok
z_limit = 2.5;

gtruth_store = zeros(512,512,N);
for i=1:N

    particles = 1:size(spots_true{i},1);

    particles_for_z = abs(spots_true{i}(:,3)-z) < z_limit;
    for j = particles(particles_for_z)
        gtruth_store(:,:,i) = circle_in_matrix(gtruth_store(:,:,i),...
            spots_true{i}(j,1), spots_true{i}(j,2), radius);
    end
end