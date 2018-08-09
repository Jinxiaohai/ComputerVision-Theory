%REGMERGE_DEMO Demo showing the usage of regmerge
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Example
%
% We apply region merging segmentation on 
% a scaled-down version of the image. Median filtering is used to
% suppress noise. Both of these operations make the algorithm run
% much faster.

addpath('..') ;
cmpviapath('..') ;

if (exist('output_images')~=7)
  mkdir('output_images');
end


ImageDir='images/';%directory containing the images



if 1,
img=imresize(imread([ImageDir 'figures2.jpg']),[120 160],'nearest') ;
img=medfilt2(img,[3 3]) ;
l=regmerge(img,5,40,0.2,0.3) ;
figure(1) ; 
imagesc(img); % title('input image');
axis image ; axis off ; colormap(gray) ;
exportfig(gcf,'output_images/regmerge_input.eps') ;

figure(2) ; 
image(label2rgb(l,'jet','w','shuffle')) ; axis image ; axis off
exportfig(gcf,'output_images/regmerge_output.eps') ;
end ;

