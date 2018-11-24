function track = exclude_tracks(ROElists, track)
%%Delete tracks from list of spots if they are located inside the region of
%%exclusion (ROE)

%Input: ROElists: Cell array containing one region in each cell
%         tracks:  List of spots

%Output: tracks: List of tracks containing only tracks outside the ROE

    for m = 1:size(ROElists,2) %Iterate through Regions of Exclusion
        if ~isempty(track)
            isIn = sum(inpolygon(track(:,2),track(:,3),ROElists{m}(:,1),ROElists{m}(:,2)));
            if isIn
                track = [];
            end
        end
    end
end