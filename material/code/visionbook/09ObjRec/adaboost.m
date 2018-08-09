function [weaks,alpha]= ...
    adaboost(x,y,bestweak,weakeval,testerr,maxiters,display,displayfun) ;
% ADABOOST adaptive boosting  
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% 
% Adaptive boosting  is
% a supervised greedy learning procedure. It 
% creates a strong classifier for a binary classification problem 
% from a large number of user-provided weak classifiers. It can be
% extended to the multi-class case. Here, strong
% implies low classification error while weak classifiers can be
% only slightly better than random guessing. 
% This implementation is based on a code developed by 
%   Jan Sochman \url{http://cmp.felk.cvut.cz/~sochmj1}.
%
% {[weaks,alpha,errbound] = adaboost(
%       x,y,bestweak,weakeval,testerr,maxiters,display)}
% Inputs:
%   x  [d x m]  Training data x_i, i=1... m. Each column
%     corresponds to one input vector.
%   y  [1 x m]  Training data classification  y_i.
%     bestweak    A function called as weak=bestweak(x,y,D) 
%     where x, y are as above, D is a [1 x m]
%     vector of weights D_k(i) and a structure weak
%     contains parameters
%     of the best weak classifier minimizing (??).
%     See also parameter weakeval.
%   weakeval    A function called as ev=weakeval(weak,x),
%     where weak is an object returned by bestweak 
%     and x is a [d x n] matrix of feature vectors x_i.
%     On return, a column vector ev (size [n x 1]) should
%     contain classification  results W(x_i)in {-1,1} of the weak
%     classifier weak applied to all columns of x.
%   testerr  (default 10^  If the relative
%   unweighted classification error on the training data decreases under
%   the threshold testerr, the algorithm stops.
%   maxiters  (default 1000)  Maximum number of iterations to
%   perform.
%   display  (default 1)  If set to 1, progress is reported.
%   Set to 0 otherwise. The corresponding code is omitted here.
% Outputs:
%   weaks  [1 x K]  An array of K structures returned by bestweak,
%   representing weak classifiers W_k.
%   alpha  [1 x K]  Coefficients alpha_k.
%   errbound  1x1  Upper bound on the relative training error.
% See also: adaboosteval.
%
%
  
if nargin<8,
  displayfun=[] ;
end ;

if nargin<7,
  display=1 ;
end ;

if nargin<6,
  maxiters=1000 ;
end ;

if nargin<5,
  testerr=1e-3 ;
end ;

% The initial weights D_1(i) are chosen to sum to 1 and to give equal weights
% to positive (y_i=1) and negative (y_i=-1) samples. 
% This is more suitable than uniform weights
% when the number of positive and negative samples differ greatly.

mp = sum(y==1);  mm = sum(y==-1); 
D = (y==1)*0.5/mp + (y==-1)*0.5/mm;

% We prepare empty arrays weaks and alpha to which we
% shall append newly added weak classifier parameters. 
% Note that we do not allocate the arrays in advance (which is the
% recommended practice) because their size is not known at this point.
% However, in this case the reallocation cost is not a bottleneck.
%
% The upper bound on the relative training error will be stored in
% errorbound. 

weaks = [];
alpha = [];
errorbound = 1;

% The main loop starts by asking bestweak for a weak classifier 
% weak that minimizes (??) with current
% weights D. 
for step = 1:maxiters
  if display>0,
    disp(['step: ' num2str(step)]);
  end ;
  weak = bestweak( x, y, D );   

% We make sure that weak is suitable, that it performs better
% than randomly.
  ev = weakeval( weak, x );
  err = sum( D.*(ev~=y) );
  if err>=0.5
    warning('Error of a weak classifier bigger or equal than 0.5.');
    break;
  end


% Calculate the coefficient currentalpha 
% (alpha_k, Equation ??). We append weak
% and currentalpha to the appropriate output vectors.
  currentalpha = 0.5 * log((1-err)/err);
  alpha = [alpha currentalpha];
  weaks = [weaks weak];
% New weights D are updated  
% and normalized based on the classification results - the weight of
% correctly classified samples is decreased and the weight of incorrectly
% classified samples increased. Note
% how we take advantage of the fact that y and ev 
% contain values {-1,1}. The errorbound is updated.
  D = D .* exp( -currentalpha*y.*ev );
  Z = sum( D(:) );
  D = D ./ Z;
  errorbound = errorbound * Z;

% To evaluate the convergence criterion, we apply the current 
% strong classifier to the training data using adaboosteval
% and calculate the relative classification error err.
% Another option is to base the termination solely on the maximum number
% of iterations maxiter. This, besides being much faster, is
% actually beneficial because AdaBoost continues to increase the
% classification margin even after the training error becomes zero. On
% the other hand, maxiter needs to be determined experimentally.

  yc = adaboosteval( weaks, alpha, weakeval, x );
  err = sum(yc~=y) / size(x,2);
  if display>0,
    disp(['training error: ' num2str(err)]);
  end ;
  if err<testerr
    disp(['Adaboost converged at iteration ' num2str(step) '.']);
    break;
  end
  
  if ~isempty(displayfun)
    displayfun(step,weaks,alpha,errorbound);
  end
end % for loop


