clear all, close all, clc

% select z-component
% Attention: Z is in [1,10], images are in [z00,z09]
Z = 6;

% choose radius:
radius = 0;

% choose width of heigth
z_limit = 2;

% choose number of frames from each category
N = 100;

disp("Loading data...");
load_data = cell(1,12);
save_data = cell(1,12);
for i = 1:12
    load(strcat("gtruthDS\raw_data\gtruth_cat",num2str(i),".mat"));
end

load_data{1} = gtruth_cat1;
load_data{2} = gtruth_cat2;
load_data{3} = gtruth_cat3;
load_data{4} = gtruth_cat4;
load_data{5} = gtruth_cat5;
load_data{6} = gtruth_cat6;
load_data{7} = gtruth_cat7;
load_data{8} = gtruth_cat8;
load_data{9} = gtruth_cat9;
load_data{10} = gtruth_cat10;
load_data{11} = gtruth_cat11;
load_data{12} = gtruth_cat12;
    
for k = 7:12

    cat = strcat("cat",num2str(k)); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    spotsAllList = cell(1,N);
    for i = 1:N
        spotsAllList{i} = load_data{k}{i}; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    % spotsAll contains ALL particles with all z-values
    % all particles in Z +- z_limit of this category are added to ground-truth

    % Create here labels

    gtruth_store = zeros(512,512,N);
    particles_for_z = cell(1,N);
    disp(strcat("Creating GT-matrices (",num2str(k),")..."));
    for i=1:N
        disp(i);
        particles = 1:size(spotsAllList{i},1);

        % select particles
        particles_for_z{i} = abs(spotsAllList{i}(:,3)-Z) < z_limit;
        for j = particles(particles_for_z{i})
            gtruth_store(:,:,i) = circle_in_matrix(gtruth_store(:,:,i),...
                spotsAllList{i}(j,1), spotsAllList{i}(j,2), radius);
        end
    end

    for i=1:length(spotsAllList)
        spotsAllList{i} = spotsAllList{i}(particles_for_z{i},:);
    end
    save_data{k} = spotsAllList;

    disp('Writing images...');


    for i = 1:N
        name = strcat('gtruthDS\OnePointLabels\',cat,...
            '\z05w20r00_',cat,'_',sprintf('%03d',i-1),...
            '_lb.png');
        imwrite(gtruth_store(:,:,i),name, 'PNG');
    end
end

disp("Saving data...");
gtruth_z05w20r10_cat1 = save_data{1};
gtruth_z05w20r10_cat2 = save_data{2};
gtruth_z05w20r10_cat3 = save_data{3};
gtruth_z05w20r10_cat4 = save_data{4};
gtruth_z05w20r10_cat5 = save_data{5};
gtruth_z05w20r10_cat6 = save_data{6};
gtruth_z05w20r10_cat7 = save_data{7};
gtruth_z05w20r10_cat8 = save_data{8};
gtruth_z05w20r10_cat9 = save_data{9};
gtruth_z05w20r10_cat10 = save_data{10};
gtruth_z05w20r10_cat11 = save_data{11};
gtruth_z05w20r10_cat12 = save_data{12};

for k= 7:12
    save(strcat("gtruthDS\OnePointLabels\cat",num2str(k),"\gtruth_z05w20r10_cat",...
        num2str(k),".mat"),strcat("gtruth_z05w20r10_cat",num2str(k)));
end
disp("FINISHED!!!");
