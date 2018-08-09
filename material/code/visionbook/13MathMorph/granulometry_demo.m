% GRANULOMETRY_DEMO Demo showing the usage of binary granulometry
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
addpath ../.;
cmpviapath('../.');
if (exist('output_images')~=7)
  mkdir('output_images');
end

ImageDir = 'images/' % directory containing the images
% Example
% Binary granulometry is used to label coins in a binary image with
% their size in order to distinguish between different coins. 
imcolor = double( imread([ImageDir 'coins.png']) ) / 255;
figure(1); imshow(imcolor,[]);
exportfig(1,'output_images/granulometry_original.eps');
pt = [10 10];
im = color_thresh( imcolor, pt, 0.022 );

im = imclose( im, strel('diamond',1) );
figure(2);imshow(im,[]); colormap(gray);
exportfig(2,'output_images/granulometry_binary.eps');

gS = granulometry( im );
figure(5);imshow(gS,[]); colormap(jet); colorbar
exportfig(5,'output_images/granulometry_granulometry.eps');

res = imreconstruct( gS, im.*max(gS(:)) );
res = res .* sqrt(2);

figure(6);imshow(res,[85 130]); colormap(jet); colorbar;
exportfig(6,'output_images/granulometry_labeled.eps');


