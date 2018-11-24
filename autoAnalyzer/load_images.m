function [images,nikonInfo] = load_images(path)
%LOAD_IMAGES Loads images from a multi-page tiff into a cell array
%Output:    images: Cell array containing one image in each cell
%           nikonInfo: Infos extracted from .tif tags

    if nargin < 1
        [file, path]    = uigetfile('*.tif;*.tiff;*.stk');
        path            = fullfile(path, file);
    end
    [imageStruct,~,nikonInfo] = tiffread2(path);
    
    images = arrayfun(@(image) double(image.data), imageStruct, 'UniformOutput', false);
end
