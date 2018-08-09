% REGIONDESCR_DEMO Demo showing the usage of regiondescr
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Example
% 
% We show how to use region descriptors to identify the same objects in
% different images by their shape. We start with three grayscale images
% which we segment to identify
% foreground and background. While it is possible to use a simple
% segmentation technique such as imthresh, the
% results suffer due to
% inhomogeneous illumination. We chose therefore to use a more
% sophisticated edge-based graph cut segmentation 
% which gives better results. The graphcut segmentation is encapsulated 
% in a function graphcut_segmentation.

close all ;
clear all ;
addpath('..') ;
cmpviapath('..',0) ;

if (exist('output_images')~=7)
  mkdir('output_images');
end


ImageDir='images/';%directory containing the images

img1 = im2double( rgb2gray( imread([ImageDir 'objectsA1.jpg']) ) );
img2 = im2double( rgb2gray( imread([ImageDir 'objectsA2.jpg']) ) );
img3 = im2double( rgb2gray( imread([ImageDir 'objectsA3.jpg']) ) );

img1s = graphcut_segmentation(img1);
img2s = graphcut_segmentation(img2);
img3s = graphcut_segmentation(img3);

% We identify objects as connected components  
% in the binary images using bwlabel which we have also used in
% meanshsegm.
% Background pixels are labelled as 0 and pixels
% of each object are marked by an integer from 1 to the number of
% objects. The resulting multiclass segmentation is shown in
% Figure ?? (middle row) where dark blue corresponds
% to the background, object 1 is in magenta, object 2 in yellow, and
% object 3 in dark red. 

img1l = bwlabel(img1s);
img2l = bwlabel(img2s);
img3l = bwlabel(img3s);

figure(1) ;
imagesc(img1l) ;
axis image ; axis off ;
exportfig(gcf,'output_images/regiondescr_initial1.eps') ;

figure(2) ;
imagesc(img2l) ;
axis image ; axis off ;
exportfig(gcf,'output_images/regiondescr_initial2.eps') ;

figure(3) ;
imagesc(img3l) ;
axis image ; axis off ;
exportfig(gcf,'output_images/regiondescr_initial3.eps') ;

% Naturally, the same objects are assigned
% different classes in the three segmentations. We show how the region
% descriptors can help us establish object identities across our 
% three images.
% 
% Function regiondescrn finds the descriptors varphi using
% regiondescr
% of all objects in the image and returns a matrix where
% row i corresponds to an object with label i.

phi1 = regiondescrn(img1l);
phi2 = regiondescrn(img2l); 
phi3 = regiondescrn(img3l); 

% Examining the descriptors shows that their amplitude indeed
% characterizes the objects quite well, especially for the first four lower
% order descriptors varphi_1,...,varphi_4.

% We take the first image as a reference and in the other two images
% identify the corresponding objects as follows: for each object 
% descriptor vector [varphi_1 ... varphi_7] we find the object in
% the reference image with the closest (nearest neighbor) descriptor vector,
% in the sense of
% minimum Euclidean distance l_2. This is done in function
% nnmatch. (More advanced classification techniques can
% be used if needed .)
% Then, the class labels are remapped 
% according to the reference image. The initial 0 in ind
% corresponds to the background class, which is preserved.

ind = [0 nnmatch(phi1,phi2)];
img2r = ind(img2l+1);
ind = [0 nnmatch(phi1,phi3)];
img3r = ind(img3l+1);

figure(6) ;
imagesc(img2r) ;
axis image ; axis off ;
exportfig(gcf,'output_images/regiondescr_final2.eps') ;
figure(7) ;
imagesc(img3r) ;
axis image ; axis off ;
exportfig(gcf,'output_images/regiondescr_final3.eps') ;



