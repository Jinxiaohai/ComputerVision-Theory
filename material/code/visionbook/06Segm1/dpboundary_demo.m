%DPBOUNDARY_DEMO Demo showing the usage of dpboundary
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Example
%
% We demonstrate dpboundary on the task of tracing a blood vessel  
% on part of an MRI image
% of a~lower limb. 
% Since the vessel is bright, we take a negative value of the 
% brightness as the cost function.
% 
ImageDir='images/';%directory containing the images

if (exist('output_images')~=7)
  mkdir('output_images');
end

im = imread( [ImageDir 'limb_vessels2.jpg'] );
x = dpboundary( -double(im) );

figure(1) ; 
imagesc(im); % title('input image');
axis image ; axis off ; colormap(gray) ;
print -depsc output_images/dpboundary_input.eps


figure(2) ; 
imshow(im) ; axis image ; axis off ; colormap(gray) ; 
hold on ; plot(x,1:size(im,1),'r-') ; hold off ;
print -depsc output_images/dpboundary_output.eps

