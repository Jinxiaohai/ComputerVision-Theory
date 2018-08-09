function camera = cameragen(pars)
% CAMERAGEN  generates camera mathematical description   
% CMP Vision Algorithms visionbookcmp.felk.cvut.cz
% Tomas Svoboda, 2007

% The function cameragen described here creates 
% a camera matrix P from user specified
% natural camera parameters into the mathematically oriented ones that are used
% in 3D computer vision algorithms. 
% 
% Usage: [camera] = cameragen(pars)
% Inputs:
%   pars  struct  Structure containing various camera parameters. 
%   .angle  1x1  Horizontal view angle of the camera in radians.
%     The vertical angle is subsequently determined
%     from aspect_ratio and image width
%     to height ratio.
%   .position  [3 x 1]  The camera center expressed in the world coordinate frame.
%   .look_at  [3 x 1]  Point where the camera (its optical axis) is aiming.
%   .sky  (default [0;-1;0])  Position of the sky. 
%   .width   (default 640)  Image width in pixels.
%   .height  (default 480)  Image height in pixels.
%   .aspect_ratio  (default 1)  Ratio between pixel width and height.
%     It defaults to square pixels.
%   .foclen  (default 1)  Focal length of the camera. It does not change
%     the image, but it changes the pixel dimensions camera.width_metric.
%   .skew  (default 0)  Skew factor, zero for most of the cameras. 
%     Non-zero it means that rows and columns are no longer perpendicular. 
% Outputs:
%   camera  struct  Structure containing a complete description
%     of the camera. Note that
%     P = K [R t].
%   .P  [3 x 4]  Camera projection matrix.
%   .K  [3 x 3]  Upper triangular matrix containing the intrinsic
%     camera parameters.
%   .R  [3 x 3]  Rotation matrix.
%   .t  [3 x 1]  Translation vector.
%   .C  [3 x 1]  Position of the camera center in the
%     world coordinate frame.
%   .width_metric  1x1  Width of the image in metric units.
%   .pix_width     1x1  Pixel width in metric units.
%   .pix_height    1x1  Pixel height in metric units.

% History:
% $Id: cameragen_decor.m 1047 2007-08-10 13:23:23Z svoboda $ 
%
% 2007-01-25: Tomas Svoboda (TS) created
% 2007-03-09: Petr Lhotsky, standard header
% 2007-05-03: TS new decor
% 2007-06-21: TS final decor
% 2007-08-09: TS refinement for better looking of m-file



try camera.aspect_ratio = pars.aspect_ratio; catch camera.aspect_ratio = 1; end;
try camera.width = pars.width; catch camera.width = 640; end;
try camera.height = pars.height; catch camera.height = 480; end;
try camera.foclen = pars.foclen; catch camera.foclen = 1; end;
try camera.skew = pars.skew; catch camera.skew = 0; end;
try camera.sky = pars.sky./norm(pars.sky); catch camera.sky = [0,-1,0]'; end;


camera.angle = pars.angle;

camera.C = pars.position;
% Orientation of the camera plane (normal vector) is 
% determined by a line connecting the camera center and 
% the camera target specified by the look_at parameter.
% The line is called the optical axis.
% The camera plane is perpendicular to it.
camera.dir = -(camera.C-pars.look_at) ./ norm( camera.C-pars.look_at );

% Azimuth and elevation of the optical axis: the spherical
% coordinates of the camera center will be useful for composition
% of the rotation matrix.
[camera.az,camera.el,camera.dist] = ...
    cart2sph( -camera.dir(1), -camera.dir(2), -camera.dir(3) );

% where is the camera looking
camera.look_at = pars.look_at;


% The composition of the camera rotation is perhaps the most
% complicated part of the conversion. It is important to keep 
% in mind that the positive z axis goes from the camera center
% towards the camera.look_at position. The image plane
% is perpendicular to the axis and the intersection is the 
% principal point.

% Rotate horizontally around the z-axis (vertical axis) until it fixes 
% the look_at point. This movement is called panning.
R_pan = nfi2r( [0 0 1], camera.az );
% Then rotate around the y-axis to fix the horizontal elevation.
% This rotation is called tilting.
R_tilt = nfi2r( [0 1 0], -camera.el );
% Rotation of the camera system itself. Remember that the z-axis
% of the camera coordinate system directs towards the scene.
R_cam = nfi2r([1 0 0],-pi/2) * nfi2r([0 0 1],pi/2);
% By default the camera is horizontally aligned with the xz plane
% of the world. In other words, the world horizon projects 
% horizontally in the image. In the camera coordinate system, it
% corresponds to the (normalized) position of the sky at
% [0,-1,0]. This default setting can be overridden by setting
% different pars.sky.
if all( camera.sky==[0 -1 0]' )
  R_sky = eye(3); % do nothing
else
  if all(-camera.sky==[0 -1 0]');
    R_sky = nfi2r( [0 0 1], pi ); % upside-down
  else
    rotaxis = cross( camera.sky,[0 -1 0]' );
    rotangle = acos( camera.sky'*[0 -1 0]' );
    R_sky = nfi2r( rotaxis, rotangle ); % general rotation
  end
end
camera.R = R_sky*R_cam*R_tilt*R_pan; % put all partial rotations together

% The rest of the computation is straightforward:
camera.t = -camera.R * camera.C; % translation vector
camera.width_metric = 2*camera.foclen * tan(camera.angle/2);
camera.pix_width = camera.width_metric / camera.width;
camera.pix_height = (1/camera.aspect_ratio) * camera.pix_width;
% composition of the intrinsic parameters matrix K
camera.K = [camera.foclen/camera.pix_width camera.skew camera.width/2; ...
            0 camera.foclen/camera.pix_height camera.height/2; ...
            0 0 1];
% and finally the 3x4 camera projection matrix
camera.P = camera.K * [camera.R camera.t];
return; % end of cameragen

