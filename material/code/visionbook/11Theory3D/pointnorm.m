function [u2,T] = pointnorm(u);
% POINTNORM   Isotropic point normalization
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2006-2007
%
% Usage: [u2,T] = pointnorm(u)
% Inputs:
%   u  [3 x N]  Matrix of unnormalized coordinates of N points.
% Outputs:
%   u2  [3 x N]  Normalized coordinates.
%   T   [3 x 3]  Transformation matrix, u2 = Tu.
% See also: u2Fdlt, u2Hdlt.



% how many points
n=size(u,2);

% Center the coordinates.
centroid = mean( u(1:2,:)' )';
u2 = u;
u2(1:2,:) = u(1:2,:) - repmat(centroid,1,n);

% Scale points to have average distance from the origin .
scale = sqrt(2) / mean( sqrt(sum(u2(1:2,:).^2)) );
u2(1:2,:) = scale*u2(1:2,:);

% Composition of the normalization matrix.
T = diag([scale scale 1]);
T(1:2,3) = -scale*centroid;
return  % end of pointnorm

