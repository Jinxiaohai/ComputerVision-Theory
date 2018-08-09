% image_view_demo Demonstration of simple viewing of the image
% CMP Vision Algorithms, http://visionbook.felk.cvut.cz
% Vaclav Hlavac, 2007
% 
% History:
% $Id: image_view_demo_decor.m 1088 2007-08-16 06:34:55Z svoboda $
%
% 2007-06-19 VH Written.
% 2007-06-29 VZ typo
% 2007-07-05 TS comments corrected
clear all;

addpath ../.
cmpviapath('../.');
% Create a directory for output images
% if needed and does not already exist.
out_dir = './output_images/';
if (exist(out_dir)~=7)
  mkdir(out_dir)
end

% read the input color image from a disk
boy = imread('images/Ondra_sampling.jpg');
% display the image in the MATLAB figure
image(boy);
axis image
% add the title to the figure
title('Input color image of a boy');
exportfig(gcf,[out_dir,'OndraColor.eps']);
% exportfig is a wrapper around the Matlab function print
% simple version would be
% print('-depsc',[out_dir,'OndraColor.eps'])



% extract individual color components
boyR = boy(:,:,1); % image with the red channel content
boyG = boy(:,:,2); % image with the green channel content
boyB = boy(:,:,3); % image with the blue channel content


figure;  % create a new MATLAB figure
% draw four images into the figure
subplot(2,2,1), subimage(boy),  axis off, title('boy - color image');
subplot(2,2,2), subimage(boyR), axis off, title('boyR - red channel');
subplot(2,2,3), subimage(boyG), axis off, title('boyG - green channel');
subplot(2,2,4), subimage(boyB), axis off, title('boyB - blue channel');
exportfig(gcf,[out_dir,'OndraFourColorComponents.eps']) ;


boyGray = rgb2gray(boy); % convert the color image into a grey-level one
figure;                  % create a new MATLAB figure
image(boyGray);          % display the grayscale image
colormap(gray(256));     % use the appropriate color map
axis off                 % switch off the axes with scales
% create a line segment between pixels (460,140) and (872,457),
% values given in (row,column) coordinates
r1 = 460;  c1 = 140;  r2 = 872;  c2 = 457;
% draw the line to the picture
line( [r1, r2], [c1, c2], 'Color','r', 'LineWidth',3 );
exportfig(gcf,[out_dir,'OndraGray.eps']) ;


% create a new MATLAB figure
figure;
% calculate and display the intensity profile
% along the line segment created earlier
improfile( boyGray, [r1, r2], [c1, c2] );
ylabel('Pixel value');
title('Intensity profile along the line segment');
exportfig(gcf,[out_dir,'OndraGrayProfile.eps']);

