function f=levelset(f,im,mu,nu,c1,c2,lambda1,lambda2,kappa,g,tau) ;
% LEVELSET implementation of active contours
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% We implement a level set active contour segmentation method
%  
% Warning: The level-set evolution formulation
%  is 
% deceptively simple.  Robust and fast implementation of level set methods
% on a discrete grid typically use special upwind update schemes with
% frequent re-initialization to maintain the distance function property of
% phi and a narrow band approach for
% acceleration . However, these techniques are unsuitable for
% Matlab implementation. We have therefore adopted a technique
% proposed by Li  that augments the criterion C to
% penalize the deviation of phi from the signed distance function
%
% Usage: f = levelset(f,im,mu,nu,c1,c2,lambda1,lambda2,kappa,g,tau)
% Inputs:
%   f  [m x n]  Initial value of the level set function
%     phi, which should be negative inside, zero on the boundary and
%     positive outside. The initial value of phi does not have to
%     be a signed distance function but the convergence might be more
%     difficult if it deviates from it too much.
%   im  [m x n]  Image being segmented.
%   mu  1x1  Coefficient mu for the curve length part of
%     the criterion.
%   nu  1x1  Coefficient nu for the area part of the
%     criterion. It plays the role of the balloon force
%     . A positive (negative) nu makes the contour shrink
%     (grow).
%   c1, c2  1x1  Expected intensities c_1, c_2 of the inside
%     (outside) of the object to be segmented for the
%     Chan-Vese area intensity criterion.
%   lambda1  1x1
%   lambda2  1x1  Coefficients lambda_1, lambda_2 
%     for the  Chan-Vese area intensity criterion.
%   kappa  1x1  Coefficient kappa to penalize deviation of
%     phi from the signed distance function.
%   g  [m x n]  Distance metric weight g. Defaults to constant 1
%     everywhere.
%   tau  1x1  Time step tau. By default it is calculated from
%     the CFL condition  so that the level set front
%     is guaranteed not to move further than one grid point at each
%     iteration. However, larger tau can often be used to
%     accelerate the convergence. If the iterations start to be
%     unstable,  tau should be decreased.
% Outputs:
%   f  [m x n]  Final level set state phi.
  
% If needed, set the time step tau and initialize some variables;
% areas will be used in the stopping criterion 
% epsilon is the size of
% the smoothed Dirac delta_varepsilon.
  
if nargin<11
  tau = 0.9/( abs(mu) + abs(nu) + abs(lambda1+lambda2) + abs(kappa) );
end

if nargin<10,
  g=ones(size(f)) ;
end ;

epsilon = 1.5;   i = 0;   areas = [];

% We iterate in a while-loop until convergence. In the loop, we
% ensure the correct boundary conditions (see NeumannBoundCond), 
% calculate the gradient and the
% normalized gradient. eps guards against division by zero.
% The Chan-Vese area intensity term fchvese does not depend on
% f and can be taken out of the loop.
fchvese = lambda1*(im-c1).^2 - lambda2*(im-c2).^2;
while true
  f = NeumannBoundCond(f);
  [ux,uy] = gradient(f);
  normu = sqrt( ux.^2 + uy.^2 + eps );
  nx = ux ./ normu;  % normalized gradient
  ny = uy ./ normu;
% All parts of the right-hand side of the evolution 
% equation (??) are evaluated:
% the distance function deviation term fdist and the curve and area
% terms fcurvearea. We assemble an update using a smoothed Dirac
% d (delta_varepsilon). Note that except for fdist, the rest of the terms only
% influences a narrow zone around the zero level set.
  fdist = kappa * ( 4*del2(f)-divergence(nx,ny) );
  fcurvearea = mu*divergence(g.*nx,g.*ny) + nu.*g;
  d  = (0.5/epsilon)*(1+cos(pi*f/epsilon)).*(abs(f)<epsilon);
  fu = fdist + d.*(fcurvearea+fchvese);
  f  = f + tau*fu;

% The stopping criterion is as in Section ??. In addition,
% we stop after a fixed number of iterations.
  area  = sum( f(:)<0 );
  areas = [areas area]; 
  if length(areas)>10
    areas = areas(end-9:end);  % keep last 10 areas
    if max(areas)-min(areas)<1 || i>1000, break; end
  end

  if rem(i,50)==0,
    figure(1) ; subplot(121) ; imagesc(im) ; colormap(gray) ; 
    axis equal ; hold on ; 
    contour(f,[0 0],'r') ; hold off ; colorbar ;
    subplot(122) ; imagesc(f,[-100 100]) ; 
    axis equal ; colormap(jet) ; hold on ; 
    contour(f,[0 0],'k') ; hold off ; colorbar ;
%    subplot(223) ; plot(f(75,:)) ; grid on ;
%    subplot(224) ; plot(step*fu(75,:)) ; grid on ;
    pause(0.01) ;
  end ;
  i = i+1;
end % end of the while loop
disp([ 'Iterations: ' num2str(i) ]) ;

% Usage: div = divergence(x,y)
% Straightforward implementation of the divergence.

function div=divergence(x,y);
  [xx,junk] = gradient(x);
  [junk,yy] = gradient(y);
  div = xx + yy;

% Usage: f = NeumannBoundCond(f)
% This function enforces Neumann boundary conditions, i.e., that
% the (centered) gradient is zero on the boundary. This is not strictly
% necessary but sometimes increases the stability. Note that this
% function depends on the finite-difference discretization scheme used to
% calculate the gradient.

function f = NeumannBoundCond(f)
[nrow,ncol] = size(f);
f([1 nrow],[1 ncol]) = f( [3 nrow-2], [3 ncol-2] );  
f([1 nrow],2:end-1)  = f( [3 nrow-2], 2:end-1 );          
f(2:end-1,[1 ncol])  = f( 2:end-1, [3 ncol-2] );          
 
