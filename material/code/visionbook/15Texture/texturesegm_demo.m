% TEXTURESEGM_DEMO --- Demo for texturesegm
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Example
%
% We shall use four textures from Figure ??.

close all
clear all 
addpath('..') ;
cmpviapath('..',1) ;
ImageDir='images/';
if (exist('output_images')~=7)
  mkdir('output_images');
end

t1 = im2double( imread([ImageDir 'D112.png']) );
t2 = im2double( imread([ImageDir 'D17.png']) );
t3 = im2double( imread([ImageDir 'D4.png']) );
t4 = im2double( imread([ImageDir 'D95.png']) );



[m,n] = size(t1);
[x,y] = meshgrid( 1:n, 1:m );
maskt = 1 + floor( 4*(x-1)/m );
imtrain = t1.*(maskt==1) + t2.*(maskt==2) + t3.*(maskt==3) + t4.*(maskt==4);

figure(1) ; imagesc(maskt) ; axis image ; axis off ; colorbar
exportfig(gcf,'output_images/texturesegm1.eps') ;
figure(2) ; imagesc(imtrain) ; axis image ; axis off ; colormap(gray) ;
exportfig(gcf,'output_images/texturesegm2.eps') ;

% The model is learnt from the training image.

model = texturesegmtrain( imtrain, maskt );

% The test image imtest is constructed from the same textures but
% the mask (mask) is
% more complicated, Figure ??be.


figure(3) ;
mask1 = ( ((x-0.75*n).^2 + (y-0.5*m).^2) < 20000 );
mask2 = ( x>100 & x<300 & y>50 & y<250 );
mask3 = ( x>100 & x<450 & y>350 & y<600) & not(mask1);
mask  = 1 + mask1 + 2*mask2 + 3*mask3;
imagesc(mask) ; colormap(jet) ; axis image ; axis off ; colorbar ;
exportfig(gcf,'output_images/texturesegm3.eps') ;

imtest = t1.*(mask==1) + t2.*(mask==2) + t3.*(mask==3) + t4.*(mask==4);
figure(4) ;
imagesc(imtest) ; axis image ; axis off ; colormap(gray) ; 
exportfig(gcf,'output_images/texturesegm4.eps') ;

% The texture segmentation 
% algorithm is applied with default regularization.

l = texturesegm( imtest, model );

% The final segmentation can be seen in Figure ??cf as 
% boundaries superimposed over the test image and as a mask. Most
% of the texture regions were identified correctly. 

figure(5) ;
imagesc(l) ; axis image ; axis off ; colorbar ;
exportfig(gcf,'output_images/texturesegm5.eps') ;
lb=imdilate(l,strel('disk',4))-l ; 

figure(6) ;
imagesc(imtest) ; colormap(gray) ; axis image ;  axis off ;hold on ;
contour(lb,[1 1],'r','LineWidth',2) ; hold off ;
exportfig(gcf,'output_images/texturesegm6.eps') ;
