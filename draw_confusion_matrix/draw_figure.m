addpath ConfusionMatrices

clear, clc

data = xlsread('data.xlsx');
name_class = {'°ËÏÉöøÓã', '°ßÂíÓã', 'ĞÂÔÂ½õÓã', 'ÎÆ¸¹²æ±Ç÷ƒ', '¶¹ÄïÓã', 'ò¢ÕëÓã'};
class_number = 6;
draw_cm(data,name_class,class_number);
