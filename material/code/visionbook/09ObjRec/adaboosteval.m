function y=adaboosteval(weaks,alpha,weakeval,x,nosign) ;
% ADABOOSTEVAL evaluate the classifier created by AdaBoost
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% This function applies the strong classifier (??)
% created by adaboost.
% 
% Usage: y = adaboosteval(weaks,alpha,weakeval,x,nosign)
% Inputs:
%   weaks  [1 x K]  An array of structures describing K weak classifiers
%     as returned by adaboost.
%   alpha  [1 x K]  Coefficients alpha_k as returned by 
%     adaboost.
%   weakeval    The same function to evaluate the weak classifiers as
%     supplied to adaboost.
%   x  [d x n]  Input data x_i to classify. Each column
%     corresponds to one input vector.
%   nosign  (default 0)  If set to 0, the classification result 
%   S(x) (??) is returned. If set to 1, the raw score 
%   f(x) (??) is returned instead.
% Outputs:
%   y  [1 x n]  The resulting classification S(x) (??)
%     or the raw score f(x) (??) (see
%     parameter nosign).
% See also: adaboost.
%
% The implementation of (??) is straightforward. It is
% enough to cycle over the weak classifiers W_k, as weakeval 
% is vectorized - it evaluates each W_k for all x_i.
%
  
if nargin<5,
  nosign=0 ;
end
  
nweaks = size( weaks, 2 );
nx = size( x, 2 );
ev = zeros( nweaks, nx );
for k = 1:nweaks
  ev(k,:) = alpha(k) * weakeval(weaks(k),x)';
end
y = sum( ev, 1 );
if nosign==0
  y = sign(y);
end
