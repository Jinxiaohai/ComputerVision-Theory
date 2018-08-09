function X = uP2Xdlt(varargin); 
% uP2Xdlt linear reconstruction of 3D points
%         from N-perspective views
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
% The function accepts a set of camera projection matrices P^i and
% coordinates of the projected points u_j^i and computes coordinates
% of 3D points X_j such that
% u_j^i = P^ X_j
% holds for all cameras and points.
% 
% Usage: X = uP2Xdlt(P1,u1,P2,u2, ...)
% Usage: X = uP2Xdlt(P,u)
% Inputs:
%   P1,P2,...,PN  [3 x 4]  N camera projection matrices.
%   u1,u2,...,un  [3 x n]  Homogeneous coordinates of n corresponding points.
% Outputs:
%   X  [4 x n] Homogeneous coordinates of reconstructed 3D points.


N = length(varargin);
if N==2
  P = varargin{1};
  u = varargin{2};
else
  P = varargin{1:2:N};
  u = varargin{2:2:N};
end

N = size(P,2);
n = size(u{1},2);

% For each point, compose a data matrix from all observations
% and solve the set of linear equations by minimizing
% the algebraic errors by a least squares method .
X = zeros( 4, n );   % reconstructed points
A = zeros( 2*N, 4 ); % data matrix 
for i = 1:n   % for all points
  for j = 1:N % for all cameras
    % create the data matrix
    A(2*j-1,:) = u{j}(1,i)*P{j}(3,:) - P{j}(1,:);
    A(2*j,:)   = u{j}(2,i)*P{j}(3,:) - P{j}(2,:);
  end
  % compute the solution by using the SVD
  [U,S,V] = svd(A);
  X(:,i) = V(:,end);
end
% normalize the reconstructed points
X = X ./ repmat( X(4,:), 4, 1 );
return % end of uP2Xdlt

