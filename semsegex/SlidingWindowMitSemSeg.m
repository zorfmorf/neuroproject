

% Wähle ein Netz
% Wähle ein Bild
% Teile das Bild in kleinere Bilder (32x32)
% Addiere die Ergebnisse des Netzes aufeinander
% -> Eine Art Höhenkarte entsteht

load("trained networks\net_w2_r1_snr247.mat");
net = net_w2_r1_247;

% Choose category
cat = 10;

% Choose image
image = imread(strcat("GTRUTH\all\images\cat",num2str(cat),"\cat",...
    num2str(cat),"_057z05.tif"));

% dimension of image
dim = 512;

% dimension of cutout for network
d = 32;

% Create Hight-map
map = zeros(512,512);

for i = 1:2:dim-d+1
    disp(strcat("(",num2str(i),")"));
    for j = 1:2:dim-d+1
        intermediate = semanticseg(image(i:i+d-1,j:j+d-1),net);
        result = (intermediate == "o");
        map(i:i+d-1,j:j+d-1) = map(i:i+d-1,j:j+d-1) + result;
    end
end

% Show results
figure(1)
hold on
subplot(1,2,1)
imshow(image)
subplot(1,2,2)
imshow(uint8(map))
hold off
