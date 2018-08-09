% CONVEXHULL_DEMO Demonstrate convex hull construction
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Example
%
% We generate 10 uniformly distributed random points and calculate 
% the convex hull.

addpath('..') ;
cmpviapath('..') ;

if (exist('output_images')~=7)
  mkdir('output_images');
end

rand('state',100) ;


n = 10;  xy = 10*rand(2,10);
k=convexhull(xy,2) ;






%
% For the second, larger example, we generate 1000 normally distributed 
% points in two clusters. The convex hull calculation only takes
% a fraction of a second.

n = 1000;
xy = random( 'norm', zeros(2,n), ones(2,n) );
xy(:,1:n/2) = [2 10; 10 3]*xy(:,1:n/2);
xy(:,n/2+1:end) = [5 0; 0 3]*xy(:,n/2+1:end) + repmat([30 10]',1,n-n/2);
k = convexhull(xy);

figure(3) ;
plot(xy(1,k),xy(2,k),'g-',xy(1,:),xy(2,:),'b.',...
     xy(1,k(1)),xy(2,k(1)),'ro','LineWidth',2)  ;
exportfig(gcf,'output_images/convexhull_big.eps') ;

% The points and the convex hull can be visualized as follows:
% plot( xy(1,k),xy(2,k),'g-', xy(1,:),xy(2,:),'b.', 'LineWidth',2 );

