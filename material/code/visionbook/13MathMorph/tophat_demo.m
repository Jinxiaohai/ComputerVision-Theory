% TOPHAT_DEMO --- Demo showing tophat to detect intensity peaks
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Example
% The top hat transformation is applied to an image of randomly
% positioned and scaled 2D Gaussians, see
% Figure ??a.

addpath ../.;
cmpviapath('../.');
if (exist('output_images')~=7)
  mkdir('output_images');
end


ImageDir = 'images/' % directory containing the images

im = imread( [ImageDir 'rand.png'] );

figure(1);imshow(im,[0 255]);colormap jet
exportfig(1,'output_images/tophat_original.eps');


figure(2);imshow(imerode(im,strel('disk',5)),[0 255]);colormap jet
exportfig(2,'output_images/tophat_erode5.eps');
figure(3);imshow(imopen(im,strel('disk',5)),[0 255]);colormap jet
exportfig(3,'output_images/tophat_open5.eps');

im_tophat = tophat( im, strel('disk',5) );
figure(4);imshow(im_tophat,[0 255]);colormap jet
exportfig(4,'output_images/tophat_hat5.eps');
im_tophat = tophat( im, strel('disk',10) );
figure(5);imshow(im_tophat,[0 255]);colormap jet
exportfig(5,'output_images/tophat_hat10.eps');
im_tophat = tophat( im, strel('disk',20) );
figure(6);imshow(im_tophat,[0 255]);colormap jet
exportfig(6,'output_images/tophat_hat20.eps');

