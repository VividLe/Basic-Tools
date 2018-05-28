%{
Purpose:
  Refine saliency map with GrabCut method. We suppose the input saliency
  map is not fully believable, thus, some random noise is added to better
  difscover the object region.
Effect:
  Ordinary
%}
clear, clc

addpath(genpath('./'))
threshold = 0.01;
maxIterations = 5;

img = imread('data/image.jpg');
comask_rp = 'data/comask.png';
salmap_rp = 'data/salmap.png';
res_rp = 'data/';

comask = imread(comask_rp);
salmap = imread(salmap_rp);

box = getBbox(comask);
factor=0.2;
[x_min,x_max,y_min,y_max] = enlarge_box(box, factor);
[rows, cols] = size(comask);
if x_min < 1
    x_min = 1;
end
if x_max > rows
    x_max = rows;
end
if y_min < 1
    y_min = 1;
end
if y_max > cols
   y_max = cols; 
end


% saliency map
salmap = rgb2gray(salmap);
salmap = imresize(salmap, size(comask), 'bilinear');
% set zero
salmap(1:x_min,:) = 0;
salmap(x_max:rows, :) = 0;
salmap(:,1:y_min) = 0;
salmap(:,y_max:cols) = 0;

% noisy map
noise_point = 0.1*rand([rows, cols]);
noise_point(1:x_min,:) = 0;
noise_point(x_max:rows, :) = 0;
noise_point(:,1:y_min) = 0;
noise_point(:,y_max:cols) = 0;

saliency_map = 0.8 * double(salmap) / 255;
GausKernl = fspecial('gaussian', [50, 50], 10);
unary_map = imfilter(saliency_map,GausKernl,'same');
potential_map = noise_point + unary_map;
potential_map(potential_map > 1) = 1;

seg = st_segment(img,potential_map,threshold,maxIterations);
seg = uint8(255*double(seg));
imwrite(seg,[res_rp,'result.png'],'png');
