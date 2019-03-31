%clearvars -global

% path to the network file
names = [ 
     %"16x16_center_snr47_z1_00", "16x16_center_snr47_z1_20", "16x16_center_snr47_z1_20_s30", "16x16_center_snr47_z3_00", "28x28_center_snr47_z1_00", "ScalInv_center_snr47_z1_20_i20s20", "28x28_012simple_snr47_z3", "28x28_center_snr47_z1_20", "ScalInv_012simple_snr47_z1_i20s20", "ScalInv_center_snr47_z1_20_i30", "28x28_center_snr247_z1_20", "28x28_center_snr47_z3_20", "ScalInv_012simple_snr47_z1_s20", "ScalInv_center_snr47_z1_20_s30", "28x28_012simple_snr47_z1", "28x28_center_snr47_z1_00", "ScalInv_center_snr47_z1_20_i20s20", "28x28_012simple_snr47_z3", "28x28_center_snr47_z1_20", "ScalInv_012simple_snr47_z1_i20s20", "ScalInv_center_snr47_z1_20_i30", "28x28_center_snr247_z1_20", "28x28_center_snr47_z3_20", "ScalInv_012simple_snr47_z1_s20", "ScalInv_center_snr47_z1_20_s30"
     "28x28_center_snr47_z1_00"
 ];
    
test_tif = imread("virus_snr7_dens_mid_t0_z05.tif");
std_dev = 1.0; % standard deviation of background noise

% Test network on respective test set
GEN_PERCENTAGES = false;

% generate a fit image for one dedicacted sample image
GEN_IMAGES = true;
GEN_ORIGINAL = true;
VERBOSE = false;

for id = 1:numel(names)
    
    name = names(id);
    load("../trained networks/" + name + ".mat");
    test_net = net;
    
    prefix = "28x28";
    wid = 28; % width of neuronal network input image
    if startsWith(name, "16x16")
        prefix = "16x16";
        wid = 16;
    end
    if startsWith(name, "ScalInv")
        prefix = "ScalInv";
    end
    widh = floor(wid/2)-1;
    
    name_raw = strrep(name, prefix + "_", "");

    load("../GTRUTH/sliding_window/" + prefix + "/" +  name_raw+ "/test_set/imagestack.mat");
    test_images = imagestack;
    load("../GTRUTH/sliding_window/" + prefix + "/" + name_raw + "/test_set/labelstack.mat");
    test_labels = labelstack;

    if VERBOSE
        fprintf("Classifying " + name + "\n");
    end
    
    if GEN_PERCENTAGES
        [result, err] = classify(test_net, test_images);

        test_size = size(result);

        sumCorrect = 0;
        sumMax = test_size(1);

        err_array = zeros(1000,3);
        correct_array = zeros(1000,3);

        jaccardMatr = zeros(2,2);

        k = 1;
        l = 1;
        for ii=1:sumMax
            img = test_images(:,:,1,ii);

            % TODO only when 60% or more sure?

            outclass = result(ii);

            if outclass == categorical(test_labels(ii))
                if outclass == categorical(1)
                    jaccardMatr(2,2) = jaccardMatr(2,2)+1;
                else 
                    jaccardMatr(1,1) = jaccardMatr(1,1)+1;
                end
                sumCorrect = sumCorrect + 1;
    %                 % display code for debugging
    %                 correct_array(l,1:2) = err;
    %                 correct_array(l,3) = i;
    %                 l = l+1;
    %                 if l == 1001
    %                     break
    %                 end
            else
                err_array(k,1:2) = err(ii);
                err_array(k,3) = ii;
                k = k+1;
                if outclass == categorical(1)
                    jaccardMatr(2,1) = jaccardMatr(2,1)+1;
                else 
                    jaccardMatr(1,2) = jaccardMatr(1,2)+1;
                end
            end
        end
        fprintf("\t " + num2str(sumCorrect / sumMax * 100) + "%%  "+ name + "\n");
    end
    
    if GEN_IMAGES
        
        % now slide window through image and add all results together
        siz = size(test_tif, 1); % size of test image
        scal = 8; % scale up result so we can draw more information into the image
        result = zeros(siz*scal, siz*scal, 3);
        
        if GEN_ORIGINAL
            for i = 1:size(test_tif, 1)
                for j = 1:size(test_tif, 2)
                    result(i*scal-scal+1:i*scal,j*scal-scal+1:j*scal,:) = test_tif(i,j);
                end
            end
        end
        
        if true
            std_dev_noise = evar(test_tif);
            step_size = 3;
            num_img = (floor((siz - wid)/step_size))^2;
            sl_stack = zeros(wid, wid, 1, num_img);
            count = 1;
            for ii=1:step_size:siz-wid
                for jj=1:step_size:siz-wid
                    sl_stack(:, :, 1, count) = test_tif(ii:ii+wid-1,jj:jj+wid-1);
                    count = count + 1;
                end
            end

            fprintf("\t classifying " + num_img + " images\n");
            %[cl, error] = classify(net, sl_stack);

            fprintf("\t generating result image\n");
            gauss_fit_stack = zeros(10, 2);
            count = 1;
            match = 1;
            gauss_fit_counter = 1;
            for ii=1:step_size:siz-wid
                for jj=1:step_size:siz-wid
                    inc = 0;
                    if cl(count) == categorical(1)
                        inc = 1 * error(count);
                    end
                    if cl(count) == categorical(2)
                        inc = 2 * error(count);
                    end
                    if inc > 0 && error(count) < 0.2
                        %result(i+widh,j+widh,2) = 255; %result(i+widh,j+widh,2) + inc;
                        % add to gauss fit stack
                        gauss_fit_stack(gauss_fit_counter,:) = [jj+widh, ii+widh];
                        gauss_fit_counter = gauss_fit_counter + 1;
                    end
                    count = count + 1;
                end
                %fprintf("\t\t" + num2str((i/(siz-wid)) * 100) + "%%\n");
            end
            
            % now do a gauss fit
            fitted_spots = fit_spots_fast(double(test_tif), std_dev, double(gauss_fit_stack));
        end

        % normalize results so the highest matrix entry is 255
        mmin = min(result(:));
        mmax = max(result(:));
        result = (result-mmin) ./ (mmax-mmin);
        
        % now write correct points?
        c = xml2struct('virus_snr7_dens_mid.xml');
        
        length = size(c.root.TrackContestISBI2012.detection, 2);
        
        for ii=1:length
            det = c.root.TrackContestISBI2012.detection(ii);
            x = str2double(det{1}.Attributes.x);
            y = str2double(det{1}.Attributes.y);
            z = str2double(det{1}.Attributes.z);
            if z > 2 && z < 8
                % x and y are switched in image coordinates
                yc = floor(y + 0.5) + 1;
                xc = floor(x + 0.5) + 1;
                result(yc*scal-scal+1:yc*scal, xc*scal-scal+1:xc*scal, 1) = 255;
            end
        end
        
        if fitted_spots
            for ii=1:size(fitted_spots,1)
                
                % fitted new points
                xc = floor(fitted_spots(ii,1) + 0.5);
                yc = floor(fitted_spots(ii,2) + 0.5);
                
                % unfitted old points
                xold = gauss_fit_stack(ii,1);
                yold = gauss_fit_stack(ii,2);
                
                % if the fit was successful (not -1), draw a line from
                % unfitted to fitted point
                if xc > 0 && yc > 0
                    xmat = [xc*scal-scal/2 xold*scal-scal/2];
                    ymat = [yc*scal-scal/2 yold*scal-scal/2];
                    nPoints = scal * max(abs(diff(xmat)), abs(diff(ymat)))+1;  % Number of points in line
                    rIndex = round(linspace(ymat(1), ymat(2), nPoints));  % Row indices
                    cIndex = round(linspace(xmat(1), xmat(2), nPoints));  % Column indices
                    index = sub2ind(size(result), rIndex, cIndex);     % Linear indices
                    for elem=1:numel(rIndex)
                        result(rIndex(elem), cIndex(elem), 2) = 255;
                    end
                    result(yc*scal-scal+1:yc*scal, xc*scal-scal+1:xc*scal, 2) = 255;
                end
                
                % draw the unfitted point in blue for comparison
                result(yold*scal-scal+1:yold*scal, xold*scal-scal+1:xold*scal, 3) = 255;
            end
        end
        
        % turn into image
        imwrite(result, name + "_d" + num2str(std_dev) + ".tif")
    end
    return
end
