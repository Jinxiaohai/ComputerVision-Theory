%REMSMALL_DEMO Demo showing the usage of remsmall
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Example
%
% We apply small region removal remsmall algorithm to
% the segmentation results of regmerge
% (Section ??).
%

addpath('..') ;
cmpviapath('..') ;

ImageDir='images/';%directory containing the images

if (exist('output_images')~=7)
  mkdir('output_images');
end



if 1,
img=imresize(imread([ImageDir 'figures2.jpg']),[120 160],'nearest') ;
img=medfilt2(img,[3 3]) ;
l=regmerge(img,5,40,0.2,0.3) ;
p=remsmall(img,l,10) ;
figure(1) ; 
image(label2rgb(p,'jet','w','shuffle')) ; axis image ; axis off
exportfig(gcf,'output_images/remsmall_output.eps') ;

end


