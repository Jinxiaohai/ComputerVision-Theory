function [p,theta,s,tx,ty,b]=asmfit(...
    im,pmean,P,lambda,theta0,s0,tx0,ty0,width,rtol,display) ;
% ASMFIT active shape model --- fit the pointdistrmodel
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% 
% In Section ??, we have seen
% a function pointdistrmodel that
% creates a point distribution model (PDM) from a set of training
% shapes. Here we show how to  fit the learned point distribution model
% to a given image . It is a segmentation method similar 
% to active contours such as snakes (Section ??).
% 
% The method is useful for images with pronounced
% edges that correspond well to the learned PDM. It is based on examining
% a narrow band around the current shape for improved landmark
% positions. The method is relatively fast
% but  requires a good guess of the initial position. 
% 
% The fitted shape is given by its pose parameters theta, s, t_x,
% t_y and shape parameters b 
% the mean shape  and principal eigenvectors  P 
% are provided by pointdistrmodel.
% 
% {[p,theta,s,tx,ty,b] =
%   asmfit(im,pmean,P,lambda,theta0,s0,tx0,ty0,width,rtol,display)}
% Inputs:
%   im  [m x n]  Input image, normally an edge map. The higher
%     the value, the larger the probability of a pixel being an edge.
%     Zero value pixels are considered background.
%   pmean  [N x 1]  The mean shape , 
%     as returned by pointdistrmodel.
%   P   [2N x K]  Principal shape eigenvectors, 
%     as returned by pointdistrmodel.
%   lambda  [K x1 ]  Principal eigenvalues, 
%     as returned by pointdistrmodel.
%   theta0  1x1  Initial pose rotation parameter theta (??). 
%   s0  1x1  Initial pose scaling parameter s (??). 
%   tx0,
%   ty0  1x1  Initial pose translation parameters t_x, 
%     t_y (??). 
%   width  (default 10)  Width of the band around the current shape
%     position to be searched in each iteration, in pixels. 
%   rtol  (default 0.5)  Threshold on the maximum change of landmark
%     coordinates to determine convergence.
%   display  (default 1)  Set to 1 for animation of the fitting
%     procedure, 0 otherwise. The corresponding code is
%     not included below.
% Outputs:
%   p  [2N x 1]  Final fitted shape p=[x_1,y_1,...,x_N,y_N].
%   theta  1x1  Parameter theta of the final pose (??).
%   s  1x1  Parameter s of the final pose (??).
%   tx,ty  1x1  Parameters t_x, t_y of the final pose (??).
%   b  [K x 1]  Final shape parameters b (??). 
% See also: pointdistrmodel.
%

if nargin<11,
  display=1 ;
end ;

if nargin<10,
  rtol=0.5 ;
end ;
  
  
if nargin<9,
  width=10 ;
end ;

% Initialize pose parameters theta, s, tx,
% ty and shape parameters b. Variable pold is
% used in the stopping criterion and stores the previous value of p;
% iter is the iteration counter.

theta = theta0;  s=s0;  tx = tx0;  ty = ty0;
b = zeros( size(P,2), 1 );
[n,junk] = size(pmean);
pold = pmean;
iter = 1;

% The main cycle is repeated until the change r of landmark positions
% between iterations decreases below the threshold rtol.
while true
  p = pointtransf( P*b+pmean, theta, s, tx, ty );
  r = max( abs(p-pold) ); 
  if (iter>1 && r<rtol) || iter>1000, break; end
  pold = p;
  if display>0
    figure(1)
    imagesc(im) ; colormap(1-gray) ; axis image ;  hold on ;
    drawcontour(reshape(p,2,[]),2) ;
  end
  
% For each landmark we find a line (described by a vector
% qx, qy) normal to the shape contour at that point using 
% function perpendicular. We evaluate the edge map im
% for values v on the line qx, qy with step 1. 
% The new landmark position pnew is the position of the maximum 
% in v, unless the maximum is zero - in this case we are in
% a background region with no edges and the landmark is not moved.
% Note how the x, y coordinates need to be extracted from and stored
% into the 1D vectors p, pnew.

  t = -width:1:width;
  pnew = p;
  for i = 1:n/2
    x = p(2*i-1);  y = p(2*i);
    if display>0,
      plot(x,y,'ob') ;
    end ;
    [qx,qy] = perpendicular( p, i );
if display>0
    plot(x+qx*t,y+qy*t,'g-') ;
end
    v = interp2( im, x+qx*t, y+qy*t, '*linear' );
    [maxv,j] = max(v);
    xn = x+qx*t(j);  yn = y+qy*t(j);
    if maxv>0
      pnew(2*i-1:2*i) = [xn yn];
      if display>0,
        plot(xn,yn,'or') ;
      end
    end
  end % for i
  
% Once the new proposed landmark positions pnew are known,
% we call pointalign to find new pose parameters
% theta, s, t_x, t_y.

  [ptransf,theta,s,tx,ty] = pointalign( pnew, P*b+pmean, theta0 );

  
% To find new shape parameters b, we first transform the 
% landmark positions pnew into the original (canonical) 
% coordinate space
% by applying an inverse transform using function pointtransfinv.
% The difference from the mean shape pmean is then projected
% into the space spanned by the modes using the orthogonality of 
% P .
  porig = pointtransfinv( pnew, theta, s, tx, ty );
  b = P'*(porig-pmean);


  if display>0,
    hold off ;
    if iter==1,
      exportfig(gcf,'output_images/asmfit2.eps') ;
    end ;
    disp(['iter=' num2str(iter) ' r=' num2str(r)]) ;
  end ;  

% We repeat the whole loop until convergence.
  
  iter = iter+1;
end % while loop  

function [qx,qy]=perpendicular(p,i) ;
%  Usage: [qx,qy] = perpendicular(p,i)
% 
% Function perpendicular finds a unitary vector (qx, qy) 
% perpendicular to the boundary described by points p at point
% number i. Indexes of neighbors used to calculate the
% normal direction - normally the left and right neighbors, except for the
% first and last points - are im, ip, with
% coordinates (xm, ym) and (xp, yp). 
 
[n,junk] = size(p);
im = max( 1, i-1 );
ip = min( n/2, i+1 );
xm = p(2*im-1);  ym = p(2*im);
xp = p(2*ip-1);  yp = p(2*ip);
qx = yp-ym;
qy = xm-xp;
mag = sqrt( qx*qx + qy*qy );  % normalize length to 1
qx = qx/mag;  qy = qy/mag;

