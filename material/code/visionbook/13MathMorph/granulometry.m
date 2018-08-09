function im_gran = granulometry(im)
% GRANULOMETRY Binary granulometry computed using square structuring element
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% The granulometry function maps to each pixel a value n that is the
% size of the largest structuring element such that an opening by
% this element leaves the pixel in the image.
% This function computes a granulometry function of a binary image
% using a family of openings by a square structuring
% element . The square element
% was chosen because it allows an efficient implementation. We use
% an algorithm by Vincent  which consists
% of computing a distance function and propagating its values
% linewise, separately in both dimensions. 
%
% Usage: im_gran = granulometry(im)
% Inputs:
%   im  [m x n]  Binary input image.
% Outputs:   
%   im_gran  [m x n]  Granulometry of im by square
%     structuring element.

im_dist = dist_square(im);

figure(3);imshow(im_dist,[]); colormap(jet); colorbar;
exportfig(3,'output_images/granulometry_distance.eps');

im_gran = propagate_dist( im_dist );   % propagation right-left
figure(4);imshow(im_gran,[]); colormap(jet); colorbar;
exportfig(4,'output_images/granulometry_propagated.eps');
im_gran = propagate_dist( im_gran' )'; % propagation bottom-up
return

function im_dist = dist_square(im)
% Usage: im_dist = dist_square(im)
% Function dist_square computes the distance function using
% a square element with center in the bottom-right corner
%   11\1x1X  ,
% where X marks the element center.
% For such an element, the distance can be computed in a single
% image scan . 
% The image is extended by one row and column to avoid the
% necessity to treat the first row and column separately.
im_dist = zeros( size(im,1)+1, size(im,2)+1 );
im_dist(2:end,2:end) = im;
for x = 2:size(im_dist,1)
  for y = 2:size(im_dist,2)
    if im_dist(x,y)==1
      im_dist(x,y) = 1 + min([im_dist(x-1,y-1) im_dist(x-1,y) im_dist(x,y-1)]);            
    end
  end
end
im_dist = im_dist( 2:end, 2:end );

return

function im_gran = propagate_dist(im_dist)
% Usage: im_gran = propagate_dist(im_dist)
% Function propagate_dist propagates the distance function
% from right to left in each row separately to compute the
% granulometry function g_I as described by
% Vincent .
M = max( im_dist(:) );
im_gran = zeros( size(im_dist,1), size(im_dist,2)+M );
for y = 1:size(im_dist,1)
  for x = size(im_gran,2):-1:(M+1)
    V = im_dist( y, x-M ); % V is the current value of the distance function
    if V>0  % value V is propagated to the next V pixels in parallel
      im_gran(y,(x-V+1):x) = max( im_gran(y,(x-V+1):x), V );
    end
  end
end
im_gran = im_gran(:,M+1:end);
return

