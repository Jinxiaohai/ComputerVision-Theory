% GAUSSIANMIXTURE_DEMO showing the usage of gaussianmixture
% CMP Vision Algorithms http://visionbook.felk.cvut.cz

% Example
%
% 
% In a 1D example (d=1), we randomly generate N=1000 points
% using a mixture of 
% K=3 Gaussians with weights w_1=0.2, w_2=0.5, w_3=0.3, 
% means mu_1=10, mu_2=20, mu_2=30, and variances
% Sigma_1=4, Sigma_2=25, Sigma_3=1. Note that the third
% parameter given to random is a standard 
% deviation (the square root of the variance).

clear all ; close all ;

addpath('..') ;
cmpviapath('..') ;

if (exist('output_images')~=7)
  mkdir('output_images');
end



rand('state',4) ;
randn('state',4) ;



if 1,
n = 1000;
w1 = 0.2;  w2 = 0.5;  w3 = 0.3;
x = [random( 'norm', 10*ones(1,floor(n*w1)), 2*ones(1,floor(n*w1)) ) ...
     random( 'norm', 20*ones(1,floor(n*w2)), 5*ones(1,floor(n*w2)) ) ...
     random( 'norm', 30*ones(1,floor(n*w3)), 1*ones(1,floor(n*w3)) )];

% Then the EM algorithm
% gaussianmixture is run. It takes about 230
% iterations. 


ts = 1;
t=[0:ts:35] ;
t1=[0:0.1:35] ;
nt=length(t1) ;
count=hist(x,t) ; 
f1=w1*pdf('norm',t1,10,2) ;
f2=w2*pdf('norm',t1,20,5) ;
f3=w3*pdf('norm',t1,30,1) ;

[mu,C,w] = gaussianmixture( x, 3, 1 );

% The estimated parameters are very close to the true ones, 
% up to a permutation:

% Figure ??a shows the histogram of the
% generated samples calculated using function hist with bin size 1,
% over which we superimpose the probability density functions of the
% three Gaussians and the total mixture density
% (Figure ??b). Observe 
% that the estimate (in red) closely follows the true p.d.f.\ (in blue).

figure(1) ;
bar(t,count/n/ts,'w') ; hold on ;
f1w=w(1)*pdf('norm',t1,mu(1),sqrt(C(1,1,1))) ;
f2w=w(2)*pdf('norm',t1,mu(2),sqrt(C(1,1,2))) ;
f3w=w(3)*pdf('norm',t1,mu(3),sqrt(C(1,1,3))) ;
plot(t1,f1,'b-',t1,f2,'b-',t1,f3,'b-','LineWidth',4) ; 
plot(t1,f1w,'r-',t1,f2w,'r-',t1,f3w,'r-','LineWidth',2) ; 
hold off 
exportfig(gcf,'output_images/gaussianmixture_demo1a.eps') ;

figure(2) ;
bar(t,count/n/ts,'w') ; hold on ;
plot(t1,f1+f2+f3,'b-','LineWidth',4) ;
plot(t1,f1w+f2w+f3w,'r-','LineWidth',2) ;
hold off 
exportfig(gcf,'output_images/gaussianmixture_demo1b.eps') ;

end ;


% We continue with a 2D example (d=2), with N=1000 points 
% generated with weights w_1=w_2=0.5, means
% mu_1=[ 0 0 ], mu_2=[ 30  10 ] and covariances
%   Sigma_1= 104  \050  \050  109   ,
%   Sigma_2=  25   0    \00     9   .

rand('state',40) ;
randn('state',40) ;


if 1,

n=1000 ;

% We generate samples from a random variable with identity
% covariance matrix. These samples are then linearly transformed to
% obtained the desired distribution. Note that the covariance matrices 
% are the squares of the matrices used to multiply the original
% xy values.

xy = random( 'norm', zeros(2,n), ones(2,n) );
xy(:,1:n/2) = [2 10; 10 3] * xy(:,1:n/2);
xy(:,n/2+1:end) = [5 0; 0 3] * xy(:,n/2+1:end) + repmat([30 10]',1,n-n/2);

% The EM algorithm gaussianmixture only
% needs about 30 iterations to converge and the results are 
% reasonably good (again, up to a permutation).

[mu,C,w] = gaussianmixture(xy,2,1);



figure(3) ;
plot(xy(1,1:n/2),xy(2,1:n/2),'b.',...
     xy(1,n/2+1:n),xy(2,n/2+1:n),'g.','LineWidth',2)  ;
exportfig(gcf,'output_images/gaussianmixture_demo2a.eps') ;

figure(4) ; 
clf 
plot(xy(1,1:n/2),xy(2,1:n/2),'b.',...
     xy(1,n/2+1:n),xy(2,n/2+1:n),'g.','LineWidth',2)  ;
hold on ;
s=1 ;
xd=-40:s:50 ;
yd=-50:s:40 ;
[X,Y]=meshgrid(xd,yd) ;
f1=mvnpdf([X(:) Y(:)],mu(:,1)',C(:,:,1)) ;
f2=mvnpdf([X(:) Y(:)],mu(:,2)',C(:,:,2)) ;
f1=reshape(f1,length(yd),length(xd)) ;
f2=reshape(f2,length(yd),length(xd)) ;
f3=w(1)*f1+w(2)*f2 ;

thr1=4.94e-4 ; s*s*sum((f1(:)>thr1) .* f1(:))
thr2=8.06e-5 ; s*s*sum((f2(:)>thr2) .* f2(:))
thr3=8e-5 ; s*s*sum((f3(:)>thr3) .* f3(:))

contour(X,Y,f1,thr1,'g') ;
contour(X,Y,f2,thr2,'b') ;
contour(X,Y,f3,thr3,'r') ;
hold off ;
exportfig(gcf,'output_images/gaussianmixture_demo2b.eps') ;

end ;

