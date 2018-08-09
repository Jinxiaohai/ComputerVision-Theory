% Demonstration of u2Hdlt, linear estimation of the Homography matrix
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007


clear all;

outdir = './output_images/'; 
if exist(outdir)~=7
  mkdir(outdir)
end

addpath ../.
cmpviapath('../.',1); % set also path to the stprtoolbox


% Generate two artificial scenes using function scenegen:
% house is a 3D house and random2D
% makes randomly generated co-planar points.
scenetypes = {'house' 'random2D'}; 
for s = 1:length(scenetypes) % for all scenes
  scenetype = scenetypes{s};
  [X,L] = scenegen( scenetype, 10 );
  X(4,:) = 1;

% Define two virtual cameras by using cameragen and use them to project the 
% 3D points.
  for i = 1:2 % two cameras
    campars.angle = 30*(pi/180); % view angle
    campars.look_at = [0 2 2]';  % orientation of optical axis
    campars.position = [12 2+2*(i-1) 5+2*(i-1)]'; % camera center
    cam(i).pars = cameragen( campars ); % generate cameras
    cam(i).u = cam(i).pars.P * X;       % 3D -> 2D projection
    % normalization to image plane
    cam(i).u = cam(i).u ./ repmat( cam(i).u(3,:), 3, 1 );
  end
% Compute the homography mapping from selected points. For the planar
% scene random2D, we could use all points, they are all
% related by homography. 
% Contrarily, the two projections of the 3D scene house are
% not all related by the homography, 
% The points [1,2,3,4]
% belong to one 3D plane in the scene and hence are related by a 
% homography mapping.
  idxcorr = [1 2 3 4];
  H = u2Hdlt( cam(1).u(:,idxcorr), cam(2).u(:,idxcorr) );
% Mapping from camera 1 to camera 2, u_2 = H u_1.
  cam(2).ucomp = H*cam(1).u;
% For a non-degenerate configuration 
% the mapping is one to one, meaning
% u_1 = H^ u_2.
  cam(1).ucomp = inv(H)*cam(2).u;

% Normalize both computed coordinates to get pixel
% coordinates. Then, all the generated and computed points
% are displayed by using the display2Dpoints function, 
  for i = 1:2
    cam(i).ucomp = cam(i).ucomp ./ repmat(cam(i).ucomp(3,:),3,1);
  end

% visually
  for i=1:2,
    fig(i)=figure(i);
    clf, hold on;
    display2Dpoints(fig(i),cam(i).u,[1,cam(i).pars.width,1,cam(i).pars.height],'k','+',10,L,scenetype);
    display2Dpoints(fig(i),cam(i).ucomp,[1,cam(i).pars.width,1,cam(i).pars.height],'b','o',10,L,scenetype);
    display2Dpoints(fig(i),cam(i).u(:,idxcorr),[1,cam(i).pars.width,1,cam(i).pars.height],'r','o',18,[],scenetype);
    display2Dpoints(fig(i),cam(i).ucomp(:,idxcorr),[1,cam(i).pars.width,1,cam(i).pars.height],'r','o',18,[],scenetype);
    set(gca,'Box','on');
  end

% printing
  figure(1)
  print('-depsc2','-cmyk',sprintf('%s/leftim_%s.eps',outdir,scenetype))
  figure(2)
  print('-depsc2','-cmyk',sprintf('%s/rightim_%s.eps',outdir,scenetype))
end % end of the scenetype loop

