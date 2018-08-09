% BSPLINEINTERP_DEMO Show how to use B-spline interpolation
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Example
%
% Figure ??a shows linear, quadratic, and cubic centered 
% B-splines, calculated as follows:
% 

addpath('..') ;
cmpviapath('..') ;

if (exist('output_images')~=7)
  mkdir('output_images');
end


t = -3:0.01:3;
for i = 1:length(t)
  f1(i) = lbspln( t(i) );
  f2(i) = qbspln( t(i) );
  f3(i) = cbspln( t(i) );
end

figure(1) ; 
plot(t,f1,'b',t,f2,'g',t,f3,'r','LineWidth',2) ;
grid on ;
legend('Linear','Quadratic','Cubic') ;
exportfig(gcf,'output_images/bsplines.eps') ;


% We demonstrate B-spline interpolation on a simple open contour given by 
% a few points that can be obtained, for example, using 
% snakeinit. The points can be saved into file and
% later reloaded as follows:


figure(2) ;
load bsplnpts

% We can now perform the interpolation. Change degree to change
% the interpolation type. You can also study the effect of the interpolation step
% (currently 0.01).

degree=1 ;
t=1:0.01:length(x) ;
xt1=bsplineinterp(x,t,degree) ;
yt1=bsplineinterp(y,t,degree) ;

degree=2 ;
xt2=bsplineinterp(x,t,degree) ;
yt2=bsplineinterp(y,t,degree) ;

degree = 3;
t = 1:0.01:length(x);
xt = bsplineinterp( x, t, degree );
yt = bsplineinterp( y, t, degree );

plot(xt1,yt1,'b-',xt2,yt2,'g-',xt,yt,'r-',x,y,'kx','LineWidth',2, ...
     'MarkerSize',10) ; 
axis([-200 700 0 1000]) ;
axis ij ; axis equal ; 

legend('Linear','Quadratic','Cubic','Control points') ;
hold off ;

exportfig(gcf,'output_images/bsplinescontour.eps') ;

% Figure ??b shows the chosen control points
% (x,y) as well as the results of the interpolation for degree
% 1,2,3. Note that curve smoothness increases with the interpolation 
% degree and so
% does the tendency to overshoot. However, the difference between
% quadratic and cubic interpolation is small. Combined with the fact that
% the computational
% complexity of quadratic and cubic centered B-splines is identical for
% many tasks (both have the same integer support), this
% is why B-spline interpolation of order higher than cubic is rarely used. 

