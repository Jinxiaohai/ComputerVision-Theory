%IMTHRESH_DEMO Demo showing the usage of imthresh.m.
% CMP Vision Algorithms http://visionbook.felk.cvut.cz

% Example
%
% The function imthresh is used as follows:

ImageDir='images/';%directory containing the images

addpath('..') ;
cmpviapath('..') ;

if (exist('output_images')~=7)
  mkdir('output_images');
end

im = imread([ImageDir 'figures2.jpg']);
[out,threshold] = imthresh(im);


figure(1);
imagesc(im); % title('input image');
axis image ; axis off ; colormap(gray) ;
exportfig(gcf,'output_images/imthresh_input.eps')

figure(2); 
imagesc(out); % title('output image');
axis image ; axis off ; colormap(gray) ;
exportfig(gcf,'output_images/imthresh_output.eps')

figure(3) ; 
imhist(im);
hold on;
h=plot([threshold threshold],[0 max(imhist(im))],'r-','Linewidth',3);
legend(h,{'threshold'});
exportfig(gcf,'output_images/imthresh_histogram.eps')
hold off


