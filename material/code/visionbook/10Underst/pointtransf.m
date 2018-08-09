function ptransf=pointtransf(p,theta,s,tx,ty) ;
% POINTTRANSF --- point distribution model transformation
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Usage: ptransf = pointtransf(p,theta,s,tx,ty)
% 
% Transform shape p according to parameters theta,
% s, tx, ty (see Equation ??).

xy = reshape( p, 2, [] );
n  = size( xy, 2 );
st = sin(theta);  ct = cos(theta);
ptransf = [s*ct (-s*st) tx; s*st s*ct ty] * [xy; ones(1,n)];
ptransf = reshape( ptransf, [], 1 );
