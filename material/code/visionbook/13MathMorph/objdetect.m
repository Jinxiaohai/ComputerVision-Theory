function im_out = objdetect(im,el)
% OBJDETECT Detection of horizontal and vertical elongated objects in image.
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Function objdetect detects objects in noisy binary
% images. Objects larger than a given size are first identified
% using morphological opening . As the
% opening transformation reduces the object size, we use binary
% reconstruction to recover the original object shape from the
% detected subset.
%
% Usage: im_out = objdetect(im,el)
% Inputs:
%   im  [m x n]  Binary input image.
%   el  [1 x 2]  Size [x y] of the rectangular
%     structuring element in pixels.
% Outputs:   
%   im_out  [m x n]  Binary image of detected objects.
im = logical(im);
im_out = imclose( im, strel('square',2) );
im_out = imopen( im_out, strel('square',2) );


im_mark = imopen( im_out, strel('rectangle',el) );
figure(3);imshow(im_mark,[]);
exportfig(3,'output_images/objdetect_markers.eps');

im_out = bin_rec( im_mark, im_out );
figure(4);imshow(im_out,[]);
exportfig(4,'output_images/objdetect_reconstructed.eps');

return;

function im_out = bin_rec(im,inset)
%  
% Usage: im_out = bin_rec(im,inset)
% See also: imreconstruct.
%
% Function bin_rec is an implementation of
% morphological binary reconstruction
% .
% Binary reconstruction is a geodesic dilation of size n of the
% markers im inside the set inset for n.
% This is implemented using a series of unit geodesic dilations
% (see function geo_dilate) until convergence 
% is reached .
while true
  im_out = geo_dilate( im, inset );
  diff = sum( im_out(:)-im(:) );
  if diff==0, break; end
  im = im_out;
end
return

function im_out = geo_dilate(im,inset)
%
% Usage: im_out = geo_dilate(im,inset,element)
%
% Function geo_dilate performs a unit geodesic
% dilation  
% of im inside the set inset using a diamond
% structuring element.
im_out = imdilate( im, strel('diamond',1) );
im_out = im_out & inset;
return


