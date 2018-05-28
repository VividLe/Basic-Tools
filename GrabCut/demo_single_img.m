clear, clc

maxIterations = 5;
img = imread('');
mask = imread('');
mask = double(mask) / 255;
threshold = graythresh(mask);

seg = st_segment(img,mask,threshold,maxIterations);

