function [F,T1,T2,e1,e2] = u2Fdlt(u1,u2,do_norm)
% U2FDLT Linear estimation of the Fundamental matrix
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
% Function u2Fdlt implements direct linear estimation (DLT) of the 
% Fundamental matrix from point correspondences
% with (optional) point normalization. This is also known as the 8-point 
% algorithm since at least 8 corresponding point pairs are needed .
% The algorithm yields good results
% for data that are not contaminated by gross errors (outliers) . 
% More advanced algorithms for computation of the
% Fundamental matrix can be found at .
%
% The function accepts coordinates of corresponding points and computes 
% a [3 x 3] matrix F such that
% u_2^T F u_1 = 0
% holds for all corresponding pairs u_1, u_2.
% 
% Usage: [F,T1,T2,e1,e2] = u2Fdlt(u1,u2,do_norm)
% Inputs:
%   u1,u2  [2|3 x N]  Homogeneous coordinates of corresponding points.
%   do_norm  (default 1)  If set to 1 isotropic
%     normalization of point coordinates is applied. The 
%     zero variant may be useful for speed-up if the points are
%     already normalized.
% Outputs:
%   F  [3 x 3]  Fundamental matrix.
%   T1,T2  [3 x 3]  Transformation matrices used for the normalization.
%   e1,e2  [3 x 1]  Normalized homogeneous coordinates of epipoles.
% See also: pointnorm,u2Hdlt.


if nargin<3
  do_norm = 1;
end

% parse the input parameters
if size(u1,2)~=size(u2,2)
  error('different numbers of corresponding points in images')
end
NoPoints = size(u1,2); % number of points
if NoPoints<8 
  error('Too few correspondences')
end

% make sure the coordinates are homogeneous
if size(u1,1)<3, u1(3,:) = 1; end
if size(u2,1)<3, u2(3,:) = 1; end

% Apply isotropic normalization of point coordinates and remember
% the transforming matrices.
if do_norm
  [u1,T1] = pointnorm(u1);
  [u2,T2] = pointnorm(u2);
end

% Compose the homogeneous equations Af=0  .
A = zeros( NoPoints, 9 );
for i=1:NoPoints                          
  A(i,:) = kron( u1(:,i), u2(:,i) );
end

% Solve the equations by
% the least squares (LSQ) method. 
[U,S,V] = svd(A);
f = V(:,size(V,2));
F = reshape( f, 3, 3 );

% Undo the point normalization
if do_norm
  F = T2'*F*T1;
end

% If requested, compute also the epipoles
% and normalize their coordinates. 
% The epipoles are also computed by the LSQ. 
if nargout>3 
  [U,S,V] = svd(F);
  e1 = V(:,size(V,2)); % LSQ solution
  e1 = e1/e1(3);       % normalization to get pixel coordinates
  e2 = U(:,size(U,2));
  e2 = e2/e2(3);
end

return; % end of u2Fdlt

