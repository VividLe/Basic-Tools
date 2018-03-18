clear all
clc

%ImgDoc = '/disk2/donzhang/img2/val.tri';

claRp = '/disk2/donzhang/dataset/DAVIS/Image/';

%oriMaskPath = '/disk2/donzhang/img2/maugvalMask/';
%oppMaskPath = '/disk2/donzhang/img2/oppmaugValMask/';

%flowPath = '/disk2/donzhang/dataset/DAVIS/imageFlow/';
flowPath2 = '/disk2/donzhang/dataset/DAVIS/imageFlowOri56/';
%mMaskPath = '/disk2/donzhang/img2/maugValMask170117/';

%if ~exist(flowPath, 'dir')
%      mkdir(flowPath);
%end

if ~exist(flowPath2, 'dir')
      mkdir(flowPath2);
end
%    if ~exist(mMaskPath, 'dir')
%      mkdir(mMaskPath);
%    end

%fid=fopen(ImgDoc,'w+');
%fclose(fid);
claSet = dir(claRp);
claSet = claSet(3:end);
%fid=fopen(ImgDoc,'w+');
claNum = length(claSet);
%other = 1;
parfor icla = 1:claNum
    claName = claSet(icla).name;
    
    %if ~exist([flowPath,claName,'/'], 'dir')
    %  mkdir([flowPath,claName,'/']);
    %end
    if ~exist([flowPath2,claName,'/'], 'dir')
      mkdir([flowPath2,claName,'/']);
    end
    
    fprintf('%s\r', claName);
    imgRp = [claRp,claName,'/'];
    %imgRp = [claRp, claName, '/'];
    imgSet = dir([imgRp, '*.png']);    
    for iimg = 1:length(imgSet)
        img1Name = imgSet(iimg).name;
        img1 = double(imread([claRp,claName,'/',img1Name]));
        for iop = 1 : 5
            if iimg + iop > length(imgSet)
                break;
            end
            img2Name = imgSet(iimg + iop).name;
            img2 = double(imread([claRp,claName,'/',img2Name]));
            img1 = imresize(img1,[56,56],'bilinear');
            img2 = imresize(img2,[56,56],'bilinear');
            optFlowName = [flowPath2,claName,'/op',img1Name(1:end-4),'To',img2Name(1:end-4),'.mat'];
            %if exist('optFlowName','file')
            %   break;
            %else
            flow = mex_LDOF(img1,img2);
            vx = flow(:,:,1);
            vy = flow(:,:,2); 
         
           opticalSave(flow,optFlowName);
           
           %flowx = ((vx + 10)/20) * 225;
           %flowy = ((vy + 10)/20) * 225;
          
           %optFlowNameX = [flowPath,claName,'/op',img1Name(1:end-4),'To',img2Name(1:end-4),'_x.png'];
           %optFlowNameY = [flowPath,claName,'/op',img1Name(1:end-4),'To',img2Name(1:end-4),'_y.png'];
          
           %imwrite(flowx,optFlowNameX);
           %imwrite(flowy,optFlowNameY);
           %end
         end
    end
end
    
