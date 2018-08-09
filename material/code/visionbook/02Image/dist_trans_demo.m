% dist_trans_demo Demonstration of the distance transform
% CMP Vision Algorithms, http://visionbook.felk.cvut.cz
% Vaclav Hlavac, 2007
%

% History:
% $Id: dist_trans_demo_decor.m 1088 2007-08-16 06:34:55Z svoboda $
% 
% 2007-06-09 VH Written after dedecor started working on Win.
% 2007-06-19 VH A typo corrected.
% 2007-06-28 VH Small corrections.
% 2007-07-02 VZ typo
% 2007-07-03 VH J. Petr and V. Zyka's comments incorporated.
% 2007-07-07 VZ ', an example' has been removed from ch title
% 2007-08-15 TS refinement for better looking of the m-file

addpath ../.
cmpviapath('../.');
% Create a directory for output images
% if needed and does not already exist.
out_dir = './output_images/';
if (exist(out_dir)~=7)
  mkdir(out_dir)
end


%
% Read the color input image with the starfish.
imColor = imread('images/StarFishOnlyRGB.png');
figure(1), clf
image(imColor);
title('Input color image of a starfish');
exportfig(gcf,'output_images/dist-tx-starfish-RGB.eps') ;
% conversion color image into grayscale one
imGray = rgb2gray(imColor);
figure(2), clf
imagesc(imGray);
colormap(gray);
title('Starfish converted to grayscale image');
exportfig(gcf,'output_images/dist-tx-starfish-gray.eps') ;

% The single object corresponding to the starfish has to be 
% segmented from the background. The input image 
% containing only one starfish distinguished well by its intensity from
% the background was selected to make segmentation easy. 
% Segmentation can be performed
% by intensity thresholding which is implemented by the function
% im2bw: the threshold of 98% intensity was
% chosen. The function im2bw provides a logical image
% at its output. The pixel value 0 (black) corresponds 
% to the object, 1 (white) corresponds to the background.
imBlackWhite = im2bw(imGray, 0.98);
figure(3), clf
imagesc(imBlackWhite);
colormap(gray);
title('Segmented to logical image; 0-object; 1-background');
exportfig(gcf,'output_images/dist-tx-starfish-BW.eps') ;


% We are now ready to calculate the distance transform for the starfish object
% using four different metrics. We use function imagesc to display
% the result of the distance transform because it scales image data to the full
% range of the grayscale colormap. The values in the image are rather
% small and they would be almost black if scaling were not used.
%
% First, we will calculate the transform using D_E (Euclidean):
imDistTx=bwdist(imBlackWhite, 'euclidean');
figure(4), clf
imagesc(imDistTx);
colormap(gray);
title('Distance transform, distance {\itD}_E (Euclidean)');
exportfig(gcf,'output_images/dist-tx-starfish-DE.eps') ;

% Second, we use D_8 (chessboard):
imDistTx=bwdist(imBlackWhite, 'chessboard');
figure(5), clf
imagesc(imDistTx);
colormap(gray);
title('Distance transform, distance {\itD}_8 (chessboard)');
exportfig(gcf,'output_images/dist-tx-starfish-D8.eps') ;

% Third, we use D_4 (cityblock):
imDistTx=bwdist(imBlackWhite, 'cityblock');
figure(6), clf
imagesc(imDistTx);
colormap(gray);
title('Distance transform, distance {\itD}_4 (cityblock)');
exportfig(gcf,'output_images/dist-tx-starfish-D4.eps') ;

% And finally, we use D_ (quasi-Euclidean):
imDistTx=bwdist(imBlackWhite, 'quasi-euclidean');
figure(7), clf
imagesc(imDistTx);
colormap(gray);
title('Distance transform, distance {\itD}_{QE} (quasi-Euclidean)');
exportfig(gcf,'output_images/dist-tx-starfish-DQE.eps') ;




