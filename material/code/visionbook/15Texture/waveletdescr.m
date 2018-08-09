function v = waveletdescr(im,maxlevel) ;
% WAVELETDESCR calculate wavelet texture descriptors
% CMP   Vision Algorithms http://visionbook.felk.cvut.cz
%
% Discrete wavelet frame texture descriptors ,
%  are an alternative to classical
% texture descriptors, based for example on co-occurrence matrices
% (Section ??). Discrete wavelet frames can be calculated
%  fast using a filter-bank and the descriptors perform well for
%  many applications.
% 
% For simplicity and computational efficiency, we shall use the Haar
% wavelet with a low-pass filter H(z) = (1+z)/2  and a corresponding high-pass
% filter G(z) = (z-1)/2.
% 
% Usage: v = waveletdescr(im,maxlevel)
% Inputs:
%   im  [m x n]  Input image. It should 
%     contain a sufficiently large patch of homogeneous texture to
%     analyze. A typical size might be 100x 100 pixels,
%     depending on the resolution. It is recommended that images be of
%     the same size and the same amplitude for the feature vectors 
%     to be comparable.
%   maxlevel  (default 3)  The number of multiresolution levels,
%     chosen depending on the characteristic scale of the texture;
%     the largest filters will have size
%     2^maxlevel.  
%     Increasing
%     maxlevel increases computational complexity and the number of
%     features generated.
% Outputs:
%   v  [k x 1]  Feature vector of length k = 3 +1, 
%     characterizing the input texture im.
% See also: haralick.
  
  
if nargin<2,
  maxlevel = 3 ;
end ;

% Unlike for haralick, input images are not restricted to be
% of type uint8. Here the image is first converted to
% double, to avoid overflow problems. However, note that an
% optimized, all integer, implementation would be straightforward.

im = double(im);
[m,n] = size(im);
npix = m*n;

% The main loop is repeated maxlevel times. At each level, we
% filter the input image im to provide four sub-bands by using
% the following filter combinations: H_x H_y,
% H_x G_y, G_x H_y, G_x G_y, where H_x is the low-pass filter
% applied along the x direction, G_y is the high-pass filter applied
% along the y direction etc. Note that thanks to separability, only six
% 1D filtering operations are required, implemented by functions 
% filterh and filterg, below. The low-pass version
% (filtered by H_x H_y) is used as an input to the subsequent scale 
% and the filter size l
% is doubled.
%  
% The features are the energies in the three high-pass (detail)
% sub-bands for each level. At the last level, the energy of the low-pass
% band is also added to the output feature vector v.

v = zeros( 3*maxlevel+1, 1 ); % the descriptors
for i = 1:maxlevel
  l = 2^i;
  if l>=min(m,n),
    error('waveletdescr: image too small for a given number of levels') ;
  end ;
  % filtering in the y direction
  imhy = filterh( im, l );
  imgy = filterg( im, l );
  % filtering in the x direction
  vgg = sum(sum( filterg(imgy',l).^2 )) / npix;
  vhg = sum(sum( filterh(imgy',l).^2 )) / npix;
  vgh = sum(sum( filterg(imhy',l).^2 )) / npix;
  im = filterh( imhy', l )';
  v(3*i-2:3*i) = [vgg vhg vgh];
end
  
v(end) = sum(sum( im.^2 )) / npix; % low-pass band energy

% Unlike a standard discrete wavelet transform, we are
% using a wavelet frame, so no subsampling of the filtered images is
% performed.

function imf = filterh(im,l)
% Usage: imf = filterh(im,l)
% Function filterh filters all columns of the image 
% im by a low-pass
% Haar filter H(z) = (1+z^l)/2. Since the filter has
% only two non-zero elements, the filtering amounts to adding together two
% shifted copies of the image. Mirror boundary conditions are ensured
% by extending the image by l rows.
  imf = 0.5*[im; im(end-1:-1:end-l,:)];
  imf = imf(1:end-l,:) + imf(l+1:end,:);

function imf = filterg(im,l)
% Usage: imf = filterg(im,l)
% Function filterg works like filterh except the high-pass
% filter G(z) = (z^-1)/2 is used.
  imf = 0.5*[im; im(end-1:-1:end-l,:)];
  imf = imf(l+1:end,:) - imf(1:end-l,:);

