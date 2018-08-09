function im_regions = wshed(varargin)
% WSHED Watershed segmentation with automatic marker extraction
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Function wshed implements watershed segmentation with
% automatic marker extraction . The
% function segments bright regions of arbitrary size and shape that
% are separated by darker borders. The markers for the watershed
% transformation are extracted using h-domes, see
% Section ??. A Matlab implementation of the
% watershed transformation is used (watershed).
%
% Usage: im_regions = wshed(im,r,h)
% Inputs:
%   im  [m x n]  Grayscale input image.
%   r  (default 4)  Radius of the structuring element used for
%   de-noising. A reasonable size is 2--5.
%   h  (default 33)  Parameter h of the h-domes
%     extraction. Specifies the minimal height of the intensity 
%     function for each object with respect to the
%     borders. A reasonable value for h is 20--40.
% Outputs:   
%   im_regions  [m x n]  Watershed regions. The regions are
%     labeled by increasing values 1,2,3, Zeros mark
%     region boundaries.
% See also: watershed.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
im = varargin{1};

% handle the input variable r, if unspecified assign r = 4
if nargin>1
  r = varargin{2};
else
  r = 4;
end

% handle the input variable h, if unspecified assign h = 35
if nargin>2
  h = varargin{3};
else
  h = 35;
end

im = imopen( im, strel('disk',r) );

figure(2);imshow(im,[]); colormap(gray);
exportfig(2,'output_images/wshed_opened.eps');

markers = im - imreconstruct( im-h, im ); % extraction of h-domes
figure(3);imshow(markers,[]); colormap(gray);
exportfig(3,'output_images/wshed_h_domes.eps');
markers = markers > 0; % thresholding h-domes
markers = imerode( markers, strel('disk',3) ); % eroding markers

im_marked = max(im(:)) - im; 
im_marked = imimposemin( im_marked, markers );
im_regions = watershed( im_marked );
return


