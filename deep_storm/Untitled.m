lbstack_gs = uint8(zeros(32,32,20000));
for i = 1:20000
    lbstack_gs(:,:,i) = uint8(conv2(lbstack(:,:,i),GKernel,'same'));
end