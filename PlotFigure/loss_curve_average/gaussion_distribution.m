% visualize the multiple peaks gaussion distribution
% please adjust the expection, variation, and maximum value
close all;  clear  clc  

x=-4:.1:4;  
y=x;   
[x, y] = meshgrid(x,y);

z1 = exp(-x.^2 -y.^2);
z2 = 0.5 * exp(-(x-1.5).^2 - (y+2.0).^2);

z = z1 + z2;
mesh(x,y,z);

