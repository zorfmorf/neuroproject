function spots_new = fit_spots_fast(image, snr, spots)
    
    % FIXME based on params or something
    MQ = 5;
    
    spots_new = cell(1,length(image));
    % fixme TODO parfor
    for m=1:length(image)
        curImage = image{m};
        curSpots = [spots{m}, zeros(size(spots{m}, 1), 7)]; % add columns to store fitting parameters
        
        % now run fitting for each potential point
        for j=1:length(curSpots(:,1))
            tx = floor(curSpots(j,1) - MQ / 2);
            ty = floor(curSpots(j,2) - MQ / 2);
            
            % handle edge cases
            if tx < 1; tx = 1; end
            if ty < 1; tx = 1; end
            if tx + MQ > length(curImage); tx = length(curImage) - MQ; end 
            if ty + MQ > length(curImage); ty = length(curImage) - MQ; end
            
            subImage = curImage(tx:tx+MQ,ty:ty+MQ);
            subImageAsRow = subImage(:);
            
            subImageXCoords = [];
            subImageYCoords = [];
            
            for y=ty:ty+MQ
                subImageXCoords = [subImageXCoords tx:tx+MQ];
                subImageYCoords = [subImageYCoords y*ones(MQ+1,1)'];
            end
            
            % now actually fit
            [xc,yc,~,~] = fastFitting(subImageAsRow, subImageXCoords, subImageYCoords, snr, "circle");
            spots_new(m,1,j) = {xc};
            spots_new(m,2,j) = {yc};
        end
    end
end
