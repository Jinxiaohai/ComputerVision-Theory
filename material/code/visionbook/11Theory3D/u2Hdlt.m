function [H,T1,T2] = u2Hdlt(u1,u2,do_norm)
% u2Hdlt  linear estimation of the Homography matrix
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
% Function u2Hdlt estimates homography from point correspondences
% by using the direct linear transformation (DLT)
% with (optional) point normalization. The homography is also known as 
% collineation
% or projective transform
% The function accepts coordinates of N corresponding image points 
% and returns a calculated [3 x 3] homography matrix H such that
% u_2 = H u_1  
% for all N points. At least 4 corresponding points are requested. The function
% estimates a least squares (LSQ) solution.
% 
% The 2D homography is widely used
% in consumer oriented applications, e.g.,
% Hugin (http://hugin.sourceforge.net).
%
% Usage: [H,T1,T2] = u2Hdlt(u1,u2,do_norm)
% Inputs:
%   u1,u2  [2|3 x N]  Coordinates (homogeneous) of the corresponding points.
%   do_norm  (default 1)  If set to 1 perform isotropic normalization of points.
%     Disabling normalization may be useful for speed reasons
%     when points are already normalized.
% Outputs:
%   H  [3 x 3]  Homography matrix.
%   T1,T2  [3 x 3]  Transformation matrices used in normalization.
% See also: imgeomt, pointnorm, u2Fdlt.
%


if nargin < 3
  do_norm=1;
end

if size(u1,2)~=size(u2,2)
  error('The number of corresponding points si not the same')
end
if size(u1,2)<4
  error('Too few correspondences')
end
if size(u1,1) == 2,
  u1(3,:) = 1;
end
if size(u2,1) == 2,
  u2(3,:) = 1;
end

% Do isotropic normalization using function pointnorm.
if do_norm
  [u1,T1] = pointnorm(u1);
  [u2,T2] = pointnorm(u2);
end

% Compose the data matrix from point correspondences. 
% The implementation closely follows .
% This is a decent example of Matlab\/, allowing very
% elegant implementation of algebraic expressions.
A = zeros( 3*size(u1,2), 9 );
for i=1:size(u1,2) % all points
  A(3*i-2:3*i,:) = kron( u1(:,i)', G(u2(:,i)) );
end

% Function G forms a skew symmetric matrix from a given vector, see below.
% Function kron computes Kronecker tensor product. It returns an array
% formed by taking all possible products between the elements u1(:,i)' and those
% of G(u2(:,i)).
% Now, compute the LSQ solution using SVD.
[U,S,V] = svd(A);
H = reshape( V(:,end), 3, 3 );

% Undo the point normalization if it was applied.
if do_norm
  H = inv(T2)*H*T1;
end
return % end of u2Hdlt

function mat = G(u)
% Usage: mat = G(u)
% Inputs:
%   u  [3 x 1]  Vector of values.
% Outputs:
%   mat  [3 x 3]  Skew symmetric matrix containing the vector values.
mat = [0 -u(3) u(2); u(3) 0 -u(1); -u(2) u(1) 0];
return % end of G

