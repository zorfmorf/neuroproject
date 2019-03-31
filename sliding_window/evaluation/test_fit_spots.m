
test_tif = imread("test.tif");
std_dev_noise = 15.0;%evar(test_tif);
gauss_fit_stack = zeros(1, 2);
gauss_fit_stack(1,:) = [34, 18];
fitted_spots = fit_spots_fast(double(test_tif), double(std_dev_noise), double(gauss_fit_stack));
