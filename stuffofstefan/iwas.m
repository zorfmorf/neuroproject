maptest = map;
for i = 1:512
    for j = 1:512
        if map(i,j) < 200
            maptest(i,j) = 0;
        end
    end
end