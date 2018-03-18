clc, clear

im1 = double(imread('00000.png'));
im2 = double(imread('00001.png'));
flow = mex_LDOF(im1,im2);
vx = flow(:,:,1);
vy = flow(:,:,2);
save('-v7', 'op00000To00001.mat','vx','vy');


