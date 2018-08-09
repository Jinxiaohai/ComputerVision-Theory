function model=texturesegmtrain(im,mask,maxlevel,sigma) ;
% TEXTURESEGMTRAIN training for texture based segmentation
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Usage: model = texturesegmtrain(im,mask,maxlevel,sigma)
% Inputs:
%   im  [m x n]  Input image.
%   mask  [m x n]  Segmentation for the image im. The numbers
%     in mask denote the class for the corresponding pixel in
%     im and should be from the range 1... d where d 
%    is the number of  classes.
%   maxlevel  (default 3)  The number of multiresolution levels, 
%     see waveletdescr.
%   sigma  (default 10)  Standard deviation of the 
%     Gaussian filter used for descriptor averaging, in pixels, see
%   waveletsegdescr.
% Outputs:
%   model  struct  Model of the texture classes to be used by
%     texturesegm.
% See also: {texturesegm, waveletdescr,
%   waveletsegdescr.}

if nargin<4,
  sigma = 10 ;
end ;

if nargin<3,
  maxlevel = 3 ;
end ;

% First, the texture descriptors f are calculated (for each pixel).
% The probability distribution of these descriptors for each class is
% assumed to be normal. Their parameters are estimated using  function
% mlcgmm , as in
% Section ?? or Section ??. 
  
f = waveletsegdescr( im, maxlevel, sigma );
[k,m,n] = size(f);
features.X = reshape( f, k, m*n );
features.y = reshape( mask, 1, m*n );

model = mlcgmm( features, 'diag' );
model.maxlevel = maxlevel;
model.sigma = sigma;
