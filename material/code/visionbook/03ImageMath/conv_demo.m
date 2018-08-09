% CONV_DEMO pictorial explanation of 2D convolution
% CMP Vision Algorithms, http://visionbook.felk.cvut.cz
% Tomas Svoboda 2007-07-03

% History:
% $Id: conv_demo_decor.m 1088 2007-08-16 06:34:55Z svoboda $
% 
% 2007-07-03 Tomas Svoboda (TS) created
% 2007-07-05 TS comments enhanced

clear all;
close all;

set(0,'DefaultAxesFontSize',36)

addpath ../.
cmpviapath('../.');
% create a directory for output images
% if needed and does not already exist
out_dir = 'output_images/'
if (exist(out_dir)~=7)
  mkdir(out_dir);
end



% 
% First we define a [3 x 3] function f:
f = [1 0 0; 0 1 1; 0 0 2]; % function
fx =  0:2;                 % x-coordinates
fy = -1:1;                 % y-coordinates

% Note the problem with indirect indexing. For a straightforward
% implementation of the equations we would need direct indexing
% by x- and y- coordinates. This is not possible, as matrix indexes in Matlab\/
% can only be positive integers. We must handle the indexes separately.
% The [2 x 2] convolution kernel h is defined alike.
h = [1 2; -1 1]; % convolution kernel
hx =  2:3;       % x-coordinates
hy = -1:0;       % y-coordinates

cfg.gridcol = 1/2*[1 1 1]; % grid in gray
cfg.colormap = [1,1,1];    % gray scale image assumed
cfg.txtcol = 'k';          % numbers in negative               
cfg.colshift = 0;          % small tuning of the text position
cfg.fontsize = 38;
figure(1),clf
cfg.xdata=fx; cfg.ydata=fy;
[fig,h_im]=showim_values(f,cfg,gcf);
set(gca,'XTick',fx,'YTick',fy);
exportfig(gcf,[out_dir,'convdemo_f.eps'])

% The domain of the output function g is determined
% from the domain limits of f and h. 
gx = (fx(1)+hx(1)):(fx(end)+hx(end));
gy = (fy(1)+hy(1)):(fy(end)+hy(end));
g  = zeros( length(gy), length(gx) );
count = 0;
figure(20+count), clf
cfg.xdata = gx; cfg.ydata = gy;
[fig,h_im] = showim_values(g,cfg,gcf);
set(gca,'XTick',gx,'YTick',gy);
exportfig(gcf,[out_dir,sprintf('convdemo_g_step%02d.eps',count)])

% The main computation cycle runs over all kernel elements.
% The input signal f is copied and multiplied
% with each element of the kernel h. The result of the
% multiplication is written 
% starting from the position of the kernel element. At the end,
% g contains the result of the convolution g=f*h.
for i = 1:length(hx)
  for j = 1:length(hy)
    g_step = zeros( size(g) );  % location for particular result 
    rowidx = j:j+length(fy)-1;  % y-positions for the weighted copy
    colidx = i:i+length(fx)-1;  % x-positions for the weighted copy
    g_step( rowidx, colidx ) = f*h(j,i); % weighted and shifted copy of f
    g = g + g_step; % pixel wise summing
    count = sub2ind(size(h),j,i);
    %% show the convolution kernel
    figure(2), clf
    cfg.xdata = hx;  cfg.ydata = hy;
    [fig,h_im] = showim_values( h, cfg, gcf );
    set(gca,'XTick',hx,'YTick',hy);
    % mark the active kernel element
    rectangle( 'Position',[hx(i)-0.4,hy(j)-0.4 0.8 0.8], ...
               'EdgeColor','red', 'LineWidth',3 )
    exportfig(gcf,[out_dir,sprintf('convdemo_h_step%02d.eps',count)])

    % show the weighted and shifted copy of the input 
    figure(10+count), clf
    cfg.xdata=gx; cfg.ydata=gy;
    [fig,h_im] = showim_values(g_step,cfg,gcf);
    set(gca,'XTick',gx,'YTick',gy);
    %% upper left corner of the copy
    rectangle('Position',[gx(i)-0.4,gy(j)-0.4,length(fx)-0.2,length(fy)-0.2],'EdgeColor','red','LineWidth',3)
    %% emphasize the shift
    rectangle('Position',[gx(i)-0.4,gy(j)-0.4,0.8,0.8],'EdgeColor','b','LineWidth',3)
    exportfig(gcf,[out_dir,sprintf('convdemo_gstep_step%02d.eps',count)])

    %% show the result after count-step
    figure(20+count), clf
    [fig,h_im] = showim_values(g,cfg,gcf);
    set(gca,'XTick',gx,'YTick',gy);
    exportfig(gcf,[out_dir,sprintf('convdemo_g_step%02d.eps',count)])
  end
end
% check the results
g - conv2(f,h)

% demo with a real image

set(0,'DefaultAxesFontSize',24)
f = imread('images/glassblocks.png');
f = imresize(f,1/4,'bicubic');
f = double(f);
desc = 'glass';
fx = 1:size(f,2);
fy = 1:size(f,1);
h = [1,1,1];
h = h./sum(h);
hx = 0:size(h,2)-1;
hy = 0:size(h,1)-1;
gx = [(fx(1)+hx(1)):1:(fx(end)+hx(end))];
gy = [(fy(1)+hy(1)):1:(fy(end)+hy(end))];
g = zeros(length(gy),length(gx));

cfg.fontsize = 32;
figure(3), clf
cfg.xdata = hx; cfg.ydata = hy;
[fig,h_im] = showim_values(h,cfg,gcf);
set(gca,'XTick',hx,'YTick',hy)
exportfig(gcf,[out_dir,sprintf('convdemo_%s_h.eps',desc)])

figure(200);
h_im = imshow(uint8(f),'InitialMagnification',round(512/size(f,1)*100));
axis on
exportfig(gcf,[out_dir,sprintf('convdemo_%s_orig.eps',desc)])

count=0;
for i=1:length(hx)
  for j=1:length(hy)
    if h(j,i)
      count=count+1;
      g_step = zeros(size(g));   % allocation for particular result 
      rowidx = j:j+length(fy)-1; % y-positions for the result
      colidx = i:i+length(fx)-1; % x-positions for the result
      g_step(rowidx,colidx) = h(j,i)*f; % multiplication 
      g = g+g_step;
      figure(3), clf
      cfg.xdata = hx; cfg.ydata = hy;
      [fig,h_im] = showim_values(h,cfg,gcf);
      rectangle('Position',[hx(i)-0.4,hy(j)-0.4,0.8,0.8],'EdgeColor','red','LineWidth',3)
      set(gca,'XTick',hx,'YTick',hy)
      exportfig(gcf,[out_dir,sprintf('convdemo_%s_h_step%02d.eps',desc,count)])
      figure(100+count), clf
      h_im = imshow(uint8(g_step),'Xdata',gx,'Ydata',gy,'InitialMagnification',round(512/size(g,1)*100));
      axis on
      hold on;
      rectangle('Position',[gx(i)-0.4,gy(j)-0.4,length(fx)-0.2,length(fy)-0.2],'EdgeColor','red','LineWidth',3)
      exportfig(gcf,[out_dir,sprintf('convdemo_%s_gstep_step%02d.eps',desc,count)])
      figure(200+count), clf
      h_im = imshow(uint8(g),'Xdata',gx,'Ydata',gy,'InitialMagnification',round(512/size(g,1)*100));
      axis on
      exportfig(gcf,[out_dir,sprintf('convdemo_%s_g_step%02d.eps',desc,count)])
    end
  end
end



