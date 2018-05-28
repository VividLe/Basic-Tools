clear
clc

addpath(genpath('./grabcut'));

maxIterations = 5;
%the threshold for average lightless of foreground point
pointTh = 500;

oriClaRp = '/home/yangle/PAMI/dataset/SEA/';
resClaRp = '/home/yangle/PAMI/dataset/SEAGb/';
vidImgRp='/home/yangle/BasicDataset/dataset/DAVIS/mImage/';
calSet = dir(oriClaRp);
calSet = calSet(3:end);
    
for icla = 1:length(calSet)
    claName = calSet(icla).name;
    oriImgRp = [oriClaRp, claName, '/'];
    resImgRp = [resClaRp, claName, '/'];
    if ~exist(resImgRp, 'dir')
        mkdir(resImgRp);
    end

    imgSet = dir([oriImgRp, '*.png']);
    parfor iimg = 1:length(imgSet)
        fprintf('%d  ', iimg);
        imgName = imgSet(iimg).name;
%         if exist([resImgRp, imgName], 'file')
%             continue;
%         end
        img = imread([vidImgRp, imgName]);
        oriMask = imread([oriImgRp, imgName]);
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
        imwrite(seg, [resImgRp, imgName], 'png');

    end       

end  