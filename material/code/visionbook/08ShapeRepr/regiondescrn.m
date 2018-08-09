function phi=regiondescrn(imgl) ;
% REGIONDESCRN calculate region descriptors for all regions in an image
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Usage: phi = regiondescrn(imgl)
%
% Calculate region descriptors using regiondescr for all regions  
% in the image. imgl is in the same format as output from 
% bwlabel, 
% integer values from 0 to the number of regions, 0 corresponds to 
% the background.

n = max( imgl(:) );
phi = zeros( n, 7 );
for i = 1:n
  phi(i,:) = regiondescr( imgl==i );
end
