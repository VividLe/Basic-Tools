clear, clc

img_rp = 'C:\Users\YangLe\Desktop\7-19\TCL\result\TCL\';
vidObj=VideoWriter('mask.avi');

vidObj.FrameRate = 8;
open(vidObj);

img_set = dir([img_rp, '*.png']);
for iimg = 1:length(img_set)
    img_name = img_set(iimg).name;
    disp(img_name);
    mask = imread([img_rp, img_name]);
    mask = imresize(mask, [1280, 720], 'bilinear');
    writeVideo(vidObj,mask);
    
end
close(vidObj);




% for i=1:100
%       fname=strcat('img',num2str(i,'%.5d'),'.png');
%       adata=imread(fname);
%       writeVideo(vidObj,adata);
%  end
% close(vidObj);

