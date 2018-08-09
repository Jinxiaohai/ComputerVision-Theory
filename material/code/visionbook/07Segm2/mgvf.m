function [fx,fy]=mgvf(E,mu,tol) ;
% MGVF Multiresolution gradient vector flow 
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Gradient vector flow  is 
% a way to improve snake 
% segmentation 
% The balloon force is no longer needed, as the external force is 
% modified to `know' the direction to the boundary even far away from it.  
% The function mgvf - where
% m stands for multi-resolution - calculates an external force
%  from the external energy by solving the PDEs
% The multi-resolution
% approach consists of solving the problem first for a reduced version of
% the image and using the solution as a starting point for the next finer
% level. It is needed because for large images, the convergence of the
% force field far away from the edges is quite slow, which makes the
% snake stop before reaching the desired boundary. 
% 
% {The code presented here is derived from the work of Xu and
% Prince  and their publicly available implementation 
% (http://iacl.ece.jhu.edu/projects/gvf/).}
%
% Usage: [fx,fy] = mgvf(E,mu,tol)
% Inputs:
%   E   [m x n]  External energy, normalized to [0,1].
%   mu  (default 0.2)
%       Regularization parameter mu.
%        The default value works well.
%   tol  (default 10^
%        Absolute stopping tolerance for the 
%  l_infty change of f_E  
%  between two iterations.
% Outputs:
%    fx,fy  [m x n]  Calculated external force.
  
if nargin<3,
  tol=1e-3 ;
end ;

if nargin<2,
  mu=0.2 ;
end ;

[m,n] = size(E);
Emin  = min(E(:));
Emax  = max(E(:));
E = (E-Emin)/(Emax-Emin);  % normalize E 

% If the energy image is small enough, the solution is found iteratively using
% gvf. If not, it is scaled down to
% half the size and mgvf is called recursively to find the force
% field. The force field is then extrapolated to the original resolution
% and used as a starting guess for an iterative solution in gvf.

if min(m,n)<64
  [fx,fy] = gvf( E, mu, tol );
else
  Es = 2 * imresize( E, 0.5, 'bilinear' );
  [fxs,fys] = mgvf( Es, mu, tol );
  fx0 = 0.5 * imresize( fxs, [m n], 'bilinear' );
  fy0 = 0.5 * imresize( fys, [m n], 'bilinear' );
  [fx,fy] = gvf( E, mu, tol, fx0, fy0 );
end
  

