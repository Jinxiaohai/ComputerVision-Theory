% THINNING_DEMO Demo showing the usage of thinning
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Example
%
% The thinning transformation is tested with different structuring
% elements from the Golay alphabet .

addpath ../.;
cmpviapath('../.');
if (exist('output_images')~=7)
  mkdir('output_images');
end

ImageDir = 'images/' % directory containing the images

im = imread([ImageDir 'spoons_binary_holes.png']) > 0;
figure(1);imshow(im,[]);colormap(gray);
exportfig(1,'output_images/thinning_original.eps');

golayL(:,:,1,1) = [0 0 0; 0 1 0; 1 1 1];
golayL(:,:,2,1) = [1 1 1; 0 0 0; 0 0 0];
golayL(:,:,1,2) = [0 0 0; 1 1 0; 0 1 0];
golayL(:,:,2,2) = [0 1 1; 0 0 1; 0 0 0];

skel = thinning( im, golayL, 0 );
im_show = double( repmat(im,[1 1 3]) );
im_show(:,:,2:3) = im_show(:,:,2:3) - repmat(double(skel),[1 1 2]);
figure(2);imshow(im_show,[]);
exportfig(2,'output_images/thinning_thinning.eps');

golayE(:,:,1,1) = [0 0 0; 0 1 0; 0 0 0];
golayE(:,:,2,1) = [1 1 1; 1 0 1; 1 0 0];
golayE(:,:,1,2) = [0 0 0; 0 1 0; 0 1 0];
golayE(:,:,2,2) = [1 1 1; 1 0 1; 0 0 0];

skel = thinning( skel, golayE, 6 );

im_show = double(repmat(im,[1 1 3]));
im_show(:,:,2:3) = im_show(:,:,2:3) - repmat(double(skel),[1 1 2]);
figure(3);imshow(im_show,[]);
exportfig(3,'output_images/thinning_pruning.eps');

skel = thinning( skel, golayE, 0 );  

im_show = double(repmat(im,[1 1 3]));
im_show(:,:,2:3) = im_show(:,:,2:3) - repmat(double(skel),[1 1 2]);
figure(4);imshow(im_show,[]);
exportfig(4,'output_images/thinning_pruning_inf.eps');


