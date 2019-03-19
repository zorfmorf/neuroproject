% Images and labels are created and can be found in the respective folder
% litle program to unify all images and labels in one imagestack/labelstack
% rotate and flip for having more images for training

clear, clc
N = 2*100*50;
imagestack = zeros(32,32,1,N,'uint8');
labelstack = zeros(32,32,1,N,'uint8');

stack_cnt = 1;


for i = [7 10]
    path_l = "gtruthDS/z05-labels/cat"+num2str(i)+"/";
    files_l = dir(fullfile(path_l,'*.png')); 
    path_i = "gtruthDS/z05-images/cat"+num2str(i)+"/";
    files_i = dir(fullfile(path_i,'*.tif')); 
    for j = 1:100
        F_l = fullfile(path_l,files_l(j).name);
        I_l = imread(F_l);
        F_i = fullfile(path_i,files_i(j).name);
        I_i = imread(F_i);
        for k = 1:50
            x = round(unifrnd(1.5, 480.5));
            y = round(unifrnd(1.5, 480.5));
            imagestack(:,:,:,stack_cnt) = I_i(x:x+31,y:y+31);
            labelstack(:,:,:,stack_cnt) = I_l(x:x+31,y:y+31);
            stack_cnt = stack_cnt +1;
        end
    end
end 

% stack_cnt = 1;
% for i = [7 9 10 12]
%     path_l = "gtruthDS/z05-labels/cat"+num2str(i)+"/";
%     files_l = dir(fullfile(path_l,'*.png')); 
%     for j = 1:100
%         
%         for k = 1:3
%             x = unifrnd(1.5, 480.5);
%             y = unifrnd(1.5, 480.5);
%             labelstack(:,:,:,stack_cnt) = I_i(x:x+31,y:y+31);
%             stack_cnt = stack_cnt +1;
%         end
%     end
% end 

save("gtruthDS/imagestack_trial.mat","imagestack");
save("gtruthDS/labelstack_trial.mat","labelstack");