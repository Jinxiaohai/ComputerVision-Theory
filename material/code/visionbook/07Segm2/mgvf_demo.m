% MGVF_DEMO Demo showing the usage of a GVF  snake 
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Example
% 
% The example shows how to use a GVF snake for segmenting a lung from
% a CT (computed tomography) image 

ImageDir='images/';%directory containing the images
addpath('..') ;
cmpviapath('..') ;
if (exist('output_images')~=7)
  mkdir('output_images');
end


im = dicomread( [ImageDir 'ctslice.dcm'] );

% An initial position is found manually, using snakeinit. 

load ctplic

figure(1);
imagesc(im) ; colormap(gray) ; axis image ; axis off ; hold on ;
plot([x;x(1,1)],[y;y(1,1)],'r','LineWidth',2) ; hold off ;
exportfig(gcf,'output_images/mgvf_input.eps') ;


% For GVF snakes, the external energy is supposed to be an 
% edge map, with high values at the locations to which 
% we want the snake to be attracted.
% We create it by taking a magnitude of the gradient of the smoothed
% and normalized image, 
% E=\|  G_sigma * f \|. Small values are
% suppressed by thresholding 

f = double(im);   f = f-min(f(:));   f = f/max(f(:));
h = fspecial( 'gaussian', 20, 3 );
f = imfilter( f, h, 'symmetric' );
[px,py] = gradient(f);
E = sqrt( px.^2 + py.^2 );
E = E .* (E>0.02);

figure(2) ;
imagesc(E) ; colormap(jet) ; colorbar ; axis image ; axis off ; 
exportfig(gcf,'output_images/mgvf_energy.eps') ;

% Applying mgvf calculates the force field ux, uy
% which is fed into the snake evolution function snake. 
% Note that lambda=0 as no balloon force is
% needed. 
% The calculation takes a minute or two.


if 1, % set to 0 to avoid recalculating
[fx,fy]= mgvf(E) ;
kappa=1/(max(max(fx(:)),max(fy(:)))) ;
[x,y]=snake(x,y,0.1,0.01,0.3*kappa,0,fx,fy,0.4,1,im);

figure(3) ;
clf ; imagesc(im) ;  colormap(gray) ; axis image ; axis off ; hold on ;
plot([x;x(1)],[y;y(1)],'r','LineWidth',2) ; hold off ;
exportfig(gcf,'output_images/snake_output.eps') ;
end ;


