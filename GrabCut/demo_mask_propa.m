clear, clc

clear, clc

addpath(genpath('./'));

img_rp = 'C:\Users\YangLe\Desktop\5-24\ZD\MaskPropa\image/';
mask_rp = 'C:\Users\YangLe\Desktop\5-24\ZD\MaskPropa\gt/';
res_rp = 'C:\Users\YangLe\Desktop\5-24\ZD\MaskPropa\mask/';
maxIterations = 5;


img_set = dir([img_rp, '*.png']);
img_name = img_set(1).name;
mask_fore = imread([mask_rp,img_name]);

for iimg = 1:length(img_set)
    disp(iimg);
    img_name = img_set(iimg).name;
    img = imread([img_rp,img_name]);
    mask = imread([mask_rp,img_name]);    

    [x_min,x_max,y_min,y_max] = getBbox(mask);
    if x_min*x_max*y_min*y_max==0
        continue;        
    end

    mask_shift = MoveMask(mask_fore, mask);
    unary_map = GaussBlur(mask_shift, x_min,x_max,y_min,y_max);    
    threshold = 0.01;
%     threshold = graythresh(unary_map);
    try 
        seg = st_segment(img,unary_map,threshold,maxIterations);
        SucSeg = true;
    catch
        SucSeg = false;
    end

    if ~SucSeg
        continue;
    end

    seg = uint8(255*double(seg));
    seg = BoxPostProc(seg,x_min,x_max,y_min,y_max);
    imwrite(seg,[res_rp,img_name],'png');
    mask_fore = seg;

end

