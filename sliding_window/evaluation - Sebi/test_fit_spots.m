
x = 34;
y = 18;
test_tif = imread("test.tif");
test_out = zeros(size(test_tif,1),size(test_tif,2),3);
test_out(:,:,1) = test_tif(:,:,1);
test_out(:,:,2) = test_tif(:,:,1);
test_out(:,:,3) = test_tif(:,:,1);

std_dev_noise = 15.0; %evar(test_tif);
gauss_fit_stack = zeros(1, 2);
gauss_fit_stack(1,:) = [x, y];
fitted_spots = fit_spots_fast(double(test_tif), double(std_dev_noise), double(gauss_fit_stack));
test_out(y,x, 1) = 255;
test_out(floor(fitted_spots(2) + 0.5), floor(fitted_spots(1) + 0.5), 2) = 255;
imwrite(uint8(test_out), "test_out.tif");