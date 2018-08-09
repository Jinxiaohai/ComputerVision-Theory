% VTXICRP_DEMO
% CMP   Vision Algorithms http://visionbook.felk.cvut.cz
% Example
% We create a hill-like point cloud, divided into two overlapping
% parts, move one of the parts slightly and then use the ICRP algorithm
% to recover the transformation. 

close all
clear all ; 
addpath('..') ;
cmpviapath('..') ;

if (exist('output_images')~=7)
  mkdir('output_images');
end

% Each row of the array x1 corresponds to the homogeneous
% coordinates ([x, y, z, w], w=1) of one point. We first fill the
% x, y columns to cover a rectangular grid.
m = 0:0.5:20;
x1 = zeros( length(m)^2, 4 );
p = repmat( m', 1, length(m) );  x1(:,1) = p(:)';
p = repmat( m, length(m), 1 );   x1(:,2) = p(:)';
% Then set the z column to obtain the truncated hill shape; 
% the w column is set to 1.
x1(:,3) = 2*( (1+cos((x1(:,1)-15)/12*pi)).*(1+cos((x1(:,2)-10)/8*pi)) );
x1(:,3) = x1(:,3) .* ( abs((x1(:,1)-15)/12*pi)<=pi );
x1(:,3) = x1(:,3) .* ( abs((x1(:,2)-10)/8*pi)<=pi );
x1(:,4) = ones( size(x1,1), 1 );

% The support of the second point cloud (x2) is shifted by 
% 10 along the x axis, to define the overlap.

x2 = x1;
x2(:,1) = x2(:,1) + 10;
x2(:,3) = 2*( (1+cos((x2(:,1)-15)/12*pi)).*(1+cos((x2(:,2)-10)/8*pi)) );
x2(:,3) = x2(:,3) .* ( abs((x2(:,1)-15)/12*pi)<=pi );
x2(:,3) = x2(:,3) .* ( abs((x2(:,2)-10)/8*pi)<=pi );

% The point cloud x2 is then rotated and shifted by a known
% transformation, consisting of turning by 2
% around the x-axis (transformation t2) and 
% mation t3) with
% a center of rotation at  x=15 and 
% y=10 (transformation t1), and a final
% translation by  x=1 and  y=-0.5 (transformation
% t4).

a1 = 2/180*pi;  a2 = 3/180*pi;          % angle around x,y axes
t1 = eye( 4, 4 );                       % t1 - change of the origin
t1(4,1) = -15;       t1(4,2) = -10;
t2 = eye( 4, 4 );                       % t2 - rotation around x axis
t2(2,2) =  cos(a1);  t2(2,3) = sin(a1);
t2(3,2) = -sin(a1);  t2(3,3) = cos(a1);
t3 = eye( 4, 4 );                       % t3 - rotation around y axis
t3(1,1) =  cos(a2);  t3(1,3) = sin(a2);
t3(3,1) = -sin(a2);  t3(3,3) = cos(a2);
t4 = eye( 4, 4 );                       % t4 - translation
t4(4,1) = 1; t4(4,2) = -0.5;
t = t1 * t2 * t3 * inv(t1) * t4;        % composed transformation matrix
xt = x2 * t;                            % transformation of the point cloud

% compute the axes range
axesvec = [];
for i=1:3,
  maxima(i) = max(max(xt(:,i)),max(x1(:,i)));
  minima(i) = min(min(xt(:,i)),min(x1(:,i)));
  axesvec = [axesvec,minima(i),maxima(i)];
end
% The point cloud x1 is intentionally
% made sparser. The matching algorithm does not require the
% same number of points on both sides.
x1 = x1(2:2:end,:);                  

% Figure ??a shows the point clouds x1 and
% xt (transformed x2) in the initial position.
% [b]
%   =.4
%   []
%   []
%   {
%     (a) The initial configuration of the two point clouds. 
%     (b) The final position of the point clouds after registration
%     by the ICRP algorithm.}

figure(1);
set(gcf,'NumberTitle','off','Name','Original 3D data')
plot3(x1(:,1),x1(:,2),x1(:,3),'b.'); hold on
plot3(xt(:,1),xt(:,2),xt(:,3),'g.'); hold off
axis(axesvec)
exportfig(gcf,'output_images/icrp_input.eps') ;

% The two point clouds (x1 and xt) are registered using 
% ICRP and the transformation found is applied to xt.
% Figure ??b shows the point clouds x1 and
% xr after registration.

tf = vtxicrp( xt, x1 );
xr = xt*tf;

figure(2);
set(gcf,'NumberTitle','off','Name','Result of matching')
plot3(x1(:,1),x1(:,2),x1(:,3),'b.'); hold on
plot3(xr(:,1),xr(:,2),xr(:,3),'g.'); hold off
axis(axesvec)
exportfig(gcf,'output_images/icrp_output.eps') ;

% Comparing the true and recovered transformation matrices inv(t) and
% tf shows that the differences are very small.

disp(' ');
disp('Original transformation:');
disp(inv(t));
disp('Found transformation:');
disp(tf);

