clear all

filepath = '/Users/mariajantz/Documents/Work/data/'; 
filename = 'database.mat'; 

load([filepath filename]); 

%matrix to be sorted
matsort = database.normal.fratematrixnorm; 

figure(1); 
subplot(2, 1, 1); 
imagesc(matsort); 

%matrix is (# clusters) x (# step phase bins) in size
[ncells, nbins] = size(matsort); 

%WHAT ARE I AND II??
%
bins = linspace(0,2*pi,nbins); %

rs = [];
for ii=1:ncells
    mncos = mean(cos(bins).*matsort(ii,:));  % the mean cosine of the weighted vectors
    mnsin = mean(sin(bins).*matsort(ii,:));   % the mean sine of the weighted vectors
    %for i=1:nbins
    r = sqrt(mncos^2 + mnsin^2); %replace with circular statistics?
    rs = [rs r]; %approximate modulation depth
    
    if r>0.1
        pd(ii) = atan2(mnsin,mncos);
    end
    % end
    
end

%sort preferred phases
[pd2,sortind] = sort(pd);

%sort matrix according to preferred phases
sorteddata = matsort(sortind,:);

%rearrange rows


subplot(2, 1, 2); 
imagesc(sorteddata); 




