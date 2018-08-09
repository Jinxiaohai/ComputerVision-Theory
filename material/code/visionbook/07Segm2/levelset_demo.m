% LEVELSET_DEMO Demo showing the usage of levelset 
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Example
%
% We first apply level set segmentation to an X-ray image of the hand,
% scaled down to 203x 224 pixels - the segmentation takes 1--2
% minutes. We create an initial level set function corresponding to
% the contour shown  
% The segmentation is driven by the Chan-Vese functional, taking advantage
% of the intensity differences between background and
% foreground. Constant weight g is used.

ImageDir='images/';%directory containing the images
addpath('..') ;
cmpviapath('..') ;

out_dir = 'output_images/';
if (exist(out_dir)~=7)
  mkdir(out_dir);
end

img = double( imread([ImageDir 'xhand3.png']) );
img = imresize( img, 0.25 );
[ny,nx] = size(img);
[x,y]   = meshgrid( 1:nx, 1:ny );
f = sqrt( (x-100).^2 + (y-175).^2 ) - 50;
g = ones( ny, nx );

close all ;
figure(1) ;  imagesc(img) ; colormap(gray) ; axis equal ; axis tight ; hold on ; 
contour(f,[0 0],'r') ; hold off ; colorbar ;
print -depsc2 -cmyk output_images/levelset_input.eps
figure(2) ;imagesc(f) ; colorbar ;
hold on ; 
contour(f,[0 0],'k') ; hold off ; 
print -depsc2 -cmyk output_images/levelset_lsetinput.eps



if 1,
f1=levelset(f,img,10,0,60,30,0.1,0.2,0.1,g,2) ;
figure(3) ;imagesc(img) ; colormap(gray) ; colorbar ; 
axis equal ; axis tight ; hold on ; 
contour(f1,[0 0],'r') ; hold off ; 

print -depsc2 -cmyk output_images/levelset_output.eps
figure(4) ;imagesc(f1,[-100 100]) ; colorbar ;
hold on ; 
contour(f1,[0 0],'k') ; hold off ; 
print -depsc2 -cmyk output_images/levelset_lsetoutput.eps
end ;


% A zero level set can be shown superimposed on an image as follows:

% The second example of segmenting ventricles in an MRI brain slice
% demonstrates the possibility of
% a topology change during level set evolution. The initial contour is
% a simple circle but it is divided into two objects after some
% iterations, each of them independently converging to a ventricle shape.

img = double( imread([ImageDir 'mribrain.png']) );
[ny,nx] = size(img);
[x,y]   = meshgrid( 1:nx, 1:ny );
f = sqrt( (x-128).^2 + (y-112).^2 ) - 5;
g = ones( ny, nx );

figure(1) ; clf ;
imagesc(img) ; colormap(gray) ; axis equal ; axis tight ; hold on ; 
contour(f,[0 0],'r') ; hold off ; colorbar ;
print -depsc2 -cmyk output_images/levelset_input2.eps
figure(2) ;imagesc(f) ; colorbar ;
hold on ; 
contour(f,[0 0],'k') ; hold off ; 
print -depsc2 -cmyk output_images/levelset_lsetinput2.eps


if 1,
f1=levelset(f,img,500,0,30,100,0.5,0.5,0.05,g,1) ;

figure(3) ;imagesc(img) ; colormap(gray) ; axis equal ; axis tight ; hold on ; 
contour(f1,[0 0],'r') ; hold off ; colorbar ;

print -depsc2 -cmyk output_images/levelset_output2.eps
figure(4) ;imagesc(f1,[-100 100]) ; colorbar ;
hold on ; 
contour(f1,[0 0],'k') ; hold off ; 
print -depsc2 -cmyk output_images/levelset_lsetoutput2.eps
end ;

