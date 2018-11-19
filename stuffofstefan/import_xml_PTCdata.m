function [spotsAll_True, spots_true] = import_xml_PTCdata(file_directory)
%%
% This function imports a xml-file with ground-truth-data 
% specifically from particle-tracking-challenge and stores data in (cell-)arrays
% Should be adapted to also store tracks...
% 
% Input:
%     file_directory: string, contains path of file to be imported
% Output:
%     spotsAll_True: Complete array of all data, sorted by particles
%         1st col: Number of frame in which particle appears
%         2nd col: x-coordinate of particle in this frame
%         3rd col: y-coordinate of particle in this frame
%         4th col: z-coordinate of particle in this frame
%     spots_true: cell-array, as long as number of frames
%         each cell represents one frame and contains x- and y-coordinates
%         of all particles appearing in this frame
% 
% Written by: Rubina, 2018
% Adapted:
%     2018-11-11, Stefan Gerlach
%         declaration as function, removed offset of x- and y- coord. in 
%         first for-loop
%     2018-11-13, Stefan Gerlach
%         additionally getting z-coordinates
%     2018-11-18, Stefan Gerlach
%         re-added offset for x-, y-, z-coordinates
%         
%%

docGround = xmlread(file_directory);
detection = docGround.getElementsByTagName('detection'); %find all spots
L = detection.getLength;
spotsAll_True = zeros(L,4);
disp("Reading data...");
%create a table with all coordinates and frame numbers
for k = 1:detection.getLength
    spotsAll_True(k,1) = str2double(detection.item(k-1).getAttribute("t"));
    spotsAll_True(k,2) = str2double(detection.item(k-1).getAttribute("x"));
    spotsAll_True(k,3) = str2double(detection.item(k-1).getAttribute("y"));
    spotsAll_True(k,4) = str2double(detection.item(k-1).getAttribute("z"));
end

numberFrames = max(spotsAll_True(:,1))+ 1; %Find the number of frames(max. value of t)
indices = cell(1,numberFrames);
spots_true = cell(1,numberFrames);

%Finding the x and y coordinates for every spot in each frame
for i= 1:numberFrames
    indices{i} = find(spotsAll_True(:,1) == i-1); %find all values for the frame 
    for j = 1:length(indices{i})
        spots_true{1,i}(j,1) = spotsAll_True(indices{i}(j),2)+1;
        spots_true{1,i}(j,2) = spotsAll_True(indices{i}(j),3)+1;
        spots_true{1,i}(j,3) = spotsAll_True(indices{i}(j),4)+1;
    end
end
%plot (handles.spots{curFrame}(:,1),handles.spots{curFrame}(:,2),'MarkerEdgeColor', 'r',plotInputArgs{:},'Parent',handles.axes1)