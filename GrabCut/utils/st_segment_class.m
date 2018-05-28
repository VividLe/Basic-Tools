function seg = st_segment_class(image,U_init,mask,mask2,maxIterations,wb)
seg = compute(image,U_init,mask,mask2,maxIterations,wb);

function seg = compute(image,U_init,mask,mask2,maxIterations,wb)
num_images=length(image);
seg =cell(1,num_images);
P =cell(1,num_images);
U_loc=cell(1,num_images);
fgk=cell(1,num_images);
bgk=cell(1,num_images);
for j=1:num_images
    image{j}= im2double(image{j});
    [P{j} Pk] = getPairwise(image{j});
    U_loc{j} = cat(3,U_init{j},1-U_init{j});
end
[fgm bgm] = initializeModel(image,mask,mask2);
for i = 1:maxIterations
    for j=1:num_images
        [fgk{j} bgk{j}] = assignComponents(image{j},fgm,bgm);
        U_app = getUnary_app(image{j},fgm,bgm,fgk{j},bgk{j});
        U = getUnary(wb,U_loc{j},U_app);
        [h,w,dummy]=size(image{j});
        [seg{j},dummy1,dummy2] = getSegmentation(P{j},U,w,h);
    end
    [fgm bgm] = learnModel(image,seg,fgm,bgm,fgk,bgk);
    display(['finished ',num2str(i/maxIterations*100),'%'])
end

function energy = getEnergy(A,T,labels)

energy = 0;
energy = energy + sum(T(labels==0,2));
energy = energy + sum(T(labels==1,1));
energy = energy + sum(sum(A(labels==0,labels==1)));

function [fg bg] = initializeModel(img,mask,mask2)
K = 5;
num_images=length(img);
fg_vec=[];
bg_vec=[];
for j=1:num_images
    img2 = reshape(img{j},[],3);
    fg_vec=[fg_vec;img2(mask{j},:)];
    bg_vec=[bg_vec;img2(mask2{j},:)];
end
fg = pdf_gm.fit_using_vectorquantisation(fg_vec,K);
bg = pdf_gm.fit_using_vectorquantisation(bg_vec,K);

function [fg bg] = learnModel(img,seg,fg,bg,fk,bk)

K = 5;
num_images=length(img);
fg_vec=[];
bg_vec=[];
fk_vec=[];
bk_vec=[];
for j=1:num_images
    img2 = reshape(img{j},[],3);
    seg2 = reshape(seg{j},[],1);
    fk2 = reshape(fk{j},[],1);
    bk2 = reshape(bk{j},[],1);
    fg_vec=[fg_vec;img2(seg2,:)];
    bg_vec=[bg_vec;img2(~seg2,:)];
    fk_vec=[fk_vec;fk2(seg2)];
    bk_vec=[bk_vec;bk2(~seg2)];
end
fg = pdf_gm.fit_given_labels(fg_vec,fk_vec,K,fg);
bg = pdf_gm.fit_given_labels(bg_vec,bk_vec,K,bg);

function [fk bk] = assignComponents(img,fg,bg)

fk = fg.cluster_2d(img);
bk = bg.cluster_2d(img);

function [A K] = getPairwise(img)

[h,w,~] = size(img);
n = h*w;

imgr = img(:,:,1); imgr = imgr(:);
imgg = img(:,:,2); imgg = imgg(:);
imgb = img(:,:,3); imgb = imgb(:);

% locations
[x,y] = meshgrid(1:w,1:h);
x = x(:); y = y(:);

% neighbors down -> y+1 -> idx+1
n1_i1 = 1:n; n1_i1 = n1_i1(y<h);
n1_i2 = n1_i1+1;

% neighbors right-down -> x+1,y+1 -> idx+1+h
n2_i1 = 1:n; n2_i1 = n2_i1(y<h & x<w);
n2_i2 = n2_i1+1+h;

% neighbors right -> x+1 -> idx+h
n3_i1 = 1:n; n3_i1 = n3_i1(x<w);
n3_i2 = n3_i1+h;

% neighbors right-up -> x+1,y-1 -> idx+h-1
n4_i1 = 1:n; n4_i1 = n4_i1(x<w & h>1);
n4_i2 = n4_i1+h-1;

from = [n1_i1 n2_i1 n3_i1 n4_i1];
to = [n1_i2 n2_i2 n3_i2 n4_i2];

gamma = 50; % TODO could be trained
invdis = 1./sqrt((x(from)-x(to)).^2+(y(from)-y(to)).^2);
dz2 = (imgr(from)-imgr(to)).^2 + (imgg(from)-imgg(to)).^2 + (imgb(from)-imgb(to)).^2;
beta = (2*mean(dz2.*invdis))^-1; % TODO changed, .*invdis is not in paper, but in gco
expb = exp(-beta*dz2);
c = gamma * invdis .* expb;

A = sparse([from to],[to from],[c c]); % TODO do i need to explicitely make it symmetric?

K = 1+max(sum(A,2)); % TODO changed, gco seems to have only half of this, not correct


function T = getUnary_app(img,fg,bg,fk,bk)

T = cat(3,fg.pdf_2d(img,fk),bg.pdf_2d(img,bk));

function U = getUnary(wb,U_loc,U_app)

U = -wb*log(1e-10+U_loc)-log(U_app);
U = reshape(U,[],2);
U = sparse(U);

function [seg flow energy] = getSegmentation(P,U,w,h)
[flow labels] = maxflow(50*P,50*U);
seg = reshape(labels==1,h,w);
energy = getEnergy(P,U,labels);
