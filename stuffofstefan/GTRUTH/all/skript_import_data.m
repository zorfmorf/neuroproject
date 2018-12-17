clear all
[~, spots_true] = import_xml_PTCdata...
('C:\Eigene Dokumente\CSE UUlm\4_Projekt\PartChallengeData\ground_truth\ground_truth\VIRUS snr 7 density mid.xml');
gtruth_cat12 = spots_true;
save("gtruth_cat12.mat","gtruth_cat12");
clear all