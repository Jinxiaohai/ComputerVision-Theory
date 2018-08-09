function labels=regmerge(im,t0,t1,t2,t3) ;
% REGMERGE Region merging via boundary melting
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Segment a grayscale image using region merging via boundary melting
% . Regions are allowed to merge if they
% are separated mostly by `weak edges', where the intensity difference
% between neighboring pixels is at most equal to a threshold
% T_1. Warning: A fast implementation of this algorithm should use data
% structures such as graphs, which are unfortunately extremely slow to
% manipulate in Matlab. Due to these limitation, this implementation is
% slow when applied to large images.
%
% Usage: labels = regmerge(im,t0,t1,t2,t3)
% Inputs:
%  im  [m x n]  Scalar input image.
%  t0  (default 5)  Neighboring pixels with intensity difference at most 
%    T_0 will be merged together to form the initial regions.
%  t1  (default 40)  Neighboring pixels with intensity difference at most  
%    T_1 will be considered as a `weak edge', encouraging merging.
%  t2  (default 0.2)  In the first pass, regions are merged if their common
%    boundary contains at least T_2 min(l_1,l_2) weak edges, where
%    l_1, l_2 are the lengths of their perimeters.
%  t3  (default 0.3)  In the second pass, regions are merged if their common
%    boundary contains at least T_3 l weak edges, where l is the length
%    of their common boundary.
% Outputs:
%  labels  [m x n]  Output labeling. Each pixel position
%    contains an integer 1... N corresponding to an assigned
%    region number; N is the number of regions.
  
% Set default input parameter values, if needed
if nargin<5,
  t3=0.3 ;
end ;

if nargin<4,
  t2=0.2 ;
end ;
  
if nargin<3,
  t1=40 ;
end ;

if nargin<2,
  t0=5 ;
end ;
  

% To determine an initial segmentation we find connected components of pixels,
% where
% we define neighboring pixels as connected if their intensity difference is
% at most T_0. This is done mainly to reduce the initial number of regions
% to speed up the algorithm.  
% We shall use a supergrid-like structure s , 
% this
% time the elements corresponding to pixels and to edges are set to one, the
% rest to zero. The image im is converted to float for the
% arithmetic operations to yield expected results. 
[ny,nx] = size(im);
im = double(im);
s = ones( 2*ny+1, 2*nx+1, 'int32' );
s(1:2:(2*ny+1),:) = zeros( ny+1, 2*nx+1, 'int32' );
s(:,1:2:(2*nx+1)) = zeros( 2*ny+1, nx+1, 'int32' );
s(2:2:2*ny,3:2:(2*nx-1)) = abs(im(:,2:end)-im(:,1:(end-1))) < t0;
s(3:2:(2*ny-1),2:2:2*nx) = abs(im(2:end,:)-im(1:(end-1),:)) < t0;
[l,rmax] = bwlabel(s,4); % find connected regions

% The initial region labels are
% stored to the image data positions in s, the set
% of all region labels used is assigned to r. Weak edges
% determined by the threshold T_1 are marked by -1 in s.
s(2:2:2*ny,2:2:2*nx) = int32( l( 2:2:2*ny, 2:2:2*nx ) );
r = 1:rmax;
s(2:2:2*ny,3:2:(2*nx-1)) = -( abs(im(:,2:end)-im(:,1:(end-1))) < t1 );
s(3:2:(2*ny-1),2:2:2*nx) = -( abs(im(2:end,:)-im(1:(end-1),:)) < t1 );

clear im l 

% The core of the algorithm consists of two passes (determined by
% pass) that only differ in the merging criterion. For each region
% r1 we find all adjacent regions nbr. We do it by growing
% the part of the supergrid corresponding to r1 by one
% pixel and checking for other region labels. The regions are considered in random order as
% this works almost as well as other merging order heuristics and is faster
% to evaluate.  
pass = 1;
while pass<3
  tomerge = []; % will contain the regions to be merged
  for i = randperm( length(r) )
    r1 = r(i);
    b11 = s==r1;
    b13 = grow2(b11); % defined below
    b15 = grow2(b13);
    nbr = setdiff( s(b15), [-1 0 r1] );
    l1 = sum( sum(b13)) - sum(sum(b11) ); % perimeter of r1

% For each region r2 adjacent to r1, determine the
% perimeter l2, common boundary length l and the number of
% weak edges on the boundary w. If the merging condition is
% satisfied, store the labels of the regions to be merged into
% tomerge and exit both for-loops.
    for j = randperm(length(nbr))
      r2 = nbr(j);
      b21 = s==r2;
      b23 = grow2(b21);
      l2 = sum( sum(b23) ) - sum( sum(b21) ); % perimeter of r2
      l = sum( sum(b23 & b13) );              % common boundary length
      w = sum( sum(b23 & b13 & (s==-1)) );    % number of weak edges
      if (w >= t2*min(l1,l2)) || (pass==2 && w>=l*t3)
        tomerge = [r2];
        break
      end
    end % for j loop
    if length(tomerge)>0  % a region to be merged was found
      tomerge = [r1 tomerge];
      break
    end
  end % for i loop
% If no regions to be merged are found, finish the current pass. 
% Otherwise, find all pixels of the new merged region and assign to them the new
% label. Remove the old label from r.
  if length(tomerge)==0
    pass = pass+1;
  else
    b = (s==tomerge(1)) | (s==tomerge(2));
    s(b) = tomerge(1);
    r = setdiff( r, tomerge(2) );
  end
end % while loop

% Renumber regions consecutively starting from one. Note how the region
% label mapping invlabels is applied in parallel to all pixels.
l = s( 2:2:2*ny, 2:2:2*nx ); % extract pixel labels from the supergrid
invlabels = zeros( 1, max(r), 'int32' );
for i = 1:length(r)
  invlabels(r(i)) = i;
end
labels = invlabels(l); % map region labels

% Usage: y = grow2(x)
%
% Function grow2 performs fast morphological dilation
%  with 
% a 3x 3 full structural element. It is faster than generic Matlab
% morphological operations. The auxiliary function grow performs
% dilation in one dimension.
% 
function y = grow2(x);
y = grow( grow(x')' );

function y = grow(x);
  y = x;
  y(:,2:end,:) = y(:,2:end) | x(:,1:(end-1));
  y(:,1:(end-1)) = y(:,1:(end-1)) | x(:,2:end);
return
 
