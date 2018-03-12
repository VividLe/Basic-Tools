% visualize the DAVIS segmentation dataset
clear, clc

vidsegrp='.\seg\';
vidimgrp='.\img\';
vidshowimgrp='.\show\';

%half the line width
hl = 5;

if ~exist(vidshowimgrp,'dir')
    mkdir(vidshowimgrp);
end

segset=dir([vidsegrp,'*.png']);
for iimg=1:length(segset)
    disp(iimg);
    img_name=segset(iimg).name;

    seg=imread([vidsegrp,img_name]);
    seg(seg<=30) = 0;
    seg(seg>30) = 255;
    
    im=imread([vidimgrp,img_name]);

    [rowsS,colsS]=size(seg);
    [rowsI,colsI,~]=size(im);
    if rowsS~=rowsI || colsS~=colsI
        seg=imresize(seg,[rowsI,colsI],'bilinear');
    end
    if size(seg,3) > 2
    seg = rgb2gray(seg);
    end

    %set value for each pixel
    [x,y]=find(seg == 255);
    for ipix=1:length(x)            
        im(x(ipix),y(ipix),1) = 200;
        im(x(ipix),y(ipix),2) = im(x(ipix),y(ipix),2) * 0.5;
        im(x(ipix),y(ipix),3) = im(x(ipix),y(ipix),3) * 0.5;
    end
    
    %color for edge
    SegEdge=edge(seg,'canny');
    [x,y]=find(SegEdge==1);
    
    for ie = 1:length(y)
        if (x(ie)-hl)<1 || (x(ie)+hl) > 480
            continue;
        end
        im(x(ie)-hl:x(ie)+hl, y(ie),:) = 0;
        im(x(ie)-hl:x(ie)+hl, y(ie),2) = 255;
    end

    imwrite(im,[vidshowimgrp,img_name],'png');

end  


