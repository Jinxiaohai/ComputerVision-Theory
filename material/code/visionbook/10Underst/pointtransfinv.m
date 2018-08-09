function ptransf=pointtransfinv(p,theta,s,tx,ty) ;
% POINTTRANSFINV --- point distribution model inverse transformation
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Usage: ptransf = pointtransfinv(p,theta,s,tx,ty)
% 
% Inverse transformation to pointtransf.

xy = reshape( p, 2, [] );
n = size(xy,2);
st = sin(-theta);  ct = cos(-theta);
rs = 1/s;
ptransf = [rs*ct (-rs*st); rs*st rs*ct] * ( xy-repmat([tx;ty],1,n) );
ptransf = reshape( ptransf, [], 1 );
