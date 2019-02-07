
% path to the network file
names = [ 
            "012_simple_snr247_z1" "012_simple_snr47_z1" "012_simple_snr247_z3" "012_simple_snr47_z3" "012_simple_snr247_z5" "012_simple_snr47_z5" "center_snr47" "zeroedge_snr47" "zeroedge_snr247"
        ];
    
% test_tif = imread("test_im512.tif");

for id = 1:numel(names)
    id = 7;
    name = names(id);
    load("../trained networks/" + name + ".mat");
    test_net = net;

    load("../GTRUTH/sliding_window/16x16/" + name + "/test_set/imagestack.mat");
    test_images = imagestack;
    load("../GTRUTH/sliding_window/16x16/" + name + "/test_set/labelstack.mat");
    test_labels = labelstack;

    test_size = size(test_images);

    sumCorrect = 0;
    sumMax = test_size(4);
    
    err_array = zeros(1000,3);
    correct_array = zeros(1000,3);
    
    jaccardMatr = zeros(2,2);

    if 1 < 2
        k = 1;
        l = 1;
        for i=1:sumMax
            img = test_images(:,:,1,i);
            [~, err] = classify(test_net,img);
            if err(2) > 0.6 
                outclass = categorical(1);
            else
                outclass = categorical(0);
            end
            if outclass == categorical(test_labels(i))
                if outclass == categorical(1)
                    jaccardMatr(2,2) = jaccardMatr(2,2)+1;
                else 
                    jaccardMatr(1,1) = jaccardMatr(1,1)+1;
                end
                sumCorrect = sumCorrect + 1;
%                 correct_array(l,1:2) = err;
%                 correct_array(l,3) = i;
%                 l = l+1;
%                 if l == 1001
%                     break
%                 end
            else
                err_array(k,1:2) = err;
                err_array(k,3) = i;
                k = k+1;
                if outclass == categorical(1)
                    jaccardMatr(2,1) = jaccardMatr(2,1)+1;
                else 
                    jaccardMatr(1,2) = jaccardMatr(1,2)+1;
                end
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
