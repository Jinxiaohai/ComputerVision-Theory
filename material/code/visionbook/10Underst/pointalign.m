function [ptransf,theta,s,tx,ty]=pointalign(pref,p,theta0,w) ;
% POINTALIGN
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Aligning the shapes
%   
% Suppose we have
% a moving shape and a reference shape described by landmark
% coordinates (x_i,y_i) and (x'_i,y'_i), respectively.  We need to find
% a transformation consisting of rotation, translation, and scaling that
% transforms the moving shape onto the reference shape in the `best' way 
% , defined as minimizing a sum of squared
% distances
% We have included weights
% w_i into the formulation , 
% however, this possibility is
% not used in our code.
%
% We decompose the minimization of E(theta,s,t_x,t_y) to an
% outer minimization with respect to theta and inner
% minimization with respect to s, t_x, t_y. 
% Minimization with respect to s, t_x, t_y is performed by setting
% the corresponding partial derivatives to zero
% The dependency E(theta)=min_ E(theta,s,t_x,t_y) is 
% non-linear, so the outer minimization with respect to theta is
% performed numerically. This normally only needs a few iterations, as
% the function is smooth and one dimensional.
% 
% Usage: [ptransf,theta,s,tx,ty] = pointalign(pref,p,theta0,w)
% Inputs:
%   pref  [2N x 1]  The reference shape [x'_1,y'_1,...,x'_N,y'_N ].
%   p     [2N x 1]  The moving shape    [x_1,y_1,...,x_N,y_N] to be
%     aligned to the reference shape.
%   theta0  (default 0)  Initial guess of the angle theta, in
%     radians.
%   w  [N x 1]  Weights w_i, default to w_i=1.
% Outputs:
%   ptransf  [2N x 1]  Transformed shape p
%     aligned with the reference shape pref in the sense of
%     criterion E (??).
%   theta,s,tx,ty  1x1  Parameters theta, s, t_x, and t_y of the
%     optimal fit.

if nargin<4,
  w=ones(size(p,1)/2,1) ;
end ;
  
if nargin<3,
  theta0=0 ;
end ;


% The minimization with respect to theta is performed by the function
% fminunc{If this function is not available - it
% is part of the Matlab's Optimization
% Toolbox - fminsearch will work equally well.}. 
% The criterion function E(theta) is evaluated by a function 
% crit (below). Once the optimal theta is found, the
% transformed shape ptransf and the rest of the parameters 
% are calculated using function transf.


theta = fminunc( @(theta)(crit(p,pref,theta,w)), theta0, ...
		 optimset('Display','off','LargeScale','off'));
[E,ptransf,s,tx,ty] = transf( p, pref, theta, w );

function E=crit(p,pref,theta,w) ;
% Usage: E = crit(p,pref,theta,w)
%
% Function crit is only a wrapper around transf.

[E,ptransf,s,tx,ty] = transf( p, pref, theta, w );
  
function [E,ptransf,s,tx,ty]=transf(p,pref,theta,w) ;
% Usage: [E,ptransf,s,tx,ty] = transf(p,pref,theta,w)
% 
% Function transf takes the moving and reference shapes p
% and pref and the parameter theta and weights w_i. 
% It calculates optimal s, t_x, t_y from (??)
% and the transformed shape ptransf, and evaluates
% the criterion E (??).
%
% We extract the x and y coordinates of the landmarks and precalculate
% sin theta, cos theta.

xy    = reshape( p,    2, [] );
xyref = reshape( pref, 2, [] );
n     = size( xy, 2 );
x    = xy(1,:);     y    = xy(2,:);
xref = xyref(1,:);  yref = xyref(2,:);
st   = sin(theta);  ct   = cos(theta);

% Assemble and solve the linear system of equations (??) for 
% unknowns s, t_x, t_y.

xw = x.*w';  yw = y.*w';
xrefw = xref.*w';  yrefw = yref.*w';
sx = sum(xw);  sy = sum(yw);
yst = st*sy;  xct = ct*sx;  xst = st*sx;  yct = ct*sy;
A = [yst-xct -n 0; -xst-yct 0 -n; ...
     sum((st.*yw-ct.*xw).^2+(st.*xw+ct.*yw).^2) -yst+xct xst+yct];
b = [-sum(xrefw) -sum(yrefw) dot(xrefw,-y*st+x*ct)+dot(yrefw,x*st+y*ct)]';
q = A\b;
s = q(1);  tx = q(2);  ty = q(3);

% Transform the points using function pointtransf (below) and 
% evaluate the criterion E.

ptransf = pointtransf( p, theta, s, tx, ty );
ptransf = reshape( ptransf, [], 1 );
E = sum( reshape(repmat(w',2,1),[],1).*(ptransf-pref).^2 );

