% demo of COARSE_PIXELS_DRAW, displays foreground image on background binary image
% CMP Vision Algorithms http://visionbook.felk.cvut.cz 
% Vaclav Hlavac, 2007-06-27
%
% Histrory:
% $Id: coarse_pixels_draw_demo_decor.m 1088 2007-08-16 06:34:55Z svoboda $

clear all;
addpath ../.
cmpviapath('../.');
% create a directory for output images
% if needed and does not already exist
out_dir = 'output_images/';
if (exist(out_dir)~=7)
  mkdir(out_dir);
end


% read the input images from prepared files
imBackground = imread('images/NoncovexExBg.png');
imForeground = imread('images/NoncovexExFg.png');
% Display the image using function dedicated for drawing coarse images.
% The first parameter is the background, and the second parameter 
% is an empty array, no foreground image will be drawn.
fh = coarse_pixels_draw(imBackground, imForeground);
title('Non-convex region');
print('-depsc2','-cmyk',[out_dir,'NonconvexIllustr.eps'])

