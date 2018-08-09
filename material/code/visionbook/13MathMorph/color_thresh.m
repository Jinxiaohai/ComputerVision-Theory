function im_bin = color_thresh(im,pt,th)
% COLOR_THRESH Thresholding in color space.
% CMP Vision Algorithms cmpvia@cmp.felk.cvut.cz
% Function color_thresh performs thresholding in color
% space. First, the image im is transformed to the YUV
% color system.
% The Euclidean distance in UV color space of each image point from
% the point pt is evaluated. The background is segmented by
% thresholding the distance.

  
  imYUV = rgb2ntsc(im);
  ptU = imYUV(pt(1),pt(2),2); % value in the U channel
  ptV = imYUV(pt(1),pt(2),3); % value in the V channel
  dist = (imYUV(:,:,2)-ptU).^2+(imYUV(:,:,3)-ptV).^2; 
  im_bin = dist > th; 
return;