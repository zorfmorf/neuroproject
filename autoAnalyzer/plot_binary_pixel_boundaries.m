function plot_binary_pixel_boundaries(image, threshold, color)

binary = image >= threshold;    

for i=1:size(binary,1) %Zeilen
    for j=1:size(binary,2) %Spalten
        if binary(i,j) == 1
            if j == 1; %Left Neighbour
                plot([j-0.5, j-0.5], [i-0.5, i+0.5],color,'LineWidth', 2);
            elseif j ~= 1 && binary(i,j-1) == 0;
                plot([j-0.5, j-0.5], [i-0.5, i+0.5],color,'LineWidth', 2);
            end
            
            if j == size(binary,2); %Right Neighbour
                plot([j+0.5, j+0.5], [i-0.5, i+0.5],color,'LineWidth', 2);
            elseif binary(i,j+1) == 0;
                plot([j+0.5, j+0.5], [i-0.5, i+0.5],color,'LineWidth', 2);
            end
            
            if i == 1; %Upper neighbour
                plot([j-0.5, j+0.5], [i-0.5, i-0.5],color,'LineWidth', 2);
            elseif binary(i-1,j) == 0;
                plot([j-0.5, j+0.5], [i-0.5, i-0.5],color,'LineWidth', 2);
            end
            
            if i == size(binary,1); %Lower neighbour
                plot([j-0.5, j+0.5], [i+0.5, i+0.5],color,'LineWidth', 2);
            elseif binary(i+1,j) == 0;
                plot([j-0.5, j+0.5], [i+0.5, i+0.5],color,'LineWidth', 2);
            end
        end
    end
end








