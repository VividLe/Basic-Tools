clear
clc

addpath(genpath('./grabcut'));

maxIterations = 5;
%the threshold for average lightless of foreground point
pointTh = 80;

oriFolRp = '/disk2/donzhang/result/sepSalMap/';
resFolRp = '/disk2/donzhang/result/grabcutRefine/';
vidImgRp='/disk2/donzhang/shareForZd/DAVIS/Image/';
folSet = dir(oriFolRp);
folSet = folSet(3:length(folSet));

for ivid=1:length(folSet)
    folName = folSet(ivid).name;
    oriClaRp = [oriFolRp, folName, '/'];
    resClaRp = [resFolRp, folName, '/'];
    calSet = dir(oriClaRp);
    calSet = calSet(3:end);
    
    for icla = 1:length(calSet)
        claName = calSet(icla).name;
        oriImgRp = [oriClaRp, claName, '/'];
        resImgRp = [resClaRp, claName, '/'];
        colorImgRp = [vidImgRp, claName, '/'];
        if ~exist(resImgRp, 'dir')
            mkdir(resImgRp);
        end
        
        imgSet = dir([oriImgRp, '*.png']);
        parfor iimg = 1:length(imgSet)
            fprintf('%d  ', iimg);
            imgName = imgSet(iimg).name;
            if exist([resImgRp, imgName], 'file')
                continue;
            end
            img = imread([colorImgRp, imgName]);
            oriMask = imread([oriImgRp, imgName]);
            mask = double(oriMask) / 255;
            
            threshold = graythresh(mask);
            maskwri=mask;
            maskwri(maskwri<threshold)=0;
            maskwri(maskwri>threshold)=255;
            
            forePoint = find(maskwri > 0);
            backPoint = find(maskwri == 0);
            numForePoint = length(forePoint);
            numBackPoint = length(backPoint);
            
            if (numForePoint < pointTh) || (numBackPoint < pointTh)
                seg=maskwri;
            else
                seg = st_segment(img,mask,threshold,maxIterations);
            end           
            
            seg = double(seg) * 255;
            seg = uint8(seg);
            imwrite(seg, [resImgRp, imgName], 'png');
            
        end       
        
    end  
    
end