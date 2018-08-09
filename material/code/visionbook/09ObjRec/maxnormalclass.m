function y=maxnormalclass(X,model) ;
% MAXNORMALCLASS maximum probability classification for normal data
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%   
% This multi-class classifier 
% models the probability distributions of feature vectors for each
% class as normal. The parameters of these normal distributions are
% estimated from the training data. This is implemented in 
%   function
% mlcgmm.{For help see file
% matlab_code/stprtool/doc/manual/probab/estimation/mlcgmm.html.}
%
% In the classification phase, we evaluate for each test object (vector) and
% each class the probability that the object belongs to a particular
% class. The object is assigned to the class with the highest probability.
% 
% Note that this algorithm is prone to numerical problems if the features
% have vastly different scale or if the dimension of the feature space
% is too large. In this case, normalization and feature selection
% should be employed. 
% Note also that this implementation estimates a priori probabilities for
% the classes from the training data. Hence, it is assumed that the
% distribution of classes in the training data is representative of the
% total distribution of classes. 
%  
% See Section ?? for an example of how to use
% this classifier.
% 
% Usage: y = maxnormalclass(X,model)
% Inputs:
%   X  [d x N]  Input feature vectors. Each of the N columns
%   represents d features for one object.
%   model  struct  Gaussian distribution parameters for all classes
%   as returned by mlcgmm,  .
%   model.Mean  [d x M]  Means of the Gaussians, M is the number of classes.
%   model.Cov  [d x d x M]  Covariance matrices of the Gaussians.
%   model.Prior  [M x 1]  Prior probabilities.
%   y  [1 x N]  The estimated class labels for all input vectors, y
%   {1... M}.

% The core of the implementation is the  function pdfgauss 
% which evaluates for all input vectors
% and for all classes the probability that an object belongs to
% a particular class. The maximum is then selected.

p = pdfgauss( X, model );
[junk,y] = max( p );


