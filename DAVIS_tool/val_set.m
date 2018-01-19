% this script document the validation sequence order in the origional
% DAVIS2016 dataset. The whole_data should be ranked in sequence: bear,
% blackswan, ...

% method 1
a = [3, 7, 11, 13, 14, 17, 20, 21, 23, 27, 28, 29, 35, 38, 39, 42, 43, 45, 47, 49];
order = (a -1)';
val_data = whole_data(order);
disp(mean(val_data));


% method 2
load('order.mat');
