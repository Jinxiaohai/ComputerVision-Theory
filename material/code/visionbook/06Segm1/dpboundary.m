function x=dpboundary(im) ;
%DPBOUNDARY Boundary tracing using dynamic programming
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Find a minimum-cost connected path between the first and last row of an
% image matrix . A connected path is only allowed to move by
% at most one pixel horizontally for each vertical step. The advantage of
% dynamic programming is that the algorithm is fast and exact
% (not heuristic). While the formulation may seem restrictive,
% a surprisingly large number of segmentation and boundary finding problems
% may be coerced into it.
% 
% Usage: x = dpboundary(im)
% Inputs:
% im  [m x n]  Scalar input image matrix with values
%   representing the cost of a path going through a pixel.
% Outputs:
%  x  [m x 1]  The x (horizontal) coordinates of the
%    optimal path, for y=1... m.
%
%
  
  
% Initialize the matrix c which will contain for each pixel 
% the total cost of an optimal path from the first row (y=1). The matrix
% p corresponds to the `pointers'; it will contain values 
% 1, 2 or 3, meaning that the optimal
% path reaches the current pixel (y,x) from pixel (y-1,x),
% (y-1,x+1), or (y-1,x-1), respectively.
[m,n] = size(im);  
c = zeros(m,n);
p = zeros(m,n,'int8');  % save memory by using 8bit integers
c(1,:) = im(1,:);

% The first pass of the algorithm goes through the image matrix c
% from the
% first to the last row. For each row of c, 
% we assemble a matrix d; each row of d
% corresponds to one alternative (no shift, left shift, right shift)
% and contains the cost of reaching the current row of c. 
% Note how the optimal choice is found in parallel for the whole row
% using the vectorized min function. The boundary cases are
% handled by repeating the last element. In case of equal costs, no shift
% variant is preferred.
for i = 2:m
  c0 = c(i-1,:);
  d = repmat( im(i,:), 3, 1 ) + [c0; c0(2:end) c0(end); c0(1) c0(1:(end-1))];
  [c(i,:),p(i,:)] = min(d);
end

% The second part of the algorithm follows the optimal path from the
% `cheapest' node xpos in the last row back to the first row, 
% using the information
% from p and creating x on the way. We take care not to 
% leave the image boundaries.
x = zeros(m,1);
[cost,xpos] = min( c(m,:) );
for i = m:-1:2
  x(i) = xpos;
  if p(i,xpos)==2 && xpos<n
    xpos = xpos+1;
  elseif p(i,xpos)==3 && xpos>1
    xpos = xpos-1;
  end
end
x(1) = xpos;

