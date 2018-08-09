function A=is2fs(X,Xm,U);
% IS2FS  Map from image space to feature space.
% CMP Vision Algorithms visionbook@cmp.felk.cvut.cz
% An auxiliary function which takes the data stored as 2D images
% and reshapes it to 1D vector. (Used for PCA demonstration)
% Usage: A = is2fs(X,Xm,U)
% Inputs:
% X  [M x N]  Matrix with the resulting image data. Each column in X
%             is a corresponding vector representing a reconstructed image.
% Xm  [M x 1]  Mean image. 
% U  [M  x K]  Basis vectors of the feature space. 
% Outputs:
% A  [K  x N]  Coefficients vectors. Each column of 
%              A is a vector in the feature space. 

% Courtesy A. Leonardis, D. Skocaj 
% see http://vicos.fri.uni-lj.si/danijels/downloads

[M,N]=size(X);
if Xm==0 Xm=zeros(M,1); end
A=U'*(X-repmat(Xm,1,N));
