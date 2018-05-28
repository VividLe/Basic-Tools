function [x_min,x_max,y_min,y_max] = enlarge_box(box, factor)
%
xmin = box(1);
xmax = box(2);
ymin = box(3);
ymax = box(4);
half_hei = round((xmax-xmin) * factor * 0.5);
half_wid = round((ymax-ymin) * factor * 0.5);
x_min = xmin - half_hei;
x_max = xmax + half_hei;
y_min = ymin - half_wid;
y_max = ymax + half_wid;

end


