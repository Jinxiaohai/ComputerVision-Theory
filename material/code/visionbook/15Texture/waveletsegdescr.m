function v = waveletsegdescr(im,maxlevel,sigma) ;
% WAVELETSEGDESCR wavelet texture descriptors for segmentation
% CMP   Vision Algorithms http://visionbook.felk.cvut.cz
% 
% Usage: v = waveletsegdescr(im,maxlevel,sigma) 
% Inputs:
%   im  [m x n]  Input image.
%   maxlevel  (default 3)  The number of multiresolution levels,
%     see waveletdescr.
%   sigma  (default 10)  Standard deviation of the Gaussian
%     filter used for descriptor averaging, in pixels.  Large
%     values result in more reliable classification at the 
%     expense of suppressing small details.
% Outputs:
%   v  [k x m x n]  A matrix of feature vectors of length k = 3 
%     +1 for each pixel. 
% See also: waveletdescr.
% 
% Since this function is so similar to waveletdescr, we will
% only comment on the differences here.
% 
  
if nargin<3,
  sigma = 10 ;
end ;

if nargin<2,
  maxlevel = 3 ;
end ;

im = double(im);
[m,n] = size(im);
npix = m*n;

v = zeros( 3*maxlevel+1, m, n ); % an array to store the descriptors

% Prepare the filter h for descriptor averaging. 
% Note that h is unitary (has a unit gain).
% The energy in all bands is low-pass filtered by h, with
% symmetric boundary conditions.

h = fspecial( 'gaussian', ceil(3*sigma), sigma );

for i = 1:maxlevel
  l = 2^i;
  if l >= min(m,n),
    error('waveletdescr: image too small for a given number of levels') ;
  end ;
  % filtering in the y direction
  imhy = filterh( im, l );
  imgy = filterg( im, l );
  % filtering in the x direction
  v(3*i-2,:,:) = imfilter( filterg(imgy',l)'.^2, h, 'symmetric' );
  v(3*i-1,:,:) = imfilter( filterh(imgy',l)'.^2, h, 'symmetric' );
  v(3*i,:,:) = imfilter( filterg(imhy',l)'.^2, h, 'symmetric' );
  im = filterh( imhy', l )';
end
  
v(end,:,:) = imfilter( im.^2, h, 'symmetric' ); % low-pass band energy

% We have chosen the feature index to be the first index to v
% (instead of the last) even though it is less efficient here
% because it is more appropriate for subsequent processing in
% texturesegmtrain and texturesegm.

function imf = filterh(im,l) ;
  imf = 0.5*[ im ; im(end-1:-1:end-l,:) ] ;
  imf = imf(1:end-l,:)+imf(l+1:end,:) ;

function imf = filterg(im,l) ;  
  imf = 0.5*[ im ; im(end-1:-1:end-l,:) ] ;
  imf = imf(l+1:end,:)-imf(1:end-l,:) ;
