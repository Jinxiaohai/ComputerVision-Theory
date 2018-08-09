function [K,R,t,C] = P2KRtC(P)
% P2KRtC decompose the euclidean 3x4 projection matrix P
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
%
% Decomposition is such that P = K [R t].
% 
% Usage: [K,R,t,C] = P2KRtC(P)
% Inputs:
%   P  [3 x 4]  Euclidean (metric) projection matrix.
% Outputs:
%   K  [3 x 3]   Upper triangular calibration matrix with
%     internal (intrinsic) parameters.
%   R  [3 x 3]   Rotation matrix. 
%   t  [3 x 1]   Translation vector.
%   C  [3 x 1]   Position of the camera center.
% See also: rq.

P = P ./ norm( P(3,1:3) );
[K,R] = rq( P(:,1:3) );
t = inv(K) * P(:,4);
C = -R'*t;
return  % end of P2KRtC
