function spots = exclude_spots(ROElists, spots)
%%Delete spots from list of spots if they are located inside the region of
%%exclusion (ROE)

%Input: ROElists: Cell array containing one region in each cell
%         spots:  List of spots

%Output: spots: List of spots containing only spots outside the ROE

for m = 1:size(ROElists,2) %Iterate through Regions of Exclusion
        if ~isempty(spots)
            IN = inpolygon(spots(:,1),spots(:,2),ROElists{m}(:,1),ROElists{m}(:,2)); %Look up which spots are inside ROE
            spots = spots(IN == 0,:); %Save only spots which are not inside ROE 
        end
end

end

