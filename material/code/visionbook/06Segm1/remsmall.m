function p=remsmall(im,l,t) ;
% REMSMALL Removal of small regions
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Removal of small regions  
% is a useful post-processing
% operation for segmentation techniques such as region merging
% since small regions often correspond to
% segmentation errors. The difference of region mean values is used to
% determine which regions to merge.
%
% Warning: This implementation is slow for a large number of
% regions. However, as the initial number of regions is usually small,
% this is normally not a problem. 
%
% Usage: p = remsmall(im,l,t)
% Inputs:
%  im  [m x n]  Scalar input image.
%  l  [m x n]  Initial segmentation; each pixel position
%    contains a positive integer region label.
%  t  (default 10)  The maximum area of a region to be merged.
%  Outputs:
%  p  [m x n]  Output segmentation;  each pixel position
%    contains an integer 1... N corresponding to an assigned
%    region number; N is the number of regions.

if nargin<3,
  t=10 ;
end ;

  
[m,n]=size(im) ;
[ml,nl]=size(l) ;
if (m~=ml || n~=nl),
  error('Size of f and l must be the same') ;
end ;

% The core of the algorithm is repeated as long as there are
% regions to merge. We determine the size and mean of each region and
% store them to rsize and rmean, respectively. Since not
% all region labels might be assigned, we also need a mapping
% invlabels from region labels to the indices of rsize
% and rmean. 
lmax = max( max(l) );
while true
  labels = unique( l(:) );
  rmean = zeros( 1, length(labels) );
  rsize = zeros( 1, length(labels) );
  invlabels = zeros( 1, lmax, 'int32' );
  for i = 1:length(labels)
    j = labels(i);
    invlabels(j) = i;
    b = (l==j);
    rsize(i) = sum(sum(b));
    rmean(i) = sum(im(b)) / rsize(i);
  end % for loop



  

% We find the size rmin and label labelmin of the
% smallest region. If it is bigger than a threshold, we are done.
  [rmin,ind] = min(rsize);
  if rmin>t || length(labels)<2, break; end
  labelmin = labels(ind);
% Identify the neighboring regions nbr of labelmin
% by growing the bitmap by one pixel and checking for other region labels
% (as in Section ??, where the function
% grow2 is defined).
  b = (l==labelmin);
  b3 = grow2(b);
  nbr = setdiff( l(b3), labelmin );

% The neighboring region with the closest mean to labelmin 
% is found and the two
% regions are merged by assigning the label of the second
% region to the first. We repeat the while-loop to consider
% further regions to merge. 
  % Find all neighboring regions
  % Find the region with the closest mean

  [meanmin,indj] = min( abs(rmean(invlabels(nbr))-rmean(invlabels(labelmin))) );
  l(b) = nbr(indj);
end % while loop

% As at the last step, the regions are renumbered starting from one.

p = invlabels(l);


% Note that we can avoid recalculating the region parameters in each
% iteration by calculating the size and mean of the merged region from
% the sizes and means of its constituents. This is left as an exercise to
% the reader.

function y=grow(x);
  y = x;
  y(:,2:end,:)   = y(:,2:end) | x(:,1:(end-1));
  y(:,1:(end-1)) = y(:,1:(end-1)) | x(:,2:end);
return

function y=grow2(x);
  y = grow(grow(x')');
return

