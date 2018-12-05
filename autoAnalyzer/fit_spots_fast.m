function spots_new = fit_spots_fast(image, snr, spots)
    spots_new = cell(1,length(image));
    % fixme TODO parfor
    for m=1:length(image)
        curImage = image{m};
        curSpots = [spots{m}, zeros(size(spots{m}, 1), 7)]; % add columns to store fitting parameters
        [xc,yc,~,~] = fastFitting(curImage, curSpots(:,1), curSpots(:,2), snr, "circle");
        spots_new(m,1) = xc;
        spots_new(m,2) = yc;
    end
end
