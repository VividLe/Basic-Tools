function mask_shift = MoveMask(mask_fore, mask)
%

[xf_min,xf_max,yf_min,yf_max] = getBbox(mask_fore);
[x_min,x_max,y_min,y_max] = getBbox(mask);
f_crop = mask_fore(xf_min:xf_max,yf_min:yf_max);
re_crop = imresize(f_crop,[x_max-x_min+1,y_max-y_min+1], 'bilinear');
mask_shift = mask;
mask_shift(x_min:x_max,y_min:y_max) = re_crop;


end

