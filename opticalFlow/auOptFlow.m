clear all
clc

claRp = '/disk3/donzhang/augTrainImg/';

flowPath = '/disk3/donzhang/optFlow/optFlow224/';

if ~exist(flowPath, 'dir')
      mkdir(flowPath);
end

claSet = dir(claRp);
claSet = claSet(3:end);

claNum = length(claSet);

for icla = 1:claNum
    claName = claSet(icla).name;
    
    if ~exist([flowPath,claName,'/'], 'dir')
      mkdir([flowPath,claName,'/']);
    end
    
    fprintf('%s\r', claName);
    imgRp = [claRp,claName,'/'];
    %imgRp = [claRp, claName, '/'];
    imgSet = dir([imgRp, '*.png']); 
    imgSetNum = str2double(imgSet(length(imgSet)).name(1:5));
    parfor iimg = 1:length(imgSet)
        img1Name = imgSet(iimg).name;
        imgNum = str2num(img1Name(1:5));
        img1 = double(imread([claRp,claName,'/',img1Name]));
        for iop = 1 : 5
            if imgNum + iop > imgSetNum
                break;
            end
           img2Name = [num2str(imgNum+iop,'%.5d'),img1Name(6:end)];
           optFlowName = [flowPath,claName,'/op',img1Name(1:end-4),'To',img2Name(1:end-4),'.mat'];
           if exist(optFlowName,'file')
               continue;
           end
           
            img2 = double(imread([claRp,claName,'/',img2Name]));
            img1 = imresize(img1,[224,224],'bilinear');
            img2 = imresize(img2,[224,224],'bilinear');
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
    
