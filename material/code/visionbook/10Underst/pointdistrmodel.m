function [P,pmean,lambda]=pointdistrmodel(pts,alpha,show) ;
% POINTDISTRMODEL Create a point distribution model from examples
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%  
% The point distribution model  describes a family of shapes by
% their mean and a small number of eigenvectors. The shapes
% are represented by landmark coordinates on their contours.
% We show here how to automatically create the statistical description
% from a set of training examples .
%    
% Usage: [P,pmean,lambda] = pointdistrmodel(pts,alpha)
% Inputs:
%   pts  [2N x M]  A set of M training shapes. Each column
%     corresponds to one shape and contains alternating x and y
%     coordinates of  N landmarks describing the shape: 
%     [x_1,y_1,x_2,y_2,...,x_N,y_N].
%   alpha  (default 0.95)  The constant 0 alpha 1
%     determines how much variation of the input data is captured
%     by the reduced model .
% Outputs:
%   P  [2N x K]  The most important eigenvectors P of the model,
%     corresponding to the K largest eigenvalues. The ordering of the
%     eigenvectors in P corresponds to the ordering of the
%     eigenvalues lambda.
%   pmean  [N x 1]  The mean shape .
%   lambda  [K x1]  K largest eigenvalues lambda_i, 
%     sorted in decreasing order.
% 
% On return, the mean shape pmean is aligned with the first
% training shape pts(:,1). Modified shapes can be obtained as
% pmean + P b.
%
  
if nargin<3,
  show=0 ;
end ;
  
if nargin<2,
  alpha=0.95 ;
end ;

% Start by aligning all other shapes with the first shape using function
% pointalign. The mean
% pmean is calculated by averaging the transformed shapes.

[n,m] = size(pts);

if show>0
  hold on
end

for i = 2:m
  pts(:,i) = pointalign( pts(:,1), pts(:,i) );
end
pmean = mean( pts, 2 );

% We iterate in the main while-loop until the change of the mean
% shape between iterations as measured by r (in pixels) becomes
% smaller than a predefined threshold. The convergence is fast,
% so a fixed threshold can be used.
r = inf;
while r<1e-6
% In the main loop, we repeatedly align the mean shape pmean 
% to the first shape pts(:,1),
% align all other shapes to the mean shape pmean, 
% and recalculate the mean.
  pmean = pointalign( pts(:,1), pmean );
  for i = 2:m
    pts(:,i) = pointalign( pmean, pts(:,i) );
  end

  oldmean = pmean;
  pmean = mean( pts, 2 );
  r = norm( (oldmean-pmean)/n );

  disp(['point distr model r=' num2str(r) ]) ;
end % while loop

if show>0,
  for i=1:m,
    drawcontour(reshape(pts(:,i),2,[]),3) ;
  end ;
end ;

% The covariance matrix S is calculated from the differences
% from the mean shape deltap. We calculate its eigenvalues
% lambda and eigenvectors P.

deltap = pts - repmat(pmean,1,m);
S = cov(deltap');
[P,D] = eig(S);
lambda = diag(D);

% Finally, we simplify the model by considering only the K largest
% eigenvalues, with the smallest K such that 
% sum_^K lambda_i  alpha sum_^N lambda_i.
% Note that the function eig returns the eigenvalues in
% increasing order, so we need to consider the K last ones and reverse them.

limit = alpha*sum(lambda);
K = n;  partsum = lambda(K);
while K>1
  if partsum>limit, break; end
  K = K-1;  partsum = partsum+lambda(K);
end
lambda = lambda(end:-1:K);
P = P(:,end:-1:K);

