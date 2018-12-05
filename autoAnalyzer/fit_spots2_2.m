
function spots_new = fit_spots2_2(image, method, params, spots)

    %% FIT_SPOTS Returns fitting parameters of spots in the input images
    %Input: image cell array, method('gaussian'), 
    %Output:          fitParams(1) = x-centre of 2D-Gaussian
    %                 fitParams(2) = y-centre of 2D-Gaussian
    %                 fitParams(3) = intensity of 2D-Gaussian
    %                 fitParams(4) = Variance in x-direction
    %                 fitParams(5) = Variance in y-direction
    %                 fitParams(6) = Offset of 2D-Gaussian (Darkest pixel in spot image)
    %                 fitParams(7) = Offset corrected intensity: (Sum of all pixels) - (offset*number of pixels)
    %                 fitParams(8) = Fitting error?
    %                 fitParams(9) = Orientation of 2D-Gaussian (Angle);

    pix       = (params.windowSize - 1)/2;         %Determines size of spot image
    spots_new = cell(1,length(image));

    for m=1:length(image)    
        curImage = image{m};
        curSpots   = [spots{m}, zeros(size(spots{m}, 1), 7)]; % add columns to store fitting parameters
        num_spots = size(curSpots, 1);
        i = 1;
        
        while (i < num_spots + 1)
            %-----------Extract spot from image------------------
            x           = round(curSpots(i, 1));
            y           = round(curSpots(i, 2));
            xMin        = max(x - pix, 1);
            xMax        = min(x + pix, size(curImage, 2));
            yMin        = max(y - pix, 1);
            yMax        = min(y + pix, size(curImage, 1));
            spotImage   = curImage(yMin:yMax, xMin:xMax);
            
%                              figure('Name','SpotImage','NumberTitle','off'),
%                              imshow(spotImage,'DisplayRange',[0 max(max(spotImage))],'InitialMagnification','fit') %Show spot if desired
            
            %---------Initial estimates of fitting parameters----------
            offset = min(spotImage(:));
            initialFitParams = [ ...
                sum(spotImage(:)) - offset*(params.windowSize)^2, ... intensity %Sum of pixels minus offset
                curSpots(i, 1) - xMin,                     ... x (Centre of image)
                curSpots(i, 2) - yMin,                     ... y (Centre of image)
                1.2,                                    ... x width (x-variance)
                1.2,                                    ... y width (y-variance)
                offset                                  ... offset(Background)
                params.angle                            ... angle (Orientiation of 2D-Gaussian)
                ];
            
            options                     = optimset('Algorithm', 'levenberg-marquardt','Display','off');
            %         global catchcount; %Can be used to count errors in fitting process -> enable in auto_analyzer
            
            try
                %----Run optimizer-------------
                [fitParams,fval,~,exitflag] = lsqcurvefit(@fitting, initialFitParams,size(spotImage), spotImage, [], [], options);
                %----check if fit succeded (exitflag), check if variance in x -and y-direction is within accepted values and check if
                %the fitted spot lies within the region (sometimes fitting process leads to strange negative xMin/xMax outputs
                if exitflag && fitParams(4) > params.minWidth && fitParams(4) < params.maxWidth && fitParams(5) > params.minWidth...
                        && fitParams(5) < params.maxWidth && fitParams(2) > 0 && fitParams(3) > 0
                    
                    
                    %----------store fitted parameters-----------
                    intensity    = fitParams(1);
                    fitParams(1) = xMin + fitParams(2) - 1;
                    fitParams(2) = yMin + fitParams(3) - 1;
                    fitParams(3) = intensity;
                    fitParams(9) = fitParams(7);
                    fitParams(7) = sum(spotImage(:)) - fitParams(6)*(2*pix+1)^2;
                    fitParams(8) = fval;
                    if (round(fitParams(1)) > 0 && round(fitParams(2)) > 0 && round(fitParams(2)) < size(curImage,1) && round(fitParams(1)) < size(curImage,2))
                        fitParams(9) = curImage(round(fitParams(2)),round(fitParams(1)));
                    end
                    
                    curSpots(i,:)   = fitParams;
                    %             end
                    %             if (~exitflag)
                else %----if fit not successfull or variance too low/too high -> delete spot
                    curSpots(i,:) = [];
                    i = i-1;
                end
                
            catch
                curSpots(i,:) = [];
                i = i-1;
                %             catchcount = catchcount + 1; %Can be used to count errors in fitting process -> enable also in auto_analyzer
            end
            i = i+1;
            num_spots = size(curSpots, 1);
        end
        spots_new{m} = curSpots;
    end
end
