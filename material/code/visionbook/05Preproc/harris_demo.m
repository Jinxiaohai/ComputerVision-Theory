% Example for harris.m
% History
% 2006-04     Petr Nemecek: created
% 2006-11-01  Tomas Svoboda: extended comments 
%
% Example
% The function harris is used as follows:

addpath ../.
cmpviapath('../.');
% create a directory for output images
% if necessary, and does not already exist
out_dir = './output_images/';
if exist(out_dir)~=7
  mkdir(out_dir)
end

set(0,'DefaultAxesFontSize',14)
set(0,'DefaultLineLineWidth',2)

ImageDir='./images/';%directory containing the images

img = imread([ImageDir 'figures.jpg']);
[corners] = harris( img, 1, 4, 25000, 2 ); 
% display the original image and overlay with the corners
figure;  imshow(img);  hold on
plot( corners(:,2), corners(:,1), 'y+', 'MarkerSize',15, 'LineWidth',5 );
plot( corners(:,2), corners(:,1), 'b+', 'MarkerSize', 5, 'LineWidth',1 ); 
exportfig(gcf,[out_dir,'harris_corners.eps'])
imwrite(img,[out_dir,'figures.jpg']);


