function ind=goodfeatures(data,n) ;
% GOODFEATURES select good features for haralick_demo
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Usage: ind=goodfeatures(data,n)
% 
% Function goodfeatures takes data, which is a structure with
% fields X (feature vectors) and y (labels), as expected
% by mlcgmm , and chooses n `best' ones. 
% The feature
% vectors are assumed normalized, i.e., each feature should have
% zero mean and unit variance. 
% 
% Feature selection is a difficult problem.
% For simplicity, we use the ratio of intra-class and inter-class variance.
% Since we have normalized for inter-class (total) variance, 
% we can calculate the total intra-class variance and choose n features
% with the smallest intra-class variance. 
  
k = max( data.y );
sumv = zeros( size(data.X,1), 1 );
for y = 1:k
  ind = (data.y==y);
  sumv = sumv + var(data.X(:,ind)')';
end
[junk,ind] = sort( sumv );
ind = ind(1:n);
