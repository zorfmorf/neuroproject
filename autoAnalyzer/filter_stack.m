    function [denoised,oribgrnd,meQ,sdQ] = filter_stack(original,ROI,lObject)
        
        %Initialise Arrays used in for-loops  
        emptyCellArray = cell(1,length(original));
        denoised = emptyCellArray;
        oribgrnd = emptyCellArray;
        background = emptyCellArray;
        meanvalue = emptyCellArray;
        allmean = 0;
                                                              
        for k = 1:length(denoised)
            meanvalue{k} = mean(original{k}(:)); %Array containing mean values of each frame
            allmean = allmean + meanvalue{k}; %Sum of all mean values
        end
        
        allmean = allmean / length(original); %Mean value of all frames
        
        parfor j = 1:length(original) %Iterate through frames
            oribgrnd{j} = double(original{j}) * allmean / meanvalue{j}; %Multiply each pixel with a factor so that mean values of all frames are equal
            background{j} = imopen(oribgrnd{j},strel('square',10)); %Creates an image of 10x10 squares which is later used for background subtraction
            oribgrnd{j} = oribgrnd{j} - background{j}; %Image where the background is somewhat more equally bright
        end
        
%         if useBandpass == 1
            parfor j = 1:length(original) %Iterate through frames                
                denoised{j} = bpass(original{j}, 1, lObject); %Create filtered Image using a bandpass filter
            end
%         elseif useBandpass == 0
%             parfor j = 1:length(original) %Iterate through frames
%                 denoised{j} = imopen(oribgrnd{j},strel('square',2)); %Dilute pixels (Former version of denoised image)
%             end
%         end
        
        
        meQ = 1;
        sdQ = 1;
        maxQ = 1;
        
        for j = 1:length(original) %Interate through frames
            Q = denoised{j}(logical(ROI)); %List of all pixel values in ROI
            meQ = ((j-1) * meQ + median(Q(Q>0))) / j; % Average median of all frames
            sdQ = ((j-1) * sdQ + std(Q)) / j; % Average standard deviation of all frames
            maxQ = ((j-1) * maxQ + max(Q)) / j;% Average maximum of all frames
        end
        
    end
