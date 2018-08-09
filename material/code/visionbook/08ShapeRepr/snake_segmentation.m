function [xy]=snake_segmentation(im,xc,yc,r,kappa,lambda) ;
% SNAKE_SEGMENTATION segmentation of grayscale images using snakes
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Usage: xy = snake_segmentation(im,xc,yc,r,kappa,lambda)
% Inputs:
%   im  [m x n]  Contains the grayscale image to be segmented.
%   xc,yc  1x1  x and y coordinates of the center of the
%     initial circular contour.
%   r  1x1  Radius of the initial circular contour.
%   kappa  1x1  Parameter kappa determining the strength of the
%     external force (data term). See also Section ??.  
%   lambda  1x1  Parameter lambda determining the strength of
%     the balloon force. See also Section ??.
% Outputs:
%   xy  [2 x M]  The final contour points as returned by
%     snake, packed to an array suitable for
%     boundarydescr.
  
% The initial contour is a circle which is expected to lie inside the
% object to be segmented. Care needs to be taken so that the contour is
% oriented clockwise with respect to Matlab image conventions.

  
t = 0:0.5:2*pi;
xi = xc+cos(t)*r;  yi = yc+sin(t)*r;
  
% The snake will be driven purely by intensity, expanding in dark regions
% and shrinking in bright regions.
  
[px,py] = gradient(-im);
kappa1 = 1 / max( abs([px(:); py(:)]) );
[x,y] = snake( xi, yi, 0.1, 0.01, kappa*kappa1, lambda, px, py );

% The evolution of the snake can be observed by using the 
% following line instead.

% Finally, we pack the x and y arrays together.

xy = [x'; y'];
