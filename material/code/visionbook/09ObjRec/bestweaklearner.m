function [best_weak,minerr] = bestweaklearner(x,y,D,weaklearner,weakeval,features) ;
% ADABOOSTEVAL evaluate the classifier created by AdaBoost
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
%
% Usage: [best_weak,minerr] = bestweaklearner(x,y,D,weaklearner,weakeval,features)
% Inputs:
%   x  [d x m]  Training data x_i, i=1... m. Each column
%     corresponds to one input vector.
%   y  [1 x m]  Training data classification  y_i.
%   D  [1 x m]  Weights D(i) (??)
%   weaklearner    A function to be called as
%     weak=weaklearner(x,y,D,f) that provides a weak classifier
%     weak (to be used by weakeval,
%     see adaboost) given training data x, classifications
%     y, weights D, and a column vector f describing
%     the feature to use.
%   features  [d_F x F]  F-column vectors of length d_F, each
%     corresponding to a single weak classifier feature.
% Outputs:
%   best_weak  struct  The best of the weak classifiers tested.
%   minerr    The weighted classification error
%     epsilon (??) of the best weak classifier.
% See also: adaboost.
% Function bestweaklearner evaluates a group of weak classifiers by
% successively passing features f from a given set
% features to a given weak classifier generator weaklearner.
% It is suitable to be used with adaboost as its
% bestweak functional parameter in all situations when there is
% a fixed set of features to be tried.
% 
% The implementation is straightforward: In a cycle we test all features,
% for each of them a weak classifier is constructed and its performance
% (err=epsilon) is evaluated. The best classifier is kept.  

  
minerr = inf;
for f = features % loop over all columns
  weak = weaklearner( x, y, D, f );
  e = weakeval( weak, x );
  err = sum( D.*(sign(e)~=y) );
  if err<minerr
    best_weak = weak;
    minerr = err;
  end
end
