xdata1 = 1:56;

im = double(imread('C:\Users\YangLe\Desktop\3-21\Figure3\data\salmap\cows00027.png'));
imS = imresize(im, [56, 56], 'bilinear');
imS = 255 - imS;
zdata1 = fliplr(imS);

figure1 = figure;

% Create axes
axes1 = axes('Visible','off','Parent',figure1);
view(axes1,[-162.5 80]);
grid(axes1,'on');
hold(axes1,'on');

% Create surf
surf(xdata1,xdata1,zdata1,'Parent',axes1);