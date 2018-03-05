clear, clc

load('saliencyseg_J.mat');
load('order.mat');

result = zeros(50, 1);
for ires = 1:50
   place = order(ires);
   data = raw_ev{place};
   result(ires) = mean(data);
end

disp(mean(result));

% load('saliencyseg_J.mat');
% cla_dir = 'F:\dataset\DAVIS\Annotations\480p\';
% cla_set = dir(cla_dir);
% cla_set = cla_set(3:end);
% 
% order = zeros(50, 1);
% db_seq_list = db_seqs();
% 
% for icla = 1:length(cla_set)
%     cla_name = cla_set(icla).name;
%     disp(cla_name);
%     place = search_str(db_seq_list, cla_name);
%     order(icla) = place;
%     data = raw_ev{place};
%     disp(length(data));
% end
% 
% 
% function place = search_str(seq_all, s_cat)
% 
% for iseq = 1:length(seq_all)
%     str = seq_all{iseq};
%     if strcmp(str, s_cat)
%         break;
%     end
% end
% place = iseq;
% 
% end
