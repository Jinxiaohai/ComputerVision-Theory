function yt=bsplineinterp(y,t,degree) ;
% BSPLINEINTERP B-spline interpolation
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
%  
% We implement B-spline interpolation , which is very
% useful whenever we want to pass a smooth function y=f(t) through 
% given points y_i=f(t_i). We address here only the uniform case with
% t_i=i for iin {1, 2, ..., N} which permits
% simple and efficient
% implementation . The continuous
% function f will be represented as a linear combination of B-splines
% where beta_m is the centered B-spline of degree m. We use
% zero boundary conditions so that all c_i outside 1... N are
% zero. Other boundary conditions, such as
% periodic or mirror, may be more appropriate for some applications.
%
% The Matlab{ implementation presented here was written by
%   one of the authors while at the {Biomedical Imaging Group,
%   EPFL, Switzerland} (http://bigwww.epfl.ch) and its
%   complete version can be found on the . It is sufficiently
%   fast for N up to about 10^4 points. Beyond that, we
%   recommend the  implementation downloadable
%   from http://bigwww.epfl.ch/thevenaz/interpolation.}
%
%  Because of space constraints, 
% only routines related to cubic B-splines ({cbspln, cbinterp,
% cbanal}) are given
% here. Routines lbspln, lbinterp, qbanal, qbspln, qbinterp for
% linear and quadratic B-splines can be found on the .
% 
% Usage: yt = bsplineinterp(y,t,degree)
% Inputs:
%   y  [N x 1]  Vector [y_1, ..., y_N] of values 
%     y_i=f(i) for iin {1, 2, ..., N}.
%   t  [M x 1]  Vector [t_1, ..., t_M] of positions where f(t)
%     is to be calculated.
%   degree  (default 3)  The B-spline degree to use: 1 (linear), 2
%   (quadratic), or 3 (cubic).
% Outputs:
%   yt  [M x 1]  The interpolated values [y(t_1), y(t_2),
%     ..., y(t_M)].

if nargin<3
  degree = 3;
end

% The first step is to calculate the B-spline coefficients.
% Linear B-splines are interpolating, so there is nothing to be done,
% c_i=y_i. 

if degree==1
  c = y;
elseif degree==2
  c = qbanal(y);
elseif degree==3
  c = cbanal(y);
else error('Unsupported degree');
end

% The second step is the actual interpolation. Since the
% interpolation functions are not vectorized, we will do vectorization here.
% h is a function handle.

if degree==1
  h = @lbinterp;
elseif degree==2
  h = @qbinterp;
else
  h = @cbinterp;
end
m = length(t);
yt = zeros( m, 1 );
for i = 1:m
  yt(i) = h( c, t(i) );
end

