function fig = showcams(fig,foclen,varargin)
% SHOWCAMS draw a camera into a 3D sketch
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
% 
% We draw a camera in a 3D sketch
% in a pleasing way. The center and image plane are drawn, as well
% as lines that connect corner points with the camera center.
% The sketch may require manual adjustment of the viewpoint
% to get the most satisfactory results. The rotation may be enabled by rotate3d
% or interactively, by clicking the 3D rotate icon on the figure window.
% 
% Usage: fig = showcams(fh,foclen,P1,im1,P2,im2, ...) 
% Usage: fig = showcams(fh,foclen,P,im)
% Inputs:
%      Variable number of input parameters. The function may be called in two ways.
%    fh      1x1  Figure handle of the 3D plot where the camera is to be drawn.
%    foclen  1x1  A focal length to control the visual 
%      appearance of the camera(s), not necessarily the true focal length. 
%      If a negative value is specified, foclen=5 is set.
%    P1   [3 x 4]  Camera projection matrix.
%    im1  [m x n x l]  Image of the P1 camera, it can be either
%      grayscale or RGB.
%    P2, im2 ..   More cameras and more images can be given.
%    P, im   Alternatively the images and cameras can be also organized in cell
%      arrays, P={P1,P2,P3,...} and
%      im={im1,im2,im3,...}. This is useful for
%      multiple camera settings. 
% Outputs:
%    fig  1x1  Figure handle of the 3D plot.
% See also: cameragen, P2KRtC.
%
%

if foclen<0
  foclen = 5;
end

alpha_par = 0.9; % set to 1 if you want no transparency

figure(fig);

N = length(varargin);
if N==2 
  if ~iscell(varargin{1}),
    cams{1} = varargin{1};
    imgs{1} = varargin{2};
  else 
    cams = varargin{1};
    imgs = varargin{2};
  end
else
  cams = varargin{1:2:N};
  imgs = varargin{2:2:N};
end

% The variable number of input parameters is parsed into
% cell arrays cams{1:N} and  imgs{1:N}, where N
% denotes the number of cameras, that contain camera matrices and
% images, respectively.
for i = 1:size(cams,2) % for all cameras
  P = cams{i};
  img = imgs{i};    
% For all specified cameras and images do:
% Decompose the P matrix into intrinsic and extrinsic
% parameters, see P2KRtC.
  [K,R,t,C] = P2KRtC(P);
%  Back project the corner pixels into the scene.
  [m n d] = size(img);
  U = [1 1; 1 m; n m; n 1]';
  U(3,:) = 1;
  X = pinv(P)*U;  % back projection
  X = X ./ repmat(X(end,:),4,1);  X = X(1:3,:);  % normalization
% Direction vectors from the camera center to the back-projected
% image corners.
  dirvec = X - repmat( C, 1, length(X) );
  dirvec = dirvec ./ repmat( sqrt(sum(dirvec.^2)), 3, 1 );
%  Compute the coordinate of the image plane corners
% in the world coordinate system.
  X = dirvec*foclen + repmat(C,1,length(X));
  plot3( X(1,:), X(2,:), X(3,:), 'o' )
%  Prepare the image for warping. Create the image plane
% from the back-projected corner points, and do the warp
% by employing surface.
  if d==3 % RGB image
    if i>1   % re-use the colormap
      [imind,cmap] = rgb2ind( uint8(img), cmap );
    else
      [imind,cmap] = rgb2ind( uint8(img), 256 );
    end
  else % gray scale image
    imind = uint8(img);
    cmap  = colormap( gray(256) );
  end
  for j=1:3  % vertices for the image plane 
    implane(:,:,j) = [X(j,[1,4]); X(j,[2,3])];
  end 
  h = surface( implane(:,:,1), implane(:,:,2), implane(:,:,3), imind, ... 
      'FaceColor','texturemap', 'EdgeColor','none', 'CDataMapping','scaled' );
  alpha( h, alpha_par )  % set image planes transparent
%  Finally, plot the lines connecting the camera center
% with the corners of the image plane and attach a label to the camera center.
  for j=1:4
    line( [C(1),X(1,j)], [C(2),X(2,j)], [C(3),X(3,j)] )
  end
  plot3( C(1), C(2), C(3), 'x', 'MarkerSize',10, 'LineWidth',3 );
  text( C(1), C(2), C(3), sprintf('  C_%d',i), 'BackgroundColor','yellow' );
  colormap(cmap);
end  % end of the all-cameras loop


