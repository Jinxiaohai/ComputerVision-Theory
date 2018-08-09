% demonstration of IMSHARPEN Image sharpening.
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, Petr Nemecek, 2006-2007

% $Id: $

close all;

addpath ../.
cmpviapath('../.');
% create a directory for output images
% if necessary, and does not already exist
out_dir = './output_images/';
if exist(out_dir)~=7
  mkdir(out_dir)
end

set(0,'DefaultAxesFontSize',18)

step=1; 
x1 = [step:step:100];
x2 = [(x1(end)+step):step:2*x1(end)];
n = 10;
Do_low = x1(round(length(x1)/2));
Do_high = x2(round(length(x1)/2));;
C = 20;
ymax = 255;
y1 = ymax*(x1./(Do_low+eps)).^(2*n)./( 1+(x1./(Do_low+eps)).^(2*n));
y2 = ymax-y1;
x = [x1,x2];
y = [y1,y2];
gy = gradient(y);
laplacian = gradient(gy);
laplaciansc = C*laplacian;
y_sharp = y - laplaciansc;
y_sharp_bound = y_sharp;
y_sharp_bound(y_sharp>255) = 255;y_sharp_bound(y_sharp<0) = 0;
ymin = min(y_sharp);
ymax = max(y_sharp);
h=figure(1); clf
subplot(4,1,1), plot(x,y,'-','LineWidth',2), axis([x([1,end]) ymin ymax]); 
hold on, line([Do_low,Do_low],[ymin,ymax],'color','k'), line([Do_high,Do_high],[ymin,ymax],'color','k')
title('original signal \it f')
subplot(4,1,2), plot(x,gy,'-','LineWidth',2)
hold on, line([Do_low,Do_low],1.1*[min(gy),max(gy)],'color','k'), line([Do_high,Do_high],1.1*[min(gy),max(gy)],'color','k')
title('first derivative \it \partial f / \partial x')
subplot(4,1,3), plot(x,laplaciansc,'-','LineWidth',2)
hold on, line([Do_low,Do_low],[min(laplaciansc),max(laplaciansc)],'color','k'), line([Do_high,Do_high],[min(laplaciansc),max(laplaciansc)],'color','k')
title('Second derivative - Laplacian (scaled) \it C \partial^2 f/\partial x^2')
subplot(4,1,4), plot(x,y,'b-','LineWidth',1), axis([x([1,end]) ymin ymax])
hold on, 
subplot(4,1,4), plot(x,y_sharp,'g-','LineWidth',4), axis([x([1,end]) ymin ymax])
subplot(4,1,4), plot(x,y_sharp_bound,'r-','LineWidth',2), axis([x([1,end]) ymin ymax])
legend('original signal','sharpened signal','truncated to <0,255>')
line([Do_low,Do_low],[ymin,ymax],'color','k'), line([Do_high,Do_high],[ymin,ymax],'color','k')
title('improved signal {\it f - C \partial^2 f/\partial x^2}')

screenres = get(0,'ScreenSize');
set(gcf,'Position',screenres+[5 9 -10 -89]);
print('-depsc2','-cmyk',[out_dir,'imsharpen_1D.eps']);

set(0,'DefaultAxesFontSize',12)


VERBOSITY = 1;
ImageDir='images/';%directory containing the images

IM=imread([ImageDir 'patterns.png']);
IM = imresize(IM,0.5);
if size(IM,3)>1
  IM=uint8(round(mean(IM,3)));
end

figure(2);imshow(IM);title('Original image');
exportfig(gcf,[out_dir,'sharpen_input.eps']);
for i = 0.5  % 0.1:0.2:1.5
  %sharpen the image using imsharpen.m:
  IM_out = imsharpen( IM, i, VERBOSITY );
if VERBOSITY>0
  figure(3);
  exportfig(gcf,[out_dir,'sharpen_gradients.eps']);
  figure(4);
  exportfig(gcf,[out_dir,'sharpen_laplacian.eps']);
end
  figure(5);  imshow(IM_out);  title(sprintf('Sharpened image, C=%0.1f',i));
exportfig(gcf,[out_dir,'sharpen_output.eps']);
end

