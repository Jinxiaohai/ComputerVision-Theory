function adaboost_demof() ;
% ADABOOST_DEMO
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Example
%
% adaboost is demonstrated on the task of classifying 2D
% points into two classes depending on their distance from the center.
% Figure ??a shows an example of 1000 points
% divided into the two classes.
% Weak classifiers W_k are linear
%
% At each AdaBoost step k, we use bestweaklearner to
% try all projection
% directions 
%  a fixed set of angles 
% and choose the best p with respect to the weighted classification 
% error epsilon_k (??). For each fixed p,
% function weaklearner finds the best tau_k, zeta_k,
% again with respect to epsilon_k.
% 
% We create the feature set features (corresponding to p):
angle = pi*(0:179)/180;
features = [cos(angle); sin(angle)];

% Training and testing data sets are generated using generate_data
% (below)
% and each contains n=1000 points. Recall that the training set
% serves to train the classifier, while an independent test set gives us an
% unbiased assessment of the classifier performance .
n = 1000;
[xtrain,ytrain] = generate_data( n );
[xtest,ytest] = generate_data( n );
figure(1) ;
show_data(xtrain,ytrain) ;
exportfig(gcf,'output_images/adaboost_data.eps') ;

figure(2) ;

% Function adaboost is called on the training data with the default
% parameters. It stops after about 60 iterations (this is data dependent).


[weaks,alpha]=adaboost(xtrain,ytrain,...
 @(x,y,D)bestweaklearner(x,y,D,@weaklearner,@weakeval,features),...
 @weakeval,1e-3,1000,1,...
 @(step,weaks,alpha,errorbound)displayfun(...
     step,weaks,alpha,xtrain,ytrain,xtest,ytest,@weakeval,errorbound)) ;
 
% Figure ?? illustrates the evolution of the
% classifier as a function of an increasing number (step=K) 
% of weak classifiers W_k. The green region, corresponding to class +1,
% converges quickly to its final circular shape. 
% Figure ??b shows the evolution of the classification
% error on the training and test
% data sets with respect to the number of iterations. 
% Note that although the error does
% not decrease monotonically, it decreases quickly and the test error
% closely follows the training error.
 
function [x,y]=generate_data(n);
%  Usage: function [x,y] = generate_data(n)
%
% Function generate_data generates n uniformly distributed points
% x in the range [-1;1]x[-1;1] and assigns them
% label y=1 if their distance to the center is smaller than
% 0.3, or label y=-1 otherwise.
x = 2*rand(2,n) - 1;
y = 1 - 2*( sqrt(x(1,:).^2+x(2,:).^2) > 0.3 );

function show_data(x, y)

plot( x(1,y==1), x(2,y==1),'b+', x(1,y==-1),x(2,y==-1),'k.' );
axis equal;  axis tight;
legend('y=+1','y=-1')



function weak=weaklearner(x,y,D,p) ;
% Usage: weak = weaklearner(x,y,D,p)
%
% Function weaklearner accepts a projection direction p_k (p)
% and calculates the threshold tau_k (thresh) and parity zeta_k
% (parity) that minimize the weighted classification error 
% epsilon_k (??). The calculated parameters are stored
% into the output structure weak. 
% 
% The parameters tau and zeta can be determined in linear time
% with respect to the number of data points (feature vectors) m 
%
% We start by calculating the projections x^T_i p which are then
% sorted together with their classifications y and weights D.
weak.feature = p;
pf = x' * p;
[ps,ind] = sort(pf);  ys = y(ind);  Ds = D(ind);
% A zero element is added at the
% beginning to correspond to M^+-(-infinity) and thus allow such a threshold.
mp = [0 cumsum(Ds.*(ys==1))];
mm = [0 cumsum(Ds.*(ys==-1))];
ep = mp - mm + mm(end);
em = mm - mp + mp(end);
% We find the minimum of ep and em and use it to
% determine the parity and threshold. To maximize the classification
% margin, the threshold tau is chosen
% in the middle of the two neighboring (sorted) projection values 
% x^T_i p and x^T_ p. If the extreme values of the
% projections are found to be optimal, the threshold tau is set to
% +-infinity. 
[best_ep,best_epi] = min(ep);
[best_em,best_emi] = min(em);
if best_ep<best_em
  weak.parity = 1;   i = best_epi;
else
  weak.parity = -1;  i = best_emi;
end
% threshold
ps = [-inf; ps; inf];
weak.thresh = 0.5 * ( ps(i+1)+ps(i+2) );
  

function y=weakeval(weak,x) ;
% 
% Usage: y = weakeval(weak,x)
%
% Function weakeval evaluates the weak classifier 
% weak (??) on
% a given data set x. See also adaboost.

y = sign( (x'*weak.feature-weak.thresh) * weak.parity )';


function displayfun(step,weaks,alpha,xtrain,ytrain,xtest,ytest,weakeval,errorbound) ;
  persistent trainerr testerr bounds ;
  if step==1,
    trainerr=[] ; testerr=[] ; bounds=[] ;
  end ;
  yc=adaboosteval(weaks,alpha,weakeval,xtrain) ;
  trainerr=[trainerr ; sum(yc~=ytrain)/size(xtrain,2)] ;
  yc=adaboosteval(weaks,alpha,weakeval,xtest) ;
  testerr=[testerr ; sum(yc~=ytest)/size(xtest,2)] ;
  bounds=[bounds errorbound] ;
  disp(['test error: ' num2str(testerr(end))]);
  figure(2) ;
  plot(trainerr, 'b');
  hold on;
  plot(testerr, 'r');
  grid on;
  plot(bounds,'g') ;
  hold off;
  xlabel('step') ; ylabel('relative error') ;
  legend('Training error', 'Test error', 'Training error bound', 'Location', 'NorthEast');

  steps=[1,2,3,5,10,15,20,30,60] ;
  if sum(find(step==steps))>0,
    exportfig(gcf,[ 'output_images/adaboosterr' num2str(step) '.eps']) ;
  end ;

  
  figure(3) ;
  vis_boundary(xtrain,ytrain,weaks,alpha,weakeval);
  if sum(find(step==steps))>0,
    print('-depsc2','-cmyk',[ 'output_images/adaboostpattern' num2str(step) '.eps']) ;
    exportfig(gcf,[ 'output_images/adaboostpattern' num2str(step) '.eps']) ;
  end ;

function vis_boundary(xt,yt,weaks,alpha,weakeval)

  clf
  rangeX = [-1:0.01:1];
  rangeY = [-1:0.01:1];
  
  % decision bitmap
  [x,y] = meshgrid(rangeX, rangeY);
  bitX = [reshape(x, 1, length(x(:))); reshape(y, 1, length(y(:)))];
  bitTSLength = size(bitX, 2);
  
  % find train error in the bitmap
  result = adaboosteval(weaks,alpha,weakeval,bitX,1) ;
  bitRes = reshape(result, size(x));
  
  poscol = [0 1 0] ;
  poscol=poscol/norm(poscol) ;
  negcol = [1 0 0];
  negcol=negcol/norm(negcol) ;
  neutrcol=[1.0 1.0 1.0]/3.0 ;
  minResp = min(bitRes(:)); %-10;
  maxResp =  max(bitRes(:)); %10;

  % generate color image
  img = zeros(size(bitRes, 1), size(bitRes, 2), 3);
  posc=repmat(poscol,bitTSLength,1) ;
  negc=repmat(negcol,bitTSLength,1) ;
  neutrc=repmat(neutrcol,bitTSLength,1) ;
  wp=repmat(bitRes(:)/maxResp,1,3) ;
  wn=repmat(bitRes(:)/minResp,1,3) ;
  rgb = repmat(bitRes(:)>0,1,3).*(wp.*posc+(1-wp).*neutrc)+...
        repmat(bitRes(:)<0,1,3).*(wn.*negc+(1-wn).*neutrc) ;
  img(:, :, 1) = reshape(rgb(:, 1), size(bitRes));
  img(:, :, 2) = reshape(rgb(:, 2), size(bitRes));
  img(:, :, 3) = reshape(rgb(:, 3), size(bitRes));
  
  image(rangeX, rangeY, img), axis xy, axis off, axis equal;
  ax1 = gca;
  axis([rangeX(1) rangeX(end) rangeY(1) rangeY(end)]);
  
  hold on;
  
  % show training set
  show_data(xt,yt) ;

  % show classifier
  showclassif(weaks,alpha)
  
  axis off
  axis equal
  set(gca, 'XLim', [rangeX(1) rangeX(end)]);
  set(gca, 'YLim', [rangeY(1) rangeY(end)]);
  
  drawnow
  %disp('Press any key') ;
  %pause

  return
  
function showclassif(weaks,alpha)
  
  for J=1:length(weaks)
    w = weaks(J).thresh * weaks(J).feature;
    
    wlen = sqrt(sum(w.^2));
    w_perp_norm = [-w(2)/wlen, w(1)/wlen];
    
    visX = [w(1) + 2 * w_perp_norm(1), ...
	    w(1) - 2 * w_perp_norm(1)];
    visY = [w(2) + 2 * w_perp_norm(2), ...
	    w(2) - 2 * w_perp_norm(2)];
    plot(visX, visY, 'k'); %, 'LineWidth', 3);
  end
  
