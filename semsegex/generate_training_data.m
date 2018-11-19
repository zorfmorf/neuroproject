clear all

%sourceImageFolder = "C:\Users\zorfmorf\Downloads\receptor\RECEPTOR snr 7 density mid"; % absolut path to directory with source images
sourceGTFile = "C:\Users\zorfmorf\Downloads\receptor\"; % absolut path to directory with source images
%sourceGTFile = "/Users/zorfmorf/Projects/uni/neuroproject/semsegex/data/ground_truth/";
%sourceImageFolder = "/Users/zorfmorf/Projects/uni/neuroproject/semsegex/data/RECEPTOR snr 7 density mid";

TRAINING_IMAGE_SIZE = 32;
IMAGE_WIDTH = 512;
IMAGE_HEIGHT = 512;

xmlFiles = dir(strcat(sourceGTFile, '*.xml'));

trainingImageCounter = 0;

for file = xmlFiles'
    outputname = replace(file.name, '.xml', '');
    fprintf(1, 'Processing file %s to %s\n', file.name, outputname)
    docGround = xmlread(strcat(sourceGTFile, file.name));
    generateBlops = 0;

    detection = docGround.getElementsByTagName('detection'); %find all spots
    L = detection.getLength;
    tlength = 100; % starts at one but actually at zero

    % x, y, t
    % ground truth data image
    gtd = zeros(IMAGE_WIDTH,IMAGE_HEIGHT,tlength);

    % read spots and write to data
    listOfSpots = struct('x', cell(1, L), 'y', cell(1, L), 't', cell(1, L));
    for k = 1:L
        %fprintf("Handling GT for %d/%d\n", k, L)
        item = detection.item(k-1); % indices start at 0
        try
            y = floor(str2double(item.getAttribute("x"))+1);
            x = floor(str2double(item.getAttribute("y"))+1);
            t = floor(str2double(item.getAttribute("t"))+1);

            % now create circle of ones, faster than doing a loop, couldn't
            % find a function that does this for me
            gtd(x,y,t) = 1;
            
            % FIXME TODO never write out of bounds or catch these errors
            % later
            if generateBlops
                try gtd(x+1,y-1,t) = 1; catch end
                try gtd(x+1,y,t) = 1; catch end
                try gtd(x+1,y+1,t) = 1; catch end
                try gtd(x,y-1,t) = 1; catch end
                try gtd(x,y+1,t) = 1; catch end
                try gtd(x-1,y-1,t) = 1; catch end
                try gtd(x-1,y,t) = 1; catch end
                try gtd(x-1,y+1,t) = 1; catch end
                try gtd(x,y+2,t) = 1; catch end
                try gtd(x,y-2,t) = 1; catch end
                try gtd(x-2,y,t) = 1; catch end
                try gtd(x+2,y,t) = 1; catch end
            end
            
            % now write blop data for it
             listOfSpots(k).x = x;
             listOfSpots(k).y = y;
             listOfSpots(k).t = t;

        catch ME
            fprintf("Could not read values for k = %d\n", k)
            ME
        end
    end

    % now go over all images in the image workspace and read them
    imageData = zeros(tlength,IMAGE_WIDTH,IMAGE_HEIGHT);
    images = dir(strcat(sourceGTFile, outputname, '\*.tif'));
    counter = 1;
    for image = images'
        imageData(counter,:,:) = imread(fullfile(image.folder, image.name));
        counter = counter + 1;
    end
    
    % now for each detection, create corresponding training image pairs
    for k = 1:L
        
        spot = listOfSpots(k);
        
        % first calculate positions
        xoffset = round(rand() * 20 - 10);
        yoffset = round(rand() * 20 - 10);
        xstart = spot.x - xoffset;
        if xstart < 1
           xstart = 1; 
        end
        if xstart + TRAINING_IMAGE_SIZE > IMAGE_WIDTH
            xstart = IMAGE_WIDTH - TRAINING_IMAGE_SIZE;
        end
        ystart = spot.y - yoffset;
        if ystart < 1
            ystart = 1;
        end
        if ystart + TRAINING_IMAGE_SIZE > IMAGE_HEIGHT
            ystart = IMAGE_HEIGHT - TRAINING_IMAGE_SIZE;
        end
        
        % copy training image data to labels folder
        img = imageData(spot.t,ystart:(ystart+TRAINING_IMAGE_SIZE),ystart:(ystart+TRAINING_IMAGE_SIZE)); % image we want to copy
        imwrite(img, strcat('trainingImages\', num2str(trainingImageCounter), '.tif'));
        ground = gtd(xstart:(xstart+TRAINING_IMAGE_SIZE),ystart:(ystart+TRAINING_IMAGE_SIZE), spot.t); % image we want to copy
        imwrite(ground, strcat('trainingLabels\', num2str(trainingImageCounter), '.tif'));
        trainingImageCounter = trainingImageCounter + 1;
    end
    
    % write to target
    %fprintf(1, 'Writing file targets...\n')
    %for t=1:tlength
    %    name = strcat('trainingLabels/', outputname, '_', sprintf('%03d',t-1), '.tif');
    %    imwrite(gtd(:,:,t), name)
    %end
end
