% Demonstration of uP2Xdlt linear reconstruction of 3D points
% from N-perspective views
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007

clear all;
addpath ../.
cmpviapath('../.');
% if necessary, create a directory for output images
out_dir = './output_images/';
if exist(out_dir)~=7
  mkdir(out_dir)
end 


% The scenario is the same as for the u2Fdlt.
% The `random2D'
% option generates a set of coplanar points. 
scenetype = 'house'; % 'house' 'random2D';
[X,L] = scenegen( scenetype, 10 );
X(4,:) = 1; % homogeneous coordinates

% Define two virtual cameras, project the 
% 3D points to them.
idxcams = [1:2];
for i = idxcams
  campars.angle = 60*pi/180;  % view angle
  campars.look_at = [0 2 1]'; % orientation of the optical axis
  campars.position = [5 2*(-3+5*(i-1)) 1]';
  cam(i).pars = cameragen( campars ); % generate all camera parameters
  cam(i).u = cam(i).pars.P * X;       % projection of 3D to the cameras
  cam(i).u = cam(i).u ./ repmat( cam(i).u(3,:), 3, 1 ); % normalization of pixels
end

% Reconstruct selected points from the corresponding
% projections. We add some random noise to image coordinates
% to visualize reconstruction errors.
idxcorr = 1:size(X,2);
sigma = 20; % level of pixel noise
for i = idxcams
  % store the P matrices for uP2Xdlt
  P{i} = cam(i).pars.P;
  % add some noise to the corresponding pixel coordinates
  cam(i).u_noisy = ...
    cam(i).u(1:2,idxcorr) + sigma*randn(size(cam(i).u(1:2,idxcorr)));
  u_noisy(3,:) = 1;      % make it homogeneous
  u{i} = cam(i).u_noisy; % store the data for uP2Xdlt
end
% reconstruction
Xrecon = uP2Xdlt( P, u );
% 3D error
err3d = sum( sqrt( (Xrecon(1:3,:)-X(1:3,idxcorr)).^2 ) );
% Typically, the exact locations
% of 3D points are not known. The 2D reprojection error
% is the difference between observed and projected points and
% it is usually the only value we can use to evaluate the
% quality of the reconstruction, 

% compare the 3D reconstructions
fig = figure(1); clf;
fig = display3Dscene(fig,X,L,'b');
fig = display3Dscene(fig,Xrecon,L,'r');
campos([5,5,5])

exportfig(fig,[out_dir,'recon_3Dcomp.eps'])

% compare the 2D error
for i = idxcams
  fig = figure(10+i); clf
  display2Dpoints(fig,cam(i).u,[1,cam(i).pars.width,1,cam(i).pars.height],'b','+',7,L,sprintf('Camera %d',i),1)
  u = P{i}*Xrecon;
  u = u./repmat(u(3,:),3,1);
  %% 2D reprojection error
  err2d = sum( sqrt((u(1:2,:)-cam(i).u(1:2,:)).^2))
  display2Dpoints(fig,u,[1,cam(i).pars.width,1,cam(i).pars.height],'r','+',3,L,sprintf('Camera %d',i),2)
  for j=1:size(cam(i).u_noisy,2)
    plot(cam(i).u_noisy(1,j),cam(i).u_noisy(2,j),'ro','MarkerFaceColor','w','MarkerSize',9,'LineWidth',2)
  end
  set(gca,'box','on')
  exportfig(fig,[out_dir,sprintf('recon_2Dcomp_cam%02d.eps',i)])
end

