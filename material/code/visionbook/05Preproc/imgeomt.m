function [im_out,axesofnew] = imgeomt(T,im,method,step,axesoforig)
% IMGEOMT 2D geometrical transformation by backward mapping
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2006-2007
% Usage: [newimage,axesofnew] = imgeomt(T,im,method,step)
% Inputs:
%   T  [3 x 3]  Transformation matrix.
%   im  [m x n x l]  Image to be transformed. It can be
%                    multilayer, such as an RGB image.
%   method    Method of interpolation, defaults to 'linear'.
%     See interp2 for more details about interpolation.
%   step  (default 1)  1/sampling factor. Determines the resolution of the
%     output image. If set to 2 only each second pixel (in both x
%     and y direction) from the output image will be rendered. Also
%     useful when transforming image to get a quick preview of
%     the transformed image.
%   axesoforig  struct  Structure containing .x and .y
%     spatial coordinates of the input image. Defaults to 
%     .x=1:n and .y=1:m.
% Outputs:
%   im_out  [? x ? x l] Transformed image. The size of the output
%     image is not determined at the time of calling the
%     function. The output image will contain the original image
%     completely. No cropping is applied.
%   axesofnew  struct  Structure containing .x and .y
%     spatial coordinates of the new image. Useful for 
%     displaying image in true spatial coordinates.
% See also: u2Hdlt, interp2.

% History:
% $Id: imgeomt_decor.m 1074 2007-08-14 09:45:42Z kybic $
%
% 2007-03-07: Tomas Svoboda, created, based on hist own old implementation
%             previously named rectify2D
% 2007-05-02: TS new decor
% 2007-05-14: TS decor updated
% 2007-05-24: VZ typo
% 2007-08-09: TS refinement for better looking of m-file

if nargin<4
  step=1;
end
if nargin<3
  method='linear';
end
  
% First, precompute the range of the output image by a forward mapping  
% of the corner coordinates. The coordinates are conveniently
% arranged in [3 x N] matrices, where N
% is the number of points, which allows computation of the transformation by
% u=T*x. It is more efficient
% than looping over all coordinates and performing
% T*x for each grid point separately.
r = size(im,1);
c = size(im,2);
% compute the range of the original image
try xrange = axesoforig.x; yrange = axesoforig.y;
catch xrange=1:c; yrange=1:r; end
[orig.xi,orig.yi] = meshgrid(xrange,yrange);
% corner points of the image
orig.u = [[min(xrange),min(yrange)]',[min(xrange) max(yrange)]', ...
          [max(xrange) min(yrange)]',[max(xrange) max(yrange)]'];
% make homogeneous
orig.u(3,:) = 1;
% map forward
forward.x = T*orig.u;
% compute the limits of the output image (bounding box)
forward.x(1:2,:) = forward.x(1:2,:)./repmat(forward.x(3,:),2,1);
maxx = max( forward.x(1,:) );
minx = min( forward.x(1,:) );
maxy = max( forward.x(2,:) );
miny = min( forward.x(2,:) );

% Then prepare a grid of spatial coordinates for the new
% image, see meshgrid.
axesofnew.x = minx:step:maxx;
axesofnew.y = miny:step:maxy;
[u,v] = meshgrid( axesofnew.x, axesofnew.y );
x2 = [u(:) v(:) ones(size(v(:)))]';

% Perform the backward mapping of the new coordinates. It essentially
% traverses the grid of the new image and looks back for the 
% counterpart in the original image. 
x1 = inv(T) * x2;
% normalization
x1(1:2,:) = x1(1:2,:) ./ repmat( x1(3,:), 2, 1 );

% Put the back-mapped coordinates into interp2 to
% perform the interpolation.
% Do it for each image layer separately. 
new.xi = reshape( x1(1,:), size(u) );
new.yi = reshape( x1(2,:), size(v) );
layers = size(im,3);
if layers>1
  im_out = zeros( length(axesofnew.y), length(axesofnew.x), layers );
  for i=1:layers
    im_out(:,:,i) = ...
      interp2( orig.xi, orig.yi, double(im(:,:,i)), new.xi, new.yi, method );
  end
else
  im_out = interp2( orig.xi, orig.yi, double(im), new.xi, new.yi, method );  
end

im_out = uint8(round(im_out));
 
return; % end of imgeomt

