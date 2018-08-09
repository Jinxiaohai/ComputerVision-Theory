% OBJDETECT_DEMO Demo showing the usage of objdetect
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Example
% This example shows detection of horizontally and vertically
% aligned spoons (Figure ??a).

addpath ../.;
cmpviapath('../.');
if (exist('output_images')~=7)
  mkdir('output_images');
end

ImageDir = 'images/' % directory containing the images

imcolor = imread([ImageDir 'spoons.png']);
  
figure(1); imshow(imcolor,[]);
exportfig(1,'output_images/objdetect_original.eps'); 

pt = [160 32];
im = color_thresh( imcolor, pt, 0.04 );

figure(2);imshow(im,[]);colormap(gray)
exportfig(2,'output_images/objdetect_binary.eps');

xh = objdetect( im, [1 40] );
xv = objdetect( im, [40 1] );

xshow = repmat(xv,[1 1 3]) .* double(imcolor)/255;
xshow( repmat(xv,[1 1 3])==0 ) = 1;
figure(5); imshow(xshow,[]);
exportfig(5,'output_images/objdetect_vertical.eps');

xshow = repmat(xh,[1 1 3]).*double(imcolor)/255;
xshow(repmat(xh,[1 1 3]) == 0) = 1; 
figure(6);imshow(xshow,[]);
exportfig(6,'output_images/objdetect_horizontal.eps');
 

