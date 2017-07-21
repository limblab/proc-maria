function [cp, cran, screws] = cran_calc(bregma_coords, array_cpcoords_mm) 
% Enter Bregma coords in microns from the values on the stereotax
% Enter array center point coords in mm: 
% Hall and Lindholm (2, -1.75)
% Moxon (2.375, -1.5)
% Courtine (2.625, -1.75)
% Seong 2014 (3.1, -1.5)
% Gister, Amina's values (3, -1.5)
% Run like this: 
% [cp, cran, screws] = cran_calc([9284, 21482], [2.2, -1.6])
% Maria Jantz, March 2017

% dimensions of the craniotomy (leave a little wiggle room around the array)
%cran_dim = [2.25, 2.5]; %long way going anterior-posterior
cran_dim = [3.3, 2.675]; %long way going medial-lateral
screw_dist = 3; %screws should be placed at least 2 mm away from craniotomy

cp = bregma_coords + array_cpcoords_mm*1000;

cp_opp = [bregma_coords(1) - array_cpcoords_mm(1) * 1000, cp(2)]

% output: coordinates of points corresponding to quadrants I and III, 
% then center point coordinates, then coordinates for the screws
cran = [cp - cran_dim/2*1000;
cp + cran_dim/2*1000];

cran_opp = [cp_opp - cran_dim/2*1000;
cp_opp + cran_dim/2*1000]

screws = [cp - screw_dist*1000; cp + screw_dist*1000];

end

