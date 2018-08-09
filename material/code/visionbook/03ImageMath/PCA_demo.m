% PCA_demo Demostration of PCA applied to images
% CMP Vision Algorithms, http://visionbook.felk.cvut.cz
% 

% Courtesy A. Leonardis, D. Skocaj 
% see http://vicos.fri.uni-lj.si/danijels/downloads

addpath ../.
cmpviapath('../.');
% Create a directory for output images
% if needed and does not already exist.
out_dir = './output_images/';
if (exist(out_dir)~=7)
  mkdir(out_dir)
end

clear all
close all

% Demonstration of PCA
%
% This example illustrates the use of principal component 
% analysis (PCA) applied to images: the
% collection of 32 gray images of size 321  x 261 serves as input.
% These images of a face were manually aligned by clicking
% to the nose, and cropped. 
%
% The 32 input images have to be reshaped to create one
% compound data matrix. The function creDatMatFromIm does
% the job: 

% Create the compound image from images provided in files.
[compoundImage,imsize] = creDatMatFromIm( 32, 'images/Jara', 'png' );

% Display input images from compoundImage
dispImgs( compoundImage, 8, 4, imsize );
set(gcf,'Name','Images which constitute the compound image');
print -depsc2 -cmyk output_images/InputImagesPCA-Jara.eps

% Set the reduced dimension of the eigenspace.
K = 4;

% Perform PCA, i.e., create an eigenspace from data matrix compoundImage
%   in which columns represent an image from the collection of images.
%   Parameter K indicatess how many eigenvectors and eigenvalues have to be
%   returned.
%   The function PCA returns mean image Xm, eigenvectors in columns of U
%   and eigenvalues L.
[Xm,U,L] = pca( compoundImage, K );

% Display K basis vector images.
dispImgs( U(:,1:K), K, 4, imsize );
set(gcf,'Name','Basis vector images');
print -depsc2 -cmyk output_images/PCA-BasisImagesJara.eps


% get vector A which contains coefficients in the PCA expansion
A = is2fs( compoundImage, Xm, U );
% convert the problem representation from the eigenspace back to the image space
Y = fs2is( A, Xm, U );

% Display the reconstructed originals.
dispImgs( Y, 8, 4, imsize );
set(gcf,'Name','Reconstructed original');
print -depsc2 -cmyk output_images/PCA-ReconstrOriginalsJara.eps

