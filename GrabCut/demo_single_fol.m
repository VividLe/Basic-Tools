clear
clc

addpath(genpath('./grabcut'));

maxIterations = 5;
%the threshold for average lightless of foreground point
pointTh = 500;

img_rp = '/disk5/yangle/PAMI/dataset/DAVIS16/merge-images/mImage/';
mask_rp = '/disk5/yangle/PAMI/result/masks/bce_best_masks/';
res_rp = '/disk5/yangle/PAMI/result/masks/bce_best_masks_grab/';

mask_set = dir([mask_rp, '*.png']);
parfor iimg = 1:length(mask_set)
	fprintf('%d  ', iimg);
	mask_name = mask_set(iimg).name;
	
	img = imread([img_rp, mask_name]);
	oriMask = imread([mask_rp, mask_name]);
	mask = double(oriMask) / 255;

	threshold = graythresh(mask);
	maskwri=mask;
	maskwri(maskwri<=threshold)=0;
	maskwri(maskwri>threshold)=255;

	forePoint = find(maskwri > 0);
	backPoint = find(maskwri == 0);
	numForePoint = length(forePoint);
	numBackPoint = length(backPoint);

	if (numForePoint < pointTh) || (numBackPoint < pointTh)
		seg=maskwri;
	else
		try
			seg = st_segment(img,mask,threshold,maxIterations);
		catch
			seg=maskwri;
		end
	end

	seg = double(seg) * 255;
	seg = uint8(seg);
	imwrite(seg, [res_rp, mask_name], 'png');

end       
 