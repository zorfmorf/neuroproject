clear all, close all, clc
[spotsAll_true, spots_true] = import_xml_PTCdata...
    ('C:\Eigene Dokumente\CSE UUlm\4_Projekt\PartChallengeData\ground_truth\ground_truth\VIRUS snr 7 density high.xml');

% select z-component, if plusieurs, give vector
Z = 6;

gtruth_store = cell(1,10);
for z = Z
    [gtruth_store{z}, particles_for_z] = create_GTmatrices_PTCdata(spots_true, z);
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


