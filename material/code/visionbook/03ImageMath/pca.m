function [Xm,U,L]=pca(X,K);
% PCA  Perform Principal Component Analysis.
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% PCA is a linear integral transformation that simplifies
% a multidimensional dataset to a lower dimension. 
% The implementation of the function pca
% uses the efficient implementation of singular
% value decomposition (svd).
%
% Usage: [Xm,U,L] = pca(X,K)
% Inputs:
%   X  [M x N]  Compound data matrix.
%   K  1x1  Number of eigenvalues and eigenvectors to be returned.
% Outputs:
%   Xm  [M x 1]  Mean.
%   U   [M x K]  Matrix whose columns consist of eigenvectors.
%   L   [1 x K]  Vector containing eigenvalues.

% Courtesy A. Leonardis, D. Skocaj 
% see http://vicos.fri.uni-lj.si/danijels/downloads

[M N]=size(X);
Xm=mean(X,2);
Xd=X-repmat(Xm,1,N);
if (N < M) %less images than image length
  C=Xd'*Xd;
  [V D Vt]=svd(C);
  U=Xd*V;
  U=U./repmat(sqrt(diag(D)'),M,1);
else %more images than image length
  C=Xd*Xd';
  [U D Ut]=svd(C);
end;
L=diag(D)'/N;

if nargin>1
   U=U(:,1:K);
   L=L(1:K);
end;


