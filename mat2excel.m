clear
clc

matRp = './mat/';
matSet = dir([matRp, '*.mat']);

xLocate = 'B';
for imat = 1:length(matSet)
    disp(imat);
% for imat = 1:3
    matName = matSet(imat).name;
    
    claName = matName(1:end-4);
    place_name = [xLocate, '1'];
    xlswrite('test.xlsx',{claName},'sheet1',place_name);    
    
    load([matRp, matName]);
    iourec=zeros(50,1);
    for i=1:50
        meanIOU=mean(vidrec{i});
        meanIOU=(round(meanIOU*10000))/10000;
        iourec(i)=meanIOU;
    end
    place_num = [xLocate, '2'];
    xlswrite('test.xlsx',iourec,'sheet1',place_num);    
    
    place_mean = [xLocate, '52'];
    xlswrite('test.xlsx',mean(iourec),'sheet1',place_mean);
    
    xLocate = char(xLocate + 1);
    
end