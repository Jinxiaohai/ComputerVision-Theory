% ULTEROSION_DEMO Demo showing the usage of ultimate erosion
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Example
%
% Ultimate erosion is applied on an image of coffee beans in
% order to find a marker for each bean.

addpath ../.;
cmpviapath('../.');
if (exist('output_images')~=7)
  mkdir('output_images');
end

ImageDir = 'images/' % directory containing the images

imcolor = imread( [ImageDir 'coffee.png'] );

figure(1); imshow(imcolor,[]);
exportfig(1,'output_images/ulterosion_original.eps');

im = rgb2gray(imcolor);
im = im < 75;
figure(2);imshow(im,[]);colormap gray
exportfig(2,'output_images/ulterosion_thresholded.eps');

imInv = 1 - im; % inverted image
imMar = zeros( size(imInv) );  % markers are set on the image frame
imMar( 1:end, [1 size(imMar,2)] ) = 1;
imMar( [1 size(imMar,1)], 1:end ) = 1;
imMar = double( imMar & imInv ); % conversion from logical to double is needed
im = 1 - imreconstruct( imMar, imInv );

figure(3);imshow(im,[]);colormap gray
exportfig(3,'output_images/ulterosion_closed.eps');

im_out = ulterosion( im, 'cityblock' );

figure(5);imshow(im_out,[]);colormap gray
exportfig(5,'output_images/ulterosion_eroded.eps');

im_red = imcolor(:,:,1);
im_red( imdilate(im_out,strel('disk',3)) ) = 255;
imcolor(:,:,1) = im_red;

figure(6);imshow(imcolor,[]);
exportfig(6,'output_images/ulterosion_superposed.eps');


