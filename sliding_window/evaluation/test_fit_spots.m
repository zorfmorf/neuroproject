
test_tif = imread("test.tif");
gauss_fit_stack = zeros(1, 2);
gauss_fit_stack(1,:) = [14, 14];
fitted_spots = fit_spots_fast(double(test_tif), 4.0, double(gauss_fit_stack));
