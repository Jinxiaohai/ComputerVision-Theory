function [best_model,inliers]=ransac(x,m,get_model,get_inliers,...
                               zeta,maxit,xi,verbosity) ;
% RANSAC Random Sample Consensus
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% 
% RANSAC  is a stochastic parameter
% estimation technique which is especially useful for data containing
% a large number of outliers. The implementation described here extends the
% basic version  by automatic
% estimation of the number of iterations to perform. Whenever an iteration
% is successful, the number of points Q consistent with the currently best
% model (the number of inliers) is used to calculate an estimate of the inlier ratio
%  xi=Q/N, where N is the total number of data points. 
% zeta is the acceptable failure probability and 
% M is the number of data points used to determine the model
% parameters.
% 
% The interface between the RANSAC core and the particular model to be
% determined consists of two user-provided functions: 
% get_model calculates the
% model parameter from a small part (sample) of the data and
% get_inliers determines which data points are consistent with 
% a given model.
%
% {[best_model,inliers] =
%   ransac(x,m,get_model,get_inliers,zeta,maxit,xi,verbosity)}
% Inputs:
%   x  [d x N]  Input data matrix. Each column is one
%     d-dimensional data point.
%   m  1x1  The number M of points used to determine the model parameters.
%   get_model    A function called as
%     model=get_model(sample), where sample is
%     a randomly selected subset of M columns from x and model 
%     contains the model parameters determined from sample.
%   get_inliers    A function called as inl=get_inliers(x,model)
%     where x is the input data matrix and model describes
%     the model to evaluate. 
%     The binary row vector inl should contain 1 for each
%     column of x that is considered to be an inlier, i.e.,
%     consistent with the model.
%   zeta  
%   (default 10^-3)
%     The probability zeta of RANSAC not finding the
%     correct solution that we are ready to accept. It is used to determine
%     the number of iterations to perform. Larger values 
% (10^-2)
%     make the algorithm run somewhat faster at the expense of
%     an increased failure ratio.
%   maxit  (default 10^4)  The maximum number of iterations to perform unless
%    K from equation (??) stops us first.
%  xi  (default 0)   An initial estimate of the inlier ratio  xi=Q/N.
%    The value is not critical since  xi is re-estimated after each
%    succesful iteration.
%  verbosity  (default 0)  If set to 2, progress is reported after each
%    iteration. If set to 1, there is only one message at convergence. 
%    The corresponding code is omitted here.
% Outputs:
%  best_model   The best model parameters found, as returned by
%    get_model. 
%  inliers  [1 x N]  A binary row vector determining inliers (data points
%    consistent with the model), as returned by get_inliers.
               
if nargin<8,
  verbosity=0 ;
end ;

if nargin<7,
  xi=0 ;
end ;

if nargin<6,
  maxit=10000 ;
end ;

if nargin<7,
  zeta=0.001 ;
end ;

% We initialize the iteration counter iter and the best-so-far model 
% parameters (best_model, best_support, inliers).
% The number of iterations to perform is estimated using function
% numiters that implements Equation ??.


[d,n] = size(x);
iter  = 0;
best_model   = [];
best_support = 0;
inliers = [];
maxiter = min( maxit, numiters(xi,zeta,m) );

% The main loop starts by randomly drawing a set ind
% containing M unique numbers from 1... N. It is used to 
% get the M-column subset sample of x.

while iter<maxiter
  ind = randsample( n, m );
  sample = x(:,ind);

% If the function randsample is not available (because
% it belongs to Matlab's Statistical toolbox) we can use
% ind=randperm(n); ind=ind(1:m) instead at the expense of
% some slowdown.
  
% We calculate the model parameters and the corresponding support (number
% of data points consistent with the model) by calling the user-provided 
% functions get_model and get_inliers.

  model = get_model( sample );
  inl = get_inliers( x, model );
  support = sum(inl);
% If the support is smaller than M, there is something wrong, so we
% alert the user.
  if support<m
    warning('ransac: Support of the generated model is smaller than M.')
  end

  if verbosity>1
    disp(['Iter:' num2str(iter) ' support=' num2str(support) ... 
          ' maxiter=' num2str(maxiter) ]) ;
    fid = visualize_line(10,x,ind,inl,inliers,model,best_model,iter,maxiter,min(maxiter,numiters(support/n,zeta,m)),0);
   end

% If the current model is better than the best model so far, we
% update the best model parameters and the number of iterations 
% maxiter.
  

  if support>best_support
    best_support = support;  best_model = model;  inliers = inl;
    xi = support/n;
    maxiter = min( maxit, numiters(xi,zeta,m) );
   if verbosity>1,
     disp(['Iter:' num2str(iter) ' new best_support=' num2str(support) ...
           ' new maxiter=' num2str(maxiter) ]) ;
   end
  end
% We increment the iteration counter and loop again.
  iter = iter+1;
end % while loop

if verbosity>0
  disp(['Ransac finished. iter=' num2str(iter) ' support=' num2str(best_support) ]);
end
  

%  Usage: iters = numiters(xi, zeta, m)
% 
% Function numiter determines the total number of iterations to
% perform from equation (??). Parameter
% xi is the inlier ratio and zeta the acceptable
% failure probability.

function iters = numiters(xi, zeta,m)

if xi<eps
  iters = Inf;
else
  iters = max( 1, ceil( log(zeta)/log(1-xi^m) ) );
end

