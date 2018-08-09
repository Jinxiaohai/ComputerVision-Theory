function w=boundarydescr(xy,n) ;
% BOUNDARYDESCR Calculate boundary descriptors
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% We will now show how to calculate Fourier boundary descriptors w_i
% . These descriptors are invariant to 
% rotation, translation,
% and scaling.  Their purpose is similar to region descriptors
% regiondescr, the main difference being that the
% input region is characterized by its boundary and not all its pixels.
% 
% Usage: w = boundarydescr(xy,n)
% Inputs:
%   xy  [2 x M]  The object boundary represented as an array
%     of point coordinates, each column corresponding to one point. 
%     The boundary is expected to be cyclic (the first row equals
%     the last row).
%   n  (default 7)  The number of descriptors to return. 
%     Values up to 15 are reasonable.
% Outputs:
%   w  [n x 1]  Descriptors w_2,...,w_.
% 
% Note that the descriptors w_i are related to Fourier coefficients
% and therefore
% decrease (decay) quickly with i, especially for smooth curves. 
% It is therefore advisable to scale them appropriately.
% 


if nargin<2,
  n=7 ;
end ;

  
% We resample the boundary equidistantly as in
% resample. The first step is to calculate the
% distance between neighboring points and then the cumulative arc-length
% distance d from the first point. We obtain the resampling
% xi, yi using interp1.
% The number N=256 of samples should be a power of two for
% efficient FFT calculation.
  
x = xy(1,:);  y = xy(2,:);
dx = x(2:end) - x(1:end-1);
dy = y(2:end) - y(1:end-1);
d = sqrt( dx.*dx+dy.*dy );
d = [0 d];     % distance from point 1 to itself is 0 
d = cumsum(d); % the arc length distances from point 1
maxd = d(end);

N = 256;
step = maxd/N;
si = (0:step:maxd-step)';
xi = interp1( d, x, si );
yi = interp1( d, y, si );

% Both x and y coordinates are Fourier transformed.  Taking the
% absolute value of the complex coefficients xf, yf brings
% invariance with respect to phase and thus the starting point. 
% Combining them
% to r  
% using Euclidean distance adds invariance to
% rotation. Neglecting the first (DC) element r(1) makes the result
% invariant to shift and normalizing by r(2) completes the effort by
% yielding w invariant to scaling.

xf = fft(xi);  yf = fft(yi);
r = sqrt( abs(xf).^2 + abs(yf).^2 );
w = r(3:n+2) / r(2);

