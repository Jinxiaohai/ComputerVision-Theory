% U2FDLT geometrical explanation of the epipolar geometry
% CMP Vision Algorithms, http://visionbook.felk.cvut.cz
% Tomas Svoboda 2007


clear all; % sanity clear of all workspace variables
close all; % force the figures re-open, needed for consistent grabbing 

addpath ../.
cmpviapath('../.');
% if necessary, create a directory for output images
out_dir = './output_images/';
if exist(out_dir)~=7
  mkdir(out_dir)
end 

% First create the 3D scene data.
scenetype = 'house';
[X,L] = scenegen(scenetype);
X(4,:) = 1;
% X contains coordinates of 3D points and L 
% encompass the indexes needed for plotting lines, see cameragen.

% We place the two cameras around a 3D scene 
% and project the 3D points to the cameras. 
for i=1:2
  campars.angle = 65*pi/180;  % view angle
  campars.look_at = [0 2 1]'; % orientation of the optical axis
  campars.position = [5 2*(-3+10*(i-1)) 1]'; % camera center
  cam(i).pars = cameragen(campars); % generate all camera parameters
  cam(i).u = cam(i).pars.P * X;     % projection of 3D to the cameras
  cam(i).u = cam(i).u ./ repmat(cam(i).u(3,:),3,1); % normalization
end

% Compute the Fundamental matrix and epipoles from the projected 2D points. 
[F,T1,T2,e1,e2] = u2Fdlt( cam(1).u, cam(2).u );

% The epipolar geometry is essentially a geometrical relation
% between points in a 3D scene and two projections captured from
% different viewpoints. The following code draws the 2D points, 
% epipolar lines,
% and the epipoles, 
idx = 1:size(cam(1).u,2);  % indexes of epipolar lines to be plotted
e(:,1) = e1;  e(:,2) = e2; % epipoles
for i = 1:2    % both cameras
  fig(i) = figure(10+i);
  clf,  hold on;
  display2Dpoints( fig(i), cam(i).u, ...
    [1 cam(i).pars.width 1 cam(i).pars.height], 'b', '+', 5, L, scenetype );
  for j = idx  % all epipolar lines
    kl = cam(i).u(1:2,j) - e(1:2,i); % direction
    el = e(1:2,i) + 1.2*kl;          % endpoint for plotting
    bl = e(1:2,i) - 0.2*kl;          % starting point for plotting
    line( [bl(1) el(1)], [bl(2) el(2)], 'LineWidth',1, 'Color','black' )
  end
  plot( e(1,i), e(2,i), 'ro', 'MarkerSize',7, 'LineWidth',2,...
        'MarkerFaceColor','w' ); % epipoles
  set( gca, 'Box','on' );
  exportfig( fig(i), [out_dir sprintf('epip_cam%02d.eps',i)] );
end


% The 3D sketch is little more complicated.
% Matlab\/ offers support for creating 3D plots and 
% allows easy viewpoint manipulation. First we make the 2D projections for both cameras 
% similarly above with some modification in order to enhance
% visibility in the 3D sketch. 
figure(2)
% create the 2D projection  
for i = 1:2   % for both cameras
  P{i} = cam(i).pars.P; % collect data for showcams function
  plot( cam(i).u(1,:), cam(i).u(2,:), 'ko', 'MarkerFaceColor','white' )
  for j = 1:size(L,1) % house lines
    line( [cam(i).u(1,L(j,:))], [cam(i).u(2,L(j,:))], 'LineWidth',7 );
  end
  for j = idx % all epipolar lines
    line( [e(1,i) cam(i).u(1,j)], [e(2,i) cam(i).u(2,j)], ...
          'LineWidth',7, 'Color','black' )
  end
  axis ij;  axis equal;  axis( [0 cam(i).pars.width 0 cam(i).pars.height] )

  % capture the Matlab figure to a bitmap
  set( gca, 'Position',[0 0 1 1] );  axis off
  im = getframe(gcf);
  IM{i} = im.cdata; % collect data for showcams function
  IM{i} = imresize( IM{i}, [cam(i).pars.height cam(i).pars.width], 'bilinear' );
end

% Composition of the 3D sketch starts with displaying the 3D scene.
% All epipolar planes intersect in the line that connects the 
% camera centers. Intersections of image planes with this line are the
% epipoles.
fig = figure(1);
% display the 3D house   
fig = display3Dscene( fig, X, L );
% draw a line between camera centers
line([cam(1).pars.C(1) cam(2).pars.C(1)], ...
     [cam(1).pars.C(2) cam(2).pars.C(2)], ...
     [cam(1).pars.C(3) cam(2).pars.C(3)], 'color','red', 'LineWidth',3 )

% We have the camera projection matrices P{i} and
% their images IM{i}. Insertion of the cameras 
% into the 3D scene is done by calling function showcams.
showcams( fig, -1, P, IM );

% Now, display epipolar planes.
% More epipolar planes can be displayed, e.g. by setting
% idx3d=[3 5]:
idx3d = [5];
for i = 1:2  % cameras
  for j = idx3d  % epipolar planes  
    % line connecting camera center and selected 3D point
    line([cam(i).pars.C(1) X(1,j)], [cam(i).pars.C(2) X(2,j)], ...
         [cam(i).pars.C(3) X(3,j)], 'color','red', 'LineWidth',3 )
    % epipolar plane vertices
    for c = 1:3
      epiplane(:,:,c) = [X(c,j); cam(1).pars.C(c);cam(2).pars.C(c)];
    end
    % displaying the epipolar plane
    patch( epiplane(:,:,1), epiplane(:,:,2), epiplane(:,:,3), ...
           0.95*[1 0.9 0.9], 'AlphaDataMapping','none', 'EdgeColor','none', ...
          'FaceAlpha','flat', 'FaceVertexAlphaData',0.3 );
  end
end

% adjust figure size
scr_size = get(0,'ScreenSize');
scale = 1.9/3;
set(gcf,'Position',[0,scr_size(4)/3,scale*scr_size(3),0.7*scale*scr_size(4)])

% set the initial viewpoint
campos(2*cam(2).pars.C+[0;-5;2])
initzoom = 4;
camzoom(initzoom)
 
print('-dpng','-r96','-cmyk',[out_dir,'epip3Dsketch.png'])

camzoom(3/initzoom)

% dolly the the camera around
MAKE_VIDEO = 0; % save a sequence for video making
% Animation of the 3D sketch is realized by moving
% the observation camera, see camdolly and 
% other related functions.
numpos = 10; % discretization of the fly
dx = -3/numpos; % fly around in x-direction
dy = 0;  dz = 0;
for i = 1:round(3*numpos),
  camdolly( dx, dy, dz, 'fixtarget' )
  if MAKE_VIDEO
    print('-dpng','-cmyk','-r96',[out_dir,sprintf('epip3ddolly_frame%04d',i)])
  end
  pause(1/25) % 25 fps
end
