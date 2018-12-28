path = 'GTRUTH/z05w20r10_cut/images';
files = dir(fullfile(path,'*.tif'));
store = zeros(32,32,5);
for k = 1:5
    F = fullfile(path,files(k).name);
    I = imread(F);
    store(:,:,k) = I;
end