k = 14480;
figure(1)
hold on
for i = k+1:k+8*5
    subplot(8,5,i-k)
    imshow(lbstack_gs(:,:,i));

    title(num2str(i));
end
hold off

figure(2)
hold on
for i = k+1:k+8*5
    subplot(8,5,i-k)
    imshow(lbstack(:,:,i));

    title(num2str(i));
end
hold off