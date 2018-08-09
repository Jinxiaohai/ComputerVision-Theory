function k=convexhull(xy,display) ;
%CONVEXHULL Calculate convex hull
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% 
% Find the convex hull of a set of N points in 2D 
% : we implement
% Graham's classic scan algorithm   
% which 
% has optimal (N log N) complexity. The main data structure of
% Graham's scan is a stack, which can be emulated with reasonable 
% efficiency in Matlab
% using arrays. 
% Melkman's algorithm  uses a double
% ended queue (deque) which is more difficult to implement
% efficiently.
%
% Convex hull construction is one of the fundamental computational geometry
% algorithms and we present it here for pedagogical reasons. The
% function convhull will work just as well.  
% 
% Usage: k = convexhull(xy,display)
% Inputs:
%   xy  [2  x N]  Array with x,y coordinates of the N input
%     points. Each column corresponds to one point.
%   display  (default 0)  If set to 1, each iteration of the algorithm is
%     illustrated graphically.
% Outputs:
%   k  [N x 1]  A vector of indices to xy of the points 
%     on the convex hull. 
%     The first point is the point with the smallest x coordinate and we
%     proceed clockwise. The last point is equal to the first point.
%
% We choose to keep collinear points on the resulting convex hull
% boundary, since it permits a slightly simpler implementation.  Changes
% required to do otherwise are minor.
%  

  
if nargin<2
  display = 0;
end

  
% We find a pivot point first with the minimum x coordinate 
% which is guaranteed 
% to be part of the convex hull. (Note that this is only true if collinear
% points are included.)

[m,n] = size(xy);

if m~=2
  error('convexhull: xy must have 2 columns');
end

[xmin,first] = min( xy(1,:) );

% We take the remaining points and sort them according to the direction (azimuth)
% from the pivot, creating an index array ind. This takes
% (Nlog N) time. We use function
% atan2 for convenience to calculate the angles. All angles are
% between -/2 and /2, so phase
% wraparound is not a problem. We add the pivot as
% the last point.

ind = [1:(first-1) (first+1):n];
angle = atan2( xy(1,ind)-xy(1,first), xy(2,ind)-xy(2,first) );
[junk,order] = sort(angle);
ind = [ind(order) first];



% A stack is emulated using an array stack and an index
% stacktop of the top stack element. Since we know the maximum
% stack size to be N, we initialize the stack array to avoid
% time consuming reallocations. 
% 
% The stack will contain indices of points that so far are considered to
% be part of the convex hull. The initial stack contains the pivot.

stack = zeros( n, 1, 'uint32' );
stack(1) = first;
stacktop = 1;

% Here is the main while-loop of the algorithm. The current
% point from the input set xy is indexed by ind(i). 
% The loop terminates when all points have been considered.
%

% A current point p2=xy(:,ind(i)) is pushed to the stack if it
% contains less than two points, or if the point p2 lies on or to the right of the
% line connecting the two top points of the stack (p0, p1). 
% This is determined by calculating the vector product of (p1-p0)
% x (p2-p0).
% Otherwise, the top
% point from the stack is discarded, because it cannot belong to the
% convex hull. In other words, the 
% hull boundary must go straight or turn right, it may never turn to the left.


i = 1;
while i<=n

if display==1,  
  figure(1) ;
  plot(xy(first,1),xy(first,2),'rx',[xy(first,1) ; xy(ind,1)],[xy(first,2) ...
                    ; xy(ind,2)],'o--',xy(stack(1:stacktop),1),xy(stack(1:stacktop),2),'g-',xy(ind(i),1),xy(ind(i),2),'md','LineWidth',2,'MarkerSize',7) ;

  disp([ 'Stack = ' num2str(stack(1:stacktop)') ]) ; 
  disp('Press any key') ;
  pause
end ;


  if stacktop<2
    stacktop = stacktop+1;
    stack(stacktop) = ind(i);
    i = i+1;
  else
    p0 = xy(:,stack(stacktop));
    p1 = xy(:,stack(stacktop-1));
    p2 = xy(:,ind(i));
    if (p1(1)-p0(1))*(p2(2)-p0(2))-(p2(1)-p0(1))*(p1(2)-p0(2)) >= 0
      if display==1,
        disp('push') ;
      end ;
      stacktop = stacktop+1;
      stack(stacktop) = ind(i);
      i = i+1;
    else
      if display==1,
        disp('pop') ;
      end ;
      % pop
      stacktop = stacktop-1;
    end
  end
end % while loop

if display,
  figure(1) ;
  plot([xy(1,first)  xy(1,ind)],[xy(2,first)  xy(2,ind)],'bo-',...
       xy(1,first), xy(2,first),'ro','LineWidth',2,'MarkerSize',7) ;
 if display>1,
    exportfig(gcf,'output_images/convexhull_fan.eps') ;
 end ;

figure(2) ;
plot(xy(1,:),xy(2,:),'bo',xy(1,stack(1:stacktop)),xy(2,stack(1:stacktop)),...
     'g-',xy(1,first), xy(2,first),'ro','LineWidth',2,'MarkerSize',7) ; 

 if display>1,
    exportfig(gcf,'output_images/convexhull_small.eps') ;
 else
   disp('Algorithm has converged.') ;  disp('Press any key') ;
   pause
 end ;
end ;

% The stack now contains the completed convex hull. Because each input point
% is pushed to the stack and discarded at most once, the computational
% complexity of the while-loop is linear.

k = stack(1:stacktop);

