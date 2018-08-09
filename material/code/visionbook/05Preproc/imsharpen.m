function im_out=imsharpen(im,C,VERBOSITY);
% IMSHARPEN Image sharpening.
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, Petr Nemecek, 2006-2007

% Function imsharpen sharpens an image by emphasizing places
% with high gradient: 
% sharpening is computed by subtracting 
% a weighted Laplacian from the blurred image. 
% Usage: im_out = imsharpen(im,C,VERBOSITY)
% Inputs:
%   im  [m x n]  Input image, gray scale images assumed.
%   C   1x1  Multiplicative coefficient: (0.3--1.5) is a reasonable range.
%   VERBOSITY  (default 0)
%              Verbosity of the function, if >0 displays
%             images of the gradients.
% Outputs:
%   im_out  [m x n]  Sharpened image.
% See also: gradient.

% History:
% $Id: imsharpen_decor.m 1074 2007-08-14 09:45:42Z kybic $
%
% 2006-01 Petr Nemecek created
% 2007-03-12 Tomas Svoboda (TS), decorated and pedagogically enhanced
% 2007-05-02 TS: new decor
% 2007-05-24 VZ: typo
% 2007-08-09 TS: refinement for better looking of m-files


if nargin<3
  VERBOSITY=0;
end

if C<=0
    warning('Incorrect input value of parameter C. Parameter C has to be greater than zero.');
end

% First, convert the input image to double precision, integers cause errors in
% gradient computation. 
im = double(im);

% Compute the first derivatives: 
[gradX,gradY] = gradient(im);
% Compute the second derivatives:
sqgradX = gradient(gradX);
sqgradY = gradient(gradY')';
% Compute the Laplacian
Laplacian = sqgradX + sqgradY;

% and sharpen the image:
im_out = im - C*Laplacian;

% Truncate values smaller than 0 and higher than 255.
% An alternative post-processing may be
% to re-map the new range to the range (0,...,255), see
% hist_equal or imagesc.
% 
im_out(im_out>255) = 255;
im_out(im_out<0) = 0;
im_out = uint8(im_out);

if VERBOSITY>0
  figure;
  subplot(2,2,1), imagesc(gradX), axis image, colormap(gray(256)); title('x-gradient \it \partial I/\partial x')
  subplot(2,2,2), imagesc(gradY), axis image, colormap(gray(256)); title('y-gradient \it \partial I/\partial y')
  subplot(2,2,3), imagesc(sqgradX), axis image, colormap(gray(256)); title('\it \partial^2 I/\partial x^2')
  subplot(2,2,4), imagesc(sqgradY), axis image, colormap(gray(256)); title('\it \partial^2 I/\partial y^2')
  figure;
  imagesc(Laplacian), axis image, colormap(gray(256)); 
  title('Laplacian: \it \nabla = \partial^2 I/\partial x^2 + \partial^2 I/\partial y^2')
end


return; % end of imsharpen
