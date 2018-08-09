% ASMFIT_DEMO demo for asmfit
% CMP Vision Algorithms http://visionbook.felk.cvut.cz

clear all ; close all
addpath('..') ;
cmpviapath('..') ;


ImageDir='images/';%directory containing the images

if (exist('output_images')~=7)
  mkdir('output_images');
end

% Example
%
% We read a previously learnt hand shape model 
% and a hand image im (Figure ??a).
load handpdm
im = im2double( imread([ ImageDir 'hand.jpg']) );

% The image is smoothed and a gradient magnitude image calculated in each
% color channel. The final edge map g is a maximum over the three
% color channels, thresholded to obtain a clean background.
h = fspecial( 'gaussian', 10, 1 );
g = zeros( size(im,1), size(im,2) );
for i = 1:3
  f = imfilter( im(:,:,i), h, 'symmetric' );
  [px,py] = gradient(f);
  g = max( g, sqrt(px.^2+py.^2) );
end
g = g .* (g>0.4*max(g(:)));

figure(1)
imagesc(g); colormap(1-gray) ; axis image ;  hold on

% Figure ??b shows the shape model in the initial
% position superimposed over the inverted edge map g
% (black on white background).
% Initial pose parameters of the shape model were obtained manually. 
s0 = 0.6;  theta0 = 0.0;  tx0 = 40;  ty0 = 50;
drawcontour(reshape(pointtransf(pmean,theta0,s0,tx0,ty0),2,[]),2);
hold off
exportfig(gcf,'output_images/asmfit1.eps')

[p,theta,s,tx,ty,b] = asmfit( g, pmean, P, lambda, theta0, s0, tx0, ty0 );

% Active shape model fitting takes 25 iterations.
% Figure ??c illustrates the first iteration,
% with normal search lines through each landmark and maxima (new
% proposed landmark positions) found. You can follow the fitting process in
% real-time by running asmfit with default parameters.  The
% final position is shown in Figure ??d.

figure(11) ;
imagesc(g) ; colormap(1-gray) ; axis image ;  hold on ;
drawcontour(reshape(p,2,[]),2) ;
exportfig(gcf,'output_images/asmfit3.eps')

