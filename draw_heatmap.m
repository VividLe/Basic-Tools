clear, clc

salmap = imread('mallard-fly00046.png');
A = double(salmap) / 255;
 colormap('hsv');   % set colormap
 imagesc(A), axis off;        % draw image and scale colormap to values range
%  colorbar;          % show color scale

%then edit color map
%(1)[0,114,189]  (2)[255, 255, 255]  (3)[255, 0, 0]