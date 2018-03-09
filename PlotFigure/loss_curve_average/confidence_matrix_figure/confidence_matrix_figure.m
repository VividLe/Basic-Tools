clear, clc

edge = 10;
width = 6;
height = 12;

fig_box = zeros(width * edge, height * edge);
for ihei = 1:height
    data = rand(1:width);
    data = data ./ sum(data);
    data = round(data * 255);
    
    for jwid = 1:width
        fig_box((jwid-1)*edge+1:jwid*edge, (ihei-1)*edge+1:ihei*edge) = data(jwid);        
    end
    
end

fig_box = uint8(fig_box);

figure, imshow(fig_box);




