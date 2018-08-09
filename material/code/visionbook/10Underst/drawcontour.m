function drawcontour(xy,points) ;
% DRAWCONTOUR --- draw a smooth contour
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Usage: drawcontour(xy) 
% 
% Draws a smooth contour through given points. Matrix xy has size
% 2x N and each column determines one point. 
%
% This function uses B-spline interpolation bsplineinterp. Note
% how the first and last points are duplicated to create neutral boundary
% conditions. 
  
t = 2:0.01:size(xy,2) + 1;
degree = 2;
xt = bsplineinterp( [xy(1,1) xy(1,:) xy(1,end)], t, degree );
yt = bsplineinterp( [xy(2,1) xy(2,:) xy(2,end)], t, degree );


if points==1,
  plot(xy(1,:),xy(2,:),'ko',xt,yt,'b-','LineWidth',2) ;
elseif points==2
  plot(xt,yt,'r-','LineWidth',3) ;
elseif points==3
  plot(xt,yt,'b-','LineWidth',1) ;
elseif points==4
  plot(xt,yt,'g-','LineWidth',1) ;
else % points==0
  plot(xt,yt,'b-','LineWidth',2) ;
end
