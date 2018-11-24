function tracks = find_tracks_mod(spots, maxDisplacement, maxDarkFrames)
%TRACK_SPOTS 
%  Output:  Cell array containing one trail in each cell -> #cells = #trails
% %         Cell content:    Number of lines in a cell corresponds to the number spots in the trail
%                            tracks{i}(:, 1): Frame in which spots appears
%                            tracks{i}(:, 2): x-values of the spots in trail
%                            tracks{i}(:, 3): y-values of the spots in trail
%                            tracks{i}(:, 4) = Intensity
%                            tracks{i}(:, 5) = Variance in x-direction
%                            tracks{i}(:, 6) = Variance in y-direction
%                            tracks{i}(:, 7) = Offset of 2D-Gaussian
%                            tracks{i}(:, 8) = (Sum of all pixels) - (offset*number of pixels)
%                            tracks{i}(:, 9) = Fitting error?
%                            tracks{i}(:, 10) = Orientation of 2D-Gaussian (Angle);

    tracks          = {};
    activeTrails    = zeros(0, 4); % index, last frame, last x, last y
        
    for i = 1:length(spots) %Iterate through frames
        
        %% Calculate distance between each spot of current and subsequent frame
        repmat(activeTrails(:, 3), 1, size(spots{i}, 1));
        repmat(spots{i}(:, 1)', size(activeTrails, 1), 1);
        xDists = repmat(activeTrails(:, 3), 1, size(spots{i}, 1)) ...    %x-positions of spots in current frame
            - repmat(spots{i}(:, 1)', size(activeTrails, 1), 1);          %x-positions of spots in subsequent frame
        yDists = repmat(activeTrails(:, 4), 1, size(spots{i}, 1)) ...    %y-positions of spots in current frame
            - repmat(spots{i}(:, 2)', size(activeTrails, 1), 1);         %y-positions of spots in subsequent frame
        dists = xDists.^2 + yDists.^2;                                   %Squared distances between all spots// #rows=#spots in first frame, #columns = #spots in second frame
        %% Add closest spots to the end of the trails
        trailIndices    = 1:size(activeTrails, 1); %Running index for each active frame
        spotIndices     = 1:size(spots{i}); %Running index for each spot in current frame

        %Search (in first frame) for nearest neighbour of each spot in subsequent frame, then iterate through all distances which are
        %smaller than maxDisplacement
        while ~isempty(dists) 
            [spotMins, minIndices]      = min(dists, [], 1); %Get smallest distance of each column -> nearest neighbour of each spot of second frame
            [minDist, minSpot]          = min(spotMins); %Get smallest distance 
            
            if minDist > maxDisplacement^2 %Stop if distance smaller than max allowed displacement
                break;
            end
                       
            activeTrailIndex                        = trailIndices(minIndices(minSpot)); %Index of the current distance in the corresonding row in dists
            trailIndex                              = activeTrails(activeTrailIndex, 1);
            spot                                    = spotIndices(minSpot);
            activeTrails(activeTrailIndex, 2:end)   = [i, spots{i}(spot, 1:2)];
            tracks{trailIndex}                      = [tracks{trailIndex}; [i, spots{i}(spot, :)]];
            
            dists           = dists(1:length(trailIndices) ~= minIndices(minSpot), 1:length(spotIndices) ~= minSpot);
            trailIndices    = trailIndices(1:length(trailIndices) ~= minIndices(minSpot));
            spotIndices     = spotIndices(1:length(spotIndices) ~= minSpot);
        end
        
        %% Make a new trail for anything not matched
        newTrailIndices         = colon(length(tracks)+1, length(tracks)+length(spotIndices)); %Gives each (new) trail a running index   
        newTrails               = [ones(length(spotIndices), 1)*i, spots{i}(spotIndices, :)]; %Contains frame# in first column // One row for each spot (which did not match)
        tracks(newTrailIndices) = mat2cell(newTrails, ones(size(newTrails, 1), 1), size(newTrails, 2)); %Add cells containing new spots (which did not match) at the end of the cell array
        activeTrails            = cat(1, activeTrails, [newTrailIndices', ones(length(spotIndices), 1)*i, spots{i}(spotIndices, 1:2)]); %Add the new spots to the list of active trails
        %% Filter old trails
        activeTrails = activeTrails(i-activeTrails(:, 2) <= maxDarkFrames, :); %Throw out spots which have been dark longer than maxDarkFrames
    end
end

