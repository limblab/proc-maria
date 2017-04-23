function [allmag, allang, allang2] = forcefilt(data, calmat, b, a)

for i=1:length(data)
    temp_data = data{i}(:,end-5:end)*calmat; %acquire forces and moments from array
    nsamp = size(temp_data,1);
    base = repmat(mean(temp_data(1:400,:)),nsamp,1); %makes a repeating matrix of the average beginning data
    
    %filter
    fdata = filtfilt(b,a,temp_data-base); 
    
    %this is the magnitude of the movement
    fmag = sqrt(fdata(:,1).^2 + fdata(:,2).^2 + fdata(:,3).^2);   
    %this is the angle between two of the directions (which two?)
    ang = atan2(fdata(:,2),fdata(:,1));
    %this is the angle between the other two.
    ang2 = atan2(fdata(:,3),fdata(:,1));
    
    allmag(i,:) = fmag;
    allang(i,:) = ang;
    allang2(i,:) = ang2;
    
end
    
end