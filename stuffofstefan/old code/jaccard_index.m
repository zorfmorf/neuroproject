path = "C:\\Eigene Dokumente\CSE UUlm\4_Projekt\neuroproject\stuffofstefan\GTRUTH\validation_data\w20r10_32x32\";
% folder = "\

% Number of images to check
N = 16;
offset = 30;
% Which category?
cat = 5;

% Dimension of images
dim = 32;

% Please pull nets of your choice into workspace
net1 = net_w2_r1_247;
net2 = net_w2_r2_snr47;
net3 = net_w2_r2_snr1247;
net4 = net_w2_r15_snr247;

data = cell(N*5);


for i = 1+offset:N+offset
    image = imread(strcat(path,"images\w20r10_cat",num2str(cat),...
        "_", sprintf('%03d',i),"_val.tif"));
    label = imread(strcat(path,"labels\w20r10_cat",num2str(cat),...
        "_", sprintf('%03d',i),"_val.png"));
    
    sol1 = semanticseg(image,net1);
    sol2 = semanticseg(image,net2);
    sol3 = semanticseg(image,net3);
    sol4 = semanticseg(image,net4);
    
    data{(i-offset-1)*5+1} = label;
    data{(i-offset-1)*5+2} = labeloverlay(image,sol1);
    data{(i-offset-1)*5+3} = labeloverlay(image,sol2);
    data{(i-offset-1)*5+4} = labeloverlay(image,sol3);
    data{(i-offset-1)*5+5} = labeloverlay(image,sol4);
end
figure(1)
for i = 1:5*N
    subplot(ceil(N/2),10,i)
    imshow(data{i});
end
    
    
    
        