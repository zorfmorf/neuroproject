%sourceImageFolder = "C:\Users\zorfmorf\Downloads\receptor\RECEPTOR snr 7 density mid"; % absolut path to directory with source images
%sourceGTFile = "C:\Users\zorfmorf\Downloads\receptor\RECEPTOR snr 7 density mid.xml"; % absolut path to directory with source images
sourceGTFile = "/Users/zorfmorf/Projects/uni/neuroproject/semsegex/data/ground_truth/";
sourceImageFolder = "/Users/zorfmorf/Projects/uni/neuroproject/semsegex/data/RECEPTOR snr 7 density mid";

xmlFiles = dir(strcat(sourceGTFile, '*.xml'));

for file = xmlFiles'
    
    %outputname = replace(file.name, ' ', '_');
    outputname = replace(file.name, '.xml', '');
    fprintf(1, 'Processing file %s to %s\n', file.name, outputname)
    docGround = xmlread(strcat(sourceGTFile, file.name));
    image_width = 512;
    image_height = 512;
    generateBlops = 0;

    detection = docGround.getElementsByTagName('detection'); %find all spots
    L = detection.getLength;
    tlength = 100; % starts at one but actually at zero

    % x, y, t
    % ground truth data image
    gtd = zeros(image_width,image_height,tlength);

    % read spots and write to data
    for k = 1:L
        %fprintf("Handling GT for %d/%d\n", k, L)
        item = detection.item(k-1); % indices start at 0
        try
            x = floor(str2double(item.getAttribute("x"))+1);
            y = floor(str2double(item.getAttribute("y"))+1);
            t = floor(str2double(item.getAttribute("t"))+1);

            % now create circle of ones, faster than doing a loop, couldn't
            % find a function that does this for me
            gtd(x,y,t) = 1;
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

        catch ME
            fprintf("Could not read values for k = %d\n", k)
            ME
        end
    end

    % write to target
    fprintf(1, 'Writing file targets...\n')
    for t=1:tlength
        name = strcat('trainingLabels/', outputname, '_', sprintf('%03d',t), '.tif');
        imwrite(gtd(:,:,t), name)
    end
end

% using a convenient function is wayyyyyyy too slow holy cow botman
function gtd = setOne(gtd, x, y, t)
    [m,n] = size(gtd);
    if x > 0 && y > 0 && x <= m && y <= n
       gtd(x, y, t) = 1; 
    end
end