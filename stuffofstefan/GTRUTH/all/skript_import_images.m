path = ('C:\Eigene Dokumente\CSE UUlm\4_Projekt\PartChallengeData\virus\VIRUS');
data = "VIRUS snr 7 density mid";

for i = 1:100
    for k = 1:10
        name = strcat(data," t",sprintf('%03d',i-1)," z",sprintf('%02d',k-1),".tif");
        pic = uint8(imread(strcat(path,"\",data,"\",name)));
        target = ('C:\Eigene Dokumente\CSE UUlm\4_Projekt\neuroproject\stuffofstefan\GTRUTH\all\images\cat12\');
        imwrite(pic,strcat(target,"cat12_",sprintf('%03d',i-1),"z",sprintf('%02d',k-1),".tif"),'tif');
    end
end