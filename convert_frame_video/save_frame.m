clear, clc

vid_path = '/home/yangle/CVPR2018/hls/data/hls.mp4';
exist_img_path = '/home/yangle/CVPR2018/hls/result/images/';
whole_img_path = '/home/yangle/CVPR2018/hls/data/whole_frames/';

if ~exist(whole_img_path, 'dir')
    mkdir(whole_img_path);
end

addpath(genpath('/home/yangle/CVPR2018/hls/code/'));

vid = VideoReader(vid_path);

% box_data = loadjson(json_file_path);
load('box_data.mat');
name_set = fieldnames(box_data);

% the first 126 frames are lost
lost_num = 126;
for ijs = 127:length(name_set)
    disp(ijs);
    %read image
    fra_order = ijs - lost_num;
    frame = read(vid, fra_order);
    order = num2str(fra_order, '%07d');
    save_name = [order, '.png'];
    
    exist_file_path = [exist_img_path, save_name];
    res_file_path = [whole_img_path, save_name];
    if exist(exist_file_path, 'file')
        disp('cope file');
        copyfile(exist_file_path, res_file_path);
    end
    
    imwrite(frame, res_file_path, 'png');
    
end


