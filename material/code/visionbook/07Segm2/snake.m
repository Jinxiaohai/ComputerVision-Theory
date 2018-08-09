function [x,y] = snake(x,y,alpha,beta,kappa, lambda, fx,fy,maxstep, displ,img)
% SNAKE Active contour (snake) segmentation
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Active contours, informally called snakes, are a powerful 
% semi-automatic image segmentation tool. In anticipation of GVF snakes
%   we implement here a traditional
% balloon-force snake using a PDE approach. 
%   
% The snake v(s) at time t is represented by two vectors
% containing the x and y coordinates of a sequence of points on the
% snake curve. The distance between subsequent points is maintained 
% close to 1 pixel. The snake is supposed to be closed and simple 
% (non-intersecting). If a snake starts to intersect itself, the user is
% expected to restart the evolution with smaller forces (reduced
% parameter values).
%  
% {The code presented here is derived from the work of Xu and
% Prince  and their publicly available implementation 
% (http://iacl.ece.jhu.edu/projects/gvf/).}
%
% Usage: [x,y] = snake(x,y,alpha,beta,kappa,lambda,fx,fy,maxstep)
% Inputs:
%   x, y  [N x 1]  Vectors containing the x and y
%     coordinates of the initial snake position. The snake is
%     closed - the last point is considered a neighbor of the first.
%     Points can be far apart and will be 
%     interpolated as needed. The contour should be given 
% clockwise (with respect to Matlab image axis conventions),
%     otherwise the balloon force will change sign.
%   alpha  [1 x 1]  alpha controls the elasticity;
%     the higher the value, the less stretching the snake
%     will allow. alpha 0.1 is a good value.
%   beta  [1 x 1]  beta controls the rigidity, the
%     resistance to bending. Make it small for the snake to follow
%     a jagged boundary, beta=0  to  0.1 works well.
%   kappa  [1 x 1]  kappa weights the contribution
%     of the external force f_ that  stops
%     the snake once it arrives at the desired boundary. Make
%     kappa bigger for the snake to stop sooner.
%     kappa=0.1  to  0.5 give good results.
%   lambda  [1 x 1]  lambda weights the contribution of the balloon
%     force. Positive values make the snake expand. lambda
%     0.05 works well.  
%   fx, fy  [m x n]  External force field, normalized to 
%    maximum magnitude 1. Both fx and fy are
%     scalar matrices corresponding to the original image.
%   maxstep  (default 0.4)
%            Maximum step-size in pixels. 
%     Reducing it in difficult cases might help to prevent the snake from
%     crossing over.
% Outputs:
%   x,y  [N x 1]  The x and y coordinates of the final
%   position of the snake. The distance between subsequent points
%   is close to 1 pixel.
  
% If displ is non zero than once in 10 iterations we display
% the current position of the snake on the background image img
if nargin<10,
  displ=0 ;
end ;

% Set default parameters, if needed.
if nargin<9,
  maxstep=0.4 ;
end ;


x = x(:);  y = y(:);  % convert to column vectors
h = [-beta 4*beta+alpha -6*beta-2*alpha 4*beta+alpha -beta];
areas = [];

iter = 0;

%  We iterate in a while-loop until convergence. We resample
%  the snake if needed by function resample 
%  to maintain uniform distances between points. We use interpolation
%  by interp2 to evaluate the external force f_ at the snake points.
%  If the snake leaves the image area, we stop.
while true
  [x,y] = resample( x, y, 0.9 );
  vfx = interp2( fx, x, y );
  vfy = interp2( fy, x, y );
  if any( isnan([vfx(:); vfy(:)]) ), break; end

  iter=iter+1 ; % increment iteration counter
  if displ && rem(iter,10)==0
    clf ; imagesc(img) ; colormap(gray) ; hold on ;
    plot([x;x(1,1)],[y;y(1,1)],'r') ; hold off ;
    pause(0.01);
  end

% The evaluation of the balloon force f_ starts by 
% calculating the tangential vector 
% The derivative is approximated by finite differences while observing
% the periodic boundary conditions. We then create a unit vector p
% (px,py),
% perpendicular to q.
  xp = [x(2:end); x(1)];      yp = [y(2:end); y(1)]; 
  xm = [x(end); x(1:end-1)];  ym = [y(end); y(1:end-1)]; 
  qx = xp-xm;     qy = yp-ym;
  pmag = sqrt( qx.*qx + qy.*qy );
  px = qy./pmag;  py = -qx./pmag;

% Testing for convergence is delicate. Because of the fixed time step
% used and discretization artifacts, the snake frequently starts to
% oscillate around the equilibrium position with small amplitude.
% The oscillations could be avoided by a more elaborate integration scheme, 
% but this would increase the computational cost. An alternative approach is
% to analyze snake movement in the last few iterations and stop if no
% progress is being made. As curve distance computation is
% expensive, we use a trick based on the fact
% that the snake is always supposed to either grow or shrink. We
% evaluate the area inside the snake in the last 10 iterations and if the
% change is smaller than one pixel, we stop. 
% Note that the area is quite simple to compute.
  area  = sum( 0.5*(xp+xm).*qy );
  areas = [areas area];
  if length(areas)>10
    areas=areas(end-9:end);     % keep last 10 areas
    if max(areas)-min(areas)<1, break; end
  end
  
%  We proceed to calculate the total force (xd, yd) acting
%  on the snake. Note how the elasticity and stiffness contribution is 
%  calculated using a convolution. The function convs, defined below,
%  respects the periodic boundary conditions. 
%
%  Updating the snake coordinates finishes the loop. As a safeguard, we shorten
%  the step-size (step) if the default size 1 causes some
%  points to move further than maxstep pixels (0.4 by default).
%  For recommended parameter values, this restriction is normally not
%  applied, only when the snake initialization is noisy or has sharp edges.

  xd = convs(x,h) + kappa*vfx + lambda.*px;
  yd = convs(y,h) + kappa*vfy + lambda.*py;
  maxd = max([xd; yd]);
  step = min( 1, maxstep/maxd );
  x = x + step*xd;
  y = y + step*yd;
end % while-loop

% Usage: xc = convs(x,h)
% 
% Function convs calculates the convolution of x with 
% h, treating x as periodic. The kernel h is
% expected to have an odd length and is considered to be centered.

function xc = convs( x, h );

  N  = length(h);  N2 = (N-1)/2;
  xc = conv( [x(end-N2+1:end); x; x(1:N2)], h );
  xc = xc(N:end-N+1);

% Snake resampling  
%
% Usage: [xi,yi] = resample(x,y,step)
%
% Function resample takes a snake and resamples it if
% necessary
% so that the distance between points is equal to step, returning
% the new representation. Note that some implementations do not resample
% the snake on each iteration, but only each 5 or 10 iterations. This
% leads to computational savings at the expense of some robustness. 
% Note also that changing the inter-point spacing changes the scaling
% constants of 
% our discrete approximation of the elasticity and stiffness.
%


function [xi,yi]=resample(x,y,step) ;

% The point vectors are made circular and distances between points are
% calculated. The arc length distances from point 1 to all other points
% are stored in d.
  
  N  = length(x);  
  xi = x;  yi = y;
  x  = [x; x(1)];  % make a circular list
  y  = [y; y(1)];
  dx = x(2:end) - x(1:N);
  dy = y(2:end) - y(1:N);
  d  = sqrt( dx.*dx + dy.*dy );  
  d  = [0; d];     % point 1 to point 1 distance is 0 
  d  = cumsum(d);  % the arc length distances from point 1
  
% If the length is unchanged, we are done. Otherwise, new snake points
% are calculated by interpolating from the old ones. 
  maxd = d(end);
  if abs(maxd/step-N)<1, return; end
 % disp('Skip update') ;
  
  si = (0:step:maxd)';
  xi = interp1( d, x, si );
  yi = interp1( d, y, si );
% Finally,
% we discard the last point of the list if it is too close to its
% neighbor, the first point of the list.
  if maxd-si(end) < step/2
    xi = xi(1:end-1);
    yi = yi(1:end-1);
  end

