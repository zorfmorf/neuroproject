function tracks = findDiffusionTracks(spots,maxdistance)
%Searches pairwaise for tracks, so that tracks are drawn only for frames
%1->2, 3->4, 5->6 etc.

        tracks = {};
        emptySpotCellArray = cell(1, length(spots));
        
        for i=1:length(emptySpotCellArray)
            emptySpotCellArray{i} = zeros(0,2);
        end
                
        for i=1:floor(length(spots)/2) 
            currentSpots = emptySpotCellArray;
            currentSpots{2*i-1} = spots{2*i-1}; %Fill Spot list with Spots of current Frame 
            currentSpots{2*i} = spots{2*i}; %Fill Spot list with Spots of subsequent Frame
            tracks = [tracks, find_tracks_mod(currentSpots, maxdistance, 0)]; %#ok<AGROW>
        end

end

