function box = getBbox(img)


[x, y] = find(img == 255);
if isempty(x) || isempty(y)
    x_min = 0;
    x_max = 0;
    y_min = 0;
    y_max = 0; 
    box = [x_min,x_max,y_min,y_max];
    return;
end

x_min = min(x);
x_max = max(x);
y_min = min(y);
y_max = max(y); 

box = [x_min,x_max,y_min,y_max];

end

