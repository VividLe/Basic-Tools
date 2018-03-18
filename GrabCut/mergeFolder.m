clear
clc

claRp = '/home/yangle/BasicDataset/dataset/DAVIS/Image/';
resRp = '/home/yangle/BasicDataset/dataset/DAVIS/mImage/';
if ~exist(resRp, 'dir')
    mkdir(resRp);
end

claSet = dir(claRp);
claSet = claSet(3:end);
for icla=1:length(claSet)
    claName = claSet(icla).name;
    imgRp = [claRp,claName,'/'];
    imgSet = dir([imgRp, '*.png']);
    for iimg = 1:length(imgSet)
        imgName = imgSet(iimg).name;
        imgNewName = [claName,imgName];
        copyfile([imgRp, imgName], [resRp,imgNewName]);        
    end    
end
