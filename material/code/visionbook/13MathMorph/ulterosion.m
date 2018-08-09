function im_out = ulterosion(varargin)
% ULTEROSION Ultimate erosion: regional maxima of the distance transform
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Function ulterosion performs ultimate erosion, 
% This is usually used to extract markers from overlapping binary objects; 
% it is found as a regional maximum of the distance function.
%
% Usage: im_out = ulterosion(im,method)
% Inputs:
%   im  [m x n]  Binary input image.
%   method  (default 'cityblock')  Method used to compute the
%   distance function. The options are 'cityblock', 
%   'chessboard' or 'euclidean'. 
% Outputs:   
%   im_out  [m x n]  Ultimate erosion of im.
% See also: bwulterode.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
im = varargin{1};

% handle the input variable r. If unspecified assign r = 4.
if nargin>1
  method = varargin{2};
else
  method = 'cityblock';
end

D = bwdist( 1-im, method );
figure(4); imshow(D,[]); colormap(jet)
exportfig(4,'output_images/ulterosion_distance.eps');

im_out = D - imreconstruct( D-1, D );
im_out = im_out > 0;
return


