function [tracksInArea, remaining] = find_tracks_in_area(Area, tracks, sequencing)
%%Delete tracks from list of spots if they are located outside Area

%Input: Area: Cell array - #cell = #Frames // Each cell contains cells where #cells = #Areas
%       tracks:  List of tracks
%       sequencing: the sequences by which the substacks have been divided

%Output: tracks: List of tracks containing only tracks inside Area

s = 0; t = 0;

tracksInArea = cell(0);
remaining = cell(0);



for m = 1:size(tracks,2) %Iterate through tracks
    if ~isempty(tracks)
        isInAnywhere = 0;
        frameOfFirstSpotInTrack = tracks{m}(1,1);
        divisor = ceil(frameOfFirstSpotInTrack/sequencing(2));
              
        for n = 1:length(Area{divisor})
            isIn = sum(inpolygon(tracks{m}(:,2),tracks{m}(:,3),Area{divisor}{n}(:,2),Area{divisor}{n}(:,1)));
            if isIn
                isInAnywhere = isInAnywhere + 1;
            end
        end
        
        if isInAnywhere
            s = s + 1;
            tracksInArea{s} = tracks{m};
        else
            t = t + 1;
            remaining{t} = tracks{m};
        end        
    end
end