% imgeomt_demo demonstration of the imgeomt function
% CMP Vision Algorithms, http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007

% $Id: $


addpath ../.
cmpviapath('../.');
% create a directory for output images
% if needed and does not already exist
out_dir = './output_images/';
if (exist(out_dir)~=7)
  mkdir(out_dir)
end

set(0,'DefaultAxesFontSize',18)

% A geometrical transformation is demonstrated on correction of converging lines; these
% occur due to perspective distortion and are often an unwanted
% phenomenon in photos of architecture or in some machine vision problems.
% The points are pre-specified for convenience. A new set can be specified
% interactively by setting NEWPOINTS=1. 
NEWPOINTS = 0; % set to 1 if you want to click the corresponding pairs
step_size = 1;
im = imread('images/tower_cropped.jpg');

figure(1); clf
imshow(im);
title('input image')
hold on;
axis on;
xlabel('x-axis');
ylabel('y-axis');


u1=[ 17   630; ...
     470   630; ...
     155    76; ...
     292    76];

u2=[134   630; ...
    288   631; ...
    134    76; ...
    287    76];

u1(:,2) = u1(:,2)-40;
u2(:,2) = u2(:,2)-40;

for i=1:4
  if NEWPOINTS
    disp(sprintf('click source point No %d',i))
    [x,y] = ginput(1);
    u1(i,:) = [x,y];
  end
  plot(u1(i,1),u1(i,2),'go','LineWidth',3,'MarkerSize',7)
  if NEWPOINTS
    disp(sprintf('click destination point No %d',i))
    [x,y] = ginput(1);
    u2(i,:) = [x,y];
  end
  plot(u2(i,1),u2(i,2),'ro','LineWidth',3,'MarkerSize',7)
  quiver(u1(i,1),u1(i,2),u2(i,1)-u1(i,1),u2(i,2)-u1(i,2), 'Color', 'g','AutoScaleFactor',1,'LineWidth',2)
  drawnow;
end;

% Compute the geometrical transform between set of corresponding points 
% by using the u2Hdlt.
[H,T1,T2] = u2Hdlt( u1', u2', 1 );
[imnew,axesofnew] = imgeomt( H, im, 'cubic', step_size );


figure(2); clf
% Displaying the new image with its true spatial coordinates.
imshow( imnew, 'XData', axesofnew.x, 'YData', axesofnew.y );
% The result is shown in Figure ??.
title('transformed image')
axis on;
xlabel('x-axis');
ylabel('y-axis');
hold on;
[r,c] = size(imnew);
step = 50;
plot(u2(:,1),u2(:,2),'ro','LineWidth',3,'MarkerSize',7)

% saving old and new image
figure(1),
exportfig(gcf,[out_dir,'imgeomt_input.eps'])
figure(2),
exportfig(gcf,[out_dir,'imgeomt_output.eps'])

% demo with grid
% To demonstrate the back-mapping, we add a regular grid to the new image
% and call imgeomt with the inverted transform. This is how
% back-mapping works. It traverses the grid of the new image and `looks' back
% to the original image for the intensities. The back-mapped coordinates are
% not integers and values are computed by interpolations, see interp2.


step=20;
im = imnew;
for i=[-1:1]
  im([2:step:end-1]+i,:,1) = 255;
  im(:,[2:step:end-1]+i,1) = 255;
end
figure(3), clf
imshow(im,'XData',axesofnew.x([1,end]),'YData',axesofnew.y([1,end]));
axis on;
xlabel('x-axis');
ylabel('y-axis');
title('regular grid on the new image')
exportfig(gcf,[out_dir,'imgeomt_input_withgrid.eps'])
[imnew,axesofnew] = imgeomt( inv(H), im, 'bilinear', step_size, axesofnew );
figure(4), clf
imshow(imnew,'XData',axesofnew.x([1,end]),'YData',axesofnew.y([1,end]));
axis on;
xlabel('x-axis');
ylabel('y-axis');
hold on;
title('back-mapped grid to the original image')
exportfig(gcf,[out_dir,'imgeomt_output_withgrid.eps'])

