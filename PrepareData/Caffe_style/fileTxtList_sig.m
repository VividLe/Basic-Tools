clear
clc

txtPath = '/home/yangle/BasicDataset/dataset/DAVIS/nameList.txt';
imgRp = '/home/yangle/BasicDataset/dataset/DAVIS/mImage/';

fid=fopen(txtPath,'w+');
fclose(fid);
imgSet = dir([imgRp, '*.png']);
imgnum=length(imgSet);
fid = fopen(txtPath,'w');
while imgnum    
    order=randi([1,imgnum]);
    imgname=imgSet(order).name;
    file_name=[imgname,' 0'];
    fprintf(fid, '%s\r\n', file_name);
    imgSet(order)=[];
    imgnum=length(imgSet);
end
fclose(fid);


