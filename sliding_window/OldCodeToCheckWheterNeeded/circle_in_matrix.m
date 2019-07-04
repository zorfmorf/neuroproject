function A = circle_in_matrix(A, x_center, y_center, radius)
%% This function writes a circle of Ones(true) into a matrix A
% Input:
%     A: Any matrix. Attention: corresponding elements of A will be overwritten
%     x_center: x-coordinate of the wished center of the circle
%     y_center: y-coordinate of the wished center of the circle
%     radius: radius of the circle
% Output:
%     A: Same matrix as input-matrix, but with a circle of Ones in it,
%         corresponding to the input-variables
%         
% Written by: Stefan Gerlach, 2018-11-12
% Adapted:


%%

sizeX = size(A,2);
sizeY = size(A,1);
x = round(x_center);
y = round(y_center);

% two array with x- and y-coordinates of all entries in matrix
[x_coord, y_coord] = meshgrid(1:sizeX, 1:sizeY);

% create 2D logical array
circlePixels = (y_coord - y).^2 + (x_coord - x).^2 <= radius.^2;

% set entries to 1
A(circlePixels) = 1;
