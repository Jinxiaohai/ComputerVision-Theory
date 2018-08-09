function ransac_demof(sigma,xi,i,verbosity) ;
% RANSAC_DEMOF --- RANSAC demonstration
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Example
%
% We demonstrate RANSAC on the task of identifying a straight line
% from a cloud of points. The line will be described as
% y=a_0+a_1 x with a model parameter vector 
% [ a_0, a_1 ]. In particular we choose 
% a line a_0=10, a_1=0.3. We generate N=1000 points of which 
%  xi N are inliers, distributed regularly on the given straight line
% for x in [ 0;100], with normal noise
% with a standard deviation sigma=1 (sigma) added to the y
% component. The remaining (1- xi)N points are outliers, 
% distributed uniformly over the rectangle (x,y) in 
% [0;100]^2. Finally, the data points are randomly permuted.
if nargin<3
  i=1;
end
if nargin<4
  verbosity=1;
end


n = 1000;
ninl  = ceil(xi*n);   % number of inliers
noutl = n-ninl;       % number of outliers 
a1 = 0.3;  a0 = 10;   % straight line parameters  
t = 100*(0:ninl-1)/(ninl-1);
xinl  = [t; a0+t*a1+sqrt(sigma)*randn(1,ninl)];
xoutl = 100 * rand( 2, noutl );
x = [xinl xoutl];
x = x(:,randperm(n));

% RANSAC is called with the default parameters. Functions find_line
% and close_to_line are defined below. 
% For comparison, we also calculate a least squares estimate of
% the line parameters using function regress.




% Finally, we show the original samples, the true line (blue), the line found
% by linear regression (green) and the line found by RANSAC 
% (red).


if 1
[model,inliers]=ransac(x,2,@find_line,@(x,model)close_to_line(x,model,sigma),0.01,10000,0.001,verbosity) ;
outliers=not(inliers) ;
lregr=regress(x(2,:)',[ ones(n,1) x(1,:)' ]) ;
t1=[0 100] ;
figure(i)
clf ;
plot(x(1,inliers),x(2,inliers),'b.',t1,a0+a1*t1,'b-','LineWidth',6) ;
hold on ;
plot(x(1,outliers),x(2,outliers),'c.',...
     t1,model(1)+model(2)*t1,'r-',...
     t1,lregr(1)+lregr(2)*t1,'g-','LineWidth',2) ; hold off ;

exportfig(gcf,['output_images/ransac_demo' num2str(i) '.eps']) ;
end ;

% 
% Usage: model = find_line(x)
%
% Function find_line identifies line parameters [ a_0  a_1
% ] from two points passed as columns of x. For simplicity, we
% temporarily ignore division by zero as such deficient models will be
% refused later.

function model=find_line(x) ;
[d,n] = size(x);
s = warning( 'off', 'MATLAB:divideByZero' );
a1 = ( x(2,1)-x(2,2)) / (x(1,1)-x(1,2) );
warning(s);
a0 = x(2,1) - a1*x(1,1);
model = [a0 a1];
  
% 
% Usage: inl = close_to_line(x,model,sigma)
%
% Function close_to_line determines which points of x
% are `sufficiently close' to the line described by model.
% We know that the y coordinate has been corrupted by Gaussian noise
% with a known standard deviation sigma. We choose the threshold to
% determine `sufficient closeness' as 3 sigma, which corresponds to
% a 95% confidence interval.
function inl=close_to_line(x,model,sigma) ;  
  [d,n] = size(x);
  y = model(1)*ones(1,n) + model(2)*x(1,:);
  inl = abs(x(2,:)-y) < 3*sigma;

