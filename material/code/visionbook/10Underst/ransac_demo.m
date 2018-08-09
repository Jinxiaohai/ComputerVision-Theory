% RANSAC_DEMO --- RANSAC demonstration
% CMP Vision Algorithms http://visionbook.felk.cvut.cz

addpath('..') ;
cmpviapath('..') ;

if (exist('output_images')~=7)
  mkdir('output_images');
end

rand('state',4) ;

ransac_demof(1,1,1) ;
ransac_demof(1,0.9,2) ;
ransac_demof(1,0.5,3,2) ;
ransac_demof(1,0.1,4,1) ;

