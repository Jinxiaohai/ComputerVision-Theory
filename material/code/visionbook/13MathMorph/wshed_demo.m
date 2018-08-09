% WSHED_DEMO Demo showing the usage of wshed, segment scales on a gecko skin
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Example
% Watershed segmentation with automatic marker extraction
% is used to segment small and large scales on a gecko
% skin . The morphological operations used
% are not shape-dependent (except the opening to suppress
% noise). Therefore, the method is robust enough to segment both
% small and large scales.

addpath ../.;
cmpviapath('../.');
if (exist('output_images')~=7)
  mkdir('output_images');
end

ImageDir = 'images/' % directory containing the images

im = imread( [ImageDir 'gecko.png'] );
figure(1);imshow(rgb2gray(im));colormap gray;
exportfig(1,'output_images/wshed_gray.eps');
im_gray = rgb2gray(im); % converting to grayscale
regions = wshed( im_gray, 4, 33 ); % watershed segmentation


im_red = im(:,:,1);
im_red(regions == 0) = 255;
im(:,:,1) = im_red;

figure(4);imshow(im);
exportfig(4,'output_images/wshed_segmentation.eps');


