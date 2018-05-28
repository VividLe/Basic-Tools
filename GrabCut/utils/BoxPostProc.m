function seg = BoxPostProc(seg,x_min,x_max,y_min,y_max)
%

[rows, cols] = size(seg);
if x_min>1
    seg(1:x_min-1,:) = 0;
end
if x_max<rows
    seg(x_max+1:rows,:) = 0;
end
if y_min>1
    seg(:,1:y_min-1) = 0;
end
if y_max<cols
    seg(:,y_max+1:cols) = 0;
end

end

