clear
clc

oriClaImgRp = '/disk3/yangle/GrabCut1/oriDataset/';
resClaImgRp = '/disk3/yangle/GrabCut1/sepDataset';
claSet = dir(oriClaImgRp);
claSet = claSet(3:end);

for icla = 1:length(claSet)
    claName = claSet(icla).name;
    imgOriRp = [oriClaImgRp, claName, '/'];
    claResRp = [resClaImgRp, claName, '/'];

    imgSet = dir([imgOriRp, '*.png']);
    parfor iimg = 1:length(imgSet)
        imgName = imgSet(iimg).name;    
        claName = imgName(1:end-9);
        imgResRp = [claResRp, claName, '/'];
        if ~exist(imgResRp, 'dir')
            mkdir(imgResRp);
        end
        resImgName = imgName(end-8:end);
        copyfile([imgOriRp, imgName], [imgResRp, resImgName]);    
    end
    
end


