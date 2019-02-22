clc;
clear;

% log file of caffe model
logName = 'ROS_train_doc.txt';

fid = fopen(logName, 'r');
fid_loss = fopen('output_loss.txt', 'w');

order = 1;
tline = fgetl(fid);

while ischar(tline)
    % Then find the loss line
    k1 = strfind(tline, 'Iteration');
    if (k1)
       k2 = strfind(tline, 'loss');
       if (k2)
           indexStart = k2 + 7;
           indexEnd = size(tline);
           str1 = tline(indexStart:indexEnd(2));
           y_loss(order) = str2double(str1);
           indexStart = k1 + 10;
           indexEnd = strfind(tline, ',') - 1;
           str2 = tline(indexStart:indexEnd);
           x_index(order) = str2double(str2);
           res_str1 = strcat(str2, '/', str1);
           fprintf(fid_loss, '%s\r\n', res_str1);
           order = order + 1;
       end
    end
    
    tline = fgetl(fid);
end

fclose(fid);
fclose(fid_loss);

plot(x_index, y_loss);

% x2 = x_index(700:end);
% y2 = y_loss(700:end);
% plot(x2, y2)