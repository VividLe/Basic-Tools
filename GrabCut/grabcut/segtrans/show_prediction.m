function show_prediction(prediction,image,mask)

n = nargin();
assert(n>=1);

clf();

subplot(1,n,n-0);
imagesc(prediction);
axis image off;
title('prediction');

if exist('image','var')
	subplot(1,n,n-1);
	imagesc(image);
	axis image off;
	title('image');

	if exist('mask','var')
		subplot(1,n,n-2);
		imagesc(mask);
		axis image off;
		title('transferred mask');
	end;

end;

