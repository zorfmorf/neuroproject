function spots = find_spots_in_ROI(image,params,ROI)
%FIND_SPOTS in ROI Returns mean position of spots in the input image

%% Find peak intensities via Threshold

L = image > params.intensityThreshold; %Binary threshold image
J=image.*L.*ROI;      %look for both high intensity and 2nd derivative in ROI

%% Part to be executed for finding spots via NN
NetSol = semanticseg(image,net);
A = NetSol == "o";  % place here whatever labels "true" in your NN
J = A.*ROI.*image;

%%


%----------TK 06.09.17 // Visualize filtering steps
% figure('Name','Original','NumberTitle','off'), imshow(image,'DisplayRange',[0 max(max(image))], 'InitialMagnification', 400) %TK 05.09.2017
% figure('Name','2nd_order_derivative_negative_part','NumberTitle','off'), imshow(K,'DisplayRange',[0 max(max(K))]) %TK 05.09.2017
% figure('Name','Threshold','NumberTitle','off'), imshow(L,'DisplayRange',[0 max(max(L))]) %TK 05.09.2017
% figure('Name','Combined','NumberTitle','off'), imshow(J,'DisplayRange',[0 max(max(J))]) %TK 05.09.2017

% get spots from connected components
components  = bwconncomp(J, 8); %Contains number of connected components  and indices of pixels with at least 8 pixels
spots       = zeros(components.NumObjects, 2);

for i = 1:components.NumObjects %Iterate through connected components and write centre of spot into variable
    [Y, X]      = ind2sub(components.ImageSize, components.PixelIdxList{i}); %Pixel indices of spot
    spots(i, 1) = dot(J(components.PixelIdxList{i}), X) / sum(J(components.PixelIdxList{i})); %Average index in x-direction
    spots(i, 2) = dot(J(components.PixelIdxList{i}), Y) / sum(J(components.PixelIdxList{i})); %Average index in y-direction
end
end
