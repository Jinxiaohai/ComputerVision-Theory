function [fx,fy] = gvf(E, mu, tol,fx0,fy0)
% GVF Gradient vector flow calculation
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%  Usage: [fx,fy] = gvf(E,mu,tol,fx0,fy0)
%  Inputs:
%    E   [m x n]  External energy.
%    mu  (default 0.2)
%        Regularization parameter mu.
%         The default value works well.
%    tol  (default 10^
%         Absolute stopping tolerance for the
%          l_infinity change of f_ between two
%          iterations.
%    fx0,fy0  [m x n]  Initial guess of the force field.
%  Outputs:
%    fx,fy  [m x n]  Calculated external force.
% 

% Calculate the gradient and use it as an initial solution if no initial
% guess is provided.
[m,n] = size(E);
[gx,gy] = gradient(E);     
if nargin<5
  fx = gx;   fy = gy;   
else
  fx = fx0;  fy = fy0;
end
SqrMagf = gx.*gx + gy.*gy; 

disp( ['Calculating GVF, size ' num2str([n m])] );


if nargin<3,
  tol=1e-6 ;
end ;

if nargin<2,
  mu=0.2 ;
end ;

% The solution is found iteratively [Equations ??,
% ??] for timestep 1.  Note that if bigger mu is
% used, a smaller timestep might be needed . Convergence is
% detected by monitoring the maximum amplitude ampl of the
% change fxd, fyd. We also stop if ampl fails to
% decrease as this signal's numerical inaccuracy and further iterations
% would not be beneficial. As a final safeguard, we stop after 1000
% iterations.  

ampl0 = inf;  i = 0; 
while true
  fxd = mu*4*del2(fx) - SqrMagf.*(fx-gx);
  fyd = mu*4*del2(fy) - SqrMagf.*(fy-gy);
    
  ampl = max( abs([fxd(:); fyd(:)]) );
  if ampl>ampl0
    disp(['Numerical instability detected, amplitude ' num2str(ampl)]);
    break;
  end
  ampl0 = ampl;
  fx = fx + fxd;
  fy = fy + fyd;
  if rem(i,100)==0,
    disp(['Iterations ' num2str(i) ' amplitude ' num2str(ampl) ]);
  end ;
  if ampl<tol || i>1000
    break;
  end
i = i+1;
end % while-loop

disp(['Iterations ' num2str(i) ' amplitude ' num2str(ampl) ]);

