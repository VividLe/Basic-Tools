function unary_map = GaussBlur(mask_shift, x_min,x_max,y_min,y_max)
%
mask_shift = double(mask_shift) / 255;
GausKernl = fspecial('gaussian', [50, 50], 10);
unary_map = imfilter(mask_shift,GausKernl,'same');

[rows, cols] = size(mask_shift);
noise_point = 0.1*rand([rows, cols]);
unary_map = unary_map + noise_point;
unary_map(unary_map>1) = 1;

end

