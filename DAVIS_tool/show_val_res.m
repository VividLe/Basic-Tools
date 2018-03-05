clear, clc

load('val_order.mat');
load('ROS_iter_11586_eval_all.mat');
% load('saliencyseg_T.mat');

data_comp = eval.F.decay;
data_val = zeros(20, 1);

for ival = 1:20
    place = order(ival);
%     data = raw_ev{place};
%     data_val(ival) = mean(data(2:end));
    data_val(ival) = data_comp(place);
end

disp(mean(data_val));
