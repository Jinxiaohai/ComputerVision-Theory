function ind=nnmatch(x,y) ;
% NNMATCH
%   CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Usage: ind = nnmatch(x,y)
% Given two matrices x, y with the same number of columns,
% we calculate a mapping vector ind, such that  
% x(ind(i),:) is the row in x closest to 
% y(i,:) in the NN sense using Euclidean l_2 distance.
% 
% This routine assumes that all vectors in y (in our case each
% represents an object) have a counterpart
% in x. If this is not true, we can define a maximum distance threshold
% beyond which the vectors (objects) are classified as `unknown'.
  
[nx,mx] = size(x);
[ny,my] = size(y);

if mx~=my
  error('Number of columns must be the same');
end

% Note the use of repmat to calculate the distance from
% y(i,:) to all rows in x at once.

for i = 1:ny
  d = sum( (x-repmat(y(i,:),nx,1)).^2, 2 );
  [dmin,j] = min(d);
  ind(i) = j;
end
