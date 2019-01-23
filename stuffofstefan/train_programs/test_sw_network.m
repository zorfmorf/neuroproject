
% path to the network file
names = [ 
            "012_simple_snr247_z1" "012_simple_snr47_z1" "012_simple_snr247_z3" "012_simple_snr47_z3" "012_simple_snr247_z5" "012_simple_snr47_z5" "center_snr47" "zeroedge_snr47" "zeroedge_snr247"
        ];
    
test_tif = imread("test_im512.tif");

for id = 1:numel(names)
    name = names(id);
    load("trained networks/" + name + ".mat");
    test_net = net;

    load("GTRUTH/sliding_window/" + name + "/test_set/imagestack.mat");
    test_images = imagestack;
    load("GTRUTH/sliding_window/" + name + "/test_set/labelstack.mat");
    test_labels = labelstack;

    test_size = size(test_images);

    sumCorrect = 0;
    sumMax = test_size(4);

    if 1 < 0
        for i=1:sumMax
            img = test_images(:,:,1,i);
            if classify(net,img) == categorical(test_labels(i))
                sumCorrect = sumCorrect + 1;
            end
        end
    end

    disp(name + " is " + num2str(sumCorrect / sumMax * 100) + "% correct");
    
    if 1 == 1
        % now slide window through image and add all results together
        siz = 512; % size of test image
        wid = 16; % width of neuronal network input image
        widh = floor(wid/2)-1;
        result = zeros(siz,siz);
        for i=1:siz-wid
            for j=1:siz-wid
                img = test_tif(i:i+wid-1,j:j+wid-1);
                inc = 0;
                cl = classify(net,img);
                if cl == categorical(1)
                    inc = 1;
                end
                if cl == categorical(2)
                    inc = 2;
                end
                if inc > 0
                    result(i+widh,j+widh) = result(i+widh,j+widh) + inc;
                end
            end
        end
        % normalize results so the highest matrix entry is 255
        mmin = min(result(:));
        mmax = max(result(:));
        result = (result-mmin) ./ (mmax-mmin);
        % turn into image
        imwrite(result, name+".tif")
    end
    break
end
