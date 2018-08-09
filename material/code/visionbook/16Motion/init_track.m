function pos = init_track(im)
% init_track a simple tracking initialization
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Petr Lhotsky, Tomas Svoboda, 2007
%
% Usage: pos = init_track(im)
% Inputs:
% im  [m x n]  Input image. Typically it is a first image in the sequence. 
% Outputs:
% pos  [2 x 1]  Centroid of the object. 

% A simple function assumes only one object is present.
% It is supposed that the object is much brighter than the
% background.
[u,v] = find(im>200); % thresholding
pos = mean([v,u]);    % centroid of the thresholded pixels

return; % init_track