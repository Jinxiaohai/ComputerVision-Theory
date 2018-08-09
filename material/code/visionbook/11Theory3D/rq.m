function [R,Q] = rq(X)
% RQ  Returns a 3x3 upper triangular R and a unitary Q so that X = R*Q
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Pajdla, Tomas Svoboda , 1994-2007
% Usage: [R,Q] = rq(X)
% X  [3 x 3]  input matrix 
% Q  [3 x 3] unitary matrix 
% R  [3 x 3] upper triangular matrix 
% See also: qr
% Funtion rq decomposes a [3 x 3] matrix X into the product of 
% an upper diagonal R and a unitary matrix Q such that
% X = RQ.

 
[Qt,Rt] = qr(X');
Rt = Rt';
Qt = Qt';

Qu(1,:) = cross(Rt(2,:),Rt(3,:));
Qu(1,:) = Qu(1,:)/norm(Qu(1,:));

Qu(2,:) = cross(Qu(1,:),Rt(3,:));
Qu(2,:) = Qu(2,:)/norm(Qu(2,:));

Qu(3,:) = cross(Qu(1,:),Qu(2,:));

R  = Rt * Qu';
Q  = Qu * Qt;

return; % end of rq
