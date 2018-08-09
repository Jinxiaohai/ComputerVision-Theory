% Ganarate example data
% ---------------------

% The data are represented by m by m points in xy plane with value of z
% coordinate corresponds to sin(a)*cos(b) - hill with different steepnes 
% of slopes.

% Definition of xy raster resolution
%
m = 0:0.2:20;

% Generate xy coordinate base
% x1 = [x y z 1] point coordinates
%
x1 = zeros(length(m)^2,4);
p = repmat(m',1,length(m));
x1(:,1) = p(:)';
p = repmat(m,length(m),1);
x1(:,2) = p(:)';
x1(:,4) = ones(size(x1,1),1);

% Points in second set of points will be 
% shiftet by 10 along x axis
% 
x2 = x1;
x2(:,1) = x2(:,1) + 10;

% Z axis is computed as fuction of x,y coordinates
%
x1(:,3) = ((cos((x1(:,1)-15)/12*pi)+1).*(cos((x1(:,2)-10)/8*pi)+1)) .* 2;
x1(:,3) = x1(:,3).*(abs((x1(:,1)-15)/12*pi)<=pi);
x1(:,3) = x1(:,3).*(abs((x1(:,2)-10)/8*pi)<=pi);
x2(:,3) = ((cos((x2(:,1)-15)/12*pi)+1).*(cos((x2(:,2)-10)/8*pi)+1)) .* 2;
x2(:,3) = x2(:,3).*(abs((x2(:,1)-15)/12*pi)<=pi);
x2(:,3) = x2(:,3).*(abs((x2(:,2)-10)/8*pi)<=pi);

% Presentation of point clouds in original position
%
figure(1);
set(gcf,'NumberTitle','off','Name','Original 3D data')
plot3(x1(:,1),x1(:,2),x1(:,3),'b*'); hold on
plot3(x2(:,1),x2(:,2),x2(:,3),'r*'); hold off
rotate3d on

% Second point cloud (x2) will be rotated and
% shifte by known transformation
%
a1 = 2/180*pi; % angle around x axis
a2 = 3/180*pi; % angle around y axis

% Center of rotation
t1 = eye(4,4);
t1(4,1) = -15; t1(4,2) = -10;
% Rotation  around x axis
t2 = eye(4,4);
t2(2,2) = cos(a1); t2(2,3) = sin(a1);
t2(3,2) = -sin(a1); t2(3,3) = cos(a1);
% Rotation  around y axis
t3 = eye(4,4);
t3(1,1) = cos(a2); t3(1,3) = sin(a2);
t3(3,1) = -sin(a2); t3(3,3) = cos(a2);
% Final translation
t4 = eye(4,4);
t4(4,1) = 1; t4(4,2) = -0.5;
% Compose transforamtion matrix
t = t1*t2*t3*inv(t1)*t4;
% Transformation of x2 point cloud
xt = x2*t;

% Presentation of point clouds after 
% known testing transformation
%
figure(2);
set(gcf,'NumberTitle','off','Name','3D matching input data')
plot3(x1(:,1),x1(:,2),x1(:,3),'b*'); hold on
plot3(xt(:,1),xt(:,2),xt(:,3),'r*'); hold off
rotate3d on

% Matching of point set x1 and transformed point set xt (made from x2).
% Algoritm look for euclidean transformation which transforms points xt
% into coordinate system of set x1 and minimize reciprocal point distance
% between poins from x1 set and xt set.
%
tf = vtxicrp(xt,x1);

% Transformation of xt poinst by found transformation
%
xr = xt*tf;

% Presentation of point clouds transformed into
% common coordinate system by transformation
% which has been obtained by ICRP.
%
figure(3);
set(gcf,'NumberTitle','off','Name','Result of matching')
plot3(x1(:,1),x1(:,2),x1(:,3),'b*'); hold on
plot3(xr(:,1),xr(:,2),xr(:,3),'g*'); hold off
rotate3d on

% Show numerical results
%
disp(' ');
disp('Original transformation:');
disp(inv(t));
disp('Found transformation:');
disp(tf);

