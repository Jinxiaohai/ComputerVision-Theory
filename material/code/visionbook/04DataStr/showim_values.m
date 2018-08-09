function [fig,h] = showim_values(im,cfg,fig)
% SHOWIM_VALUES display image values
% CMP Vision Algorithms http://visionbook.felk.cvut.cz 
% Tomas Svoboda, 2007
% An auxiliary function showim_values complements imshow or 
% image(sc). It displays image values inside a rectangular grid.
% The function is used many times throughout the book when image values
% require closer inspection. If the input image is of data type
% logical small black-filled squares are printed at the
% position of 1,
% Printing of binary images was motivated by generating example images
% for binary morphology, image geometry and image segmentation.
% 
% Note: Larger images may require some tuning of the parameters and/or
% size of the figure window, set(gcf,'Position',[left bottom width height]).
% 
% Usage: [fig,h] = showim_values(im,cfg,fig)
% Inputs:
%   im  [m x n]   Input image to be displayed.
%   cfg  struct  Structure with config parameters. Not all
%     parameters below need to be specified.
%   .colormap  [N x 3] 
%                  Colormap, see colormap for explanation. 
%                  By default it adapts to the image content.
%   .rowshift  (default 0.05) 
%                  Row shift. Fine tuning of the text positions. 
%   .colshift  (default -0.1) 
%                  Column shift. Fine tuning of the text positions.
%   .txtcol   (default 'black') 
%                  Color of the text.  A particular    
%                  option is 'neg', which prints numbers in 
%                  black or white depending on the image values.
%   .fontsize  (default 16) 
%                  Font size. 
%   .gridcol  (default 'black') 
%                  Color of the grid lines.
%   .colormapping  (default 'scaled') 
%                  See image for details.
%   .rectwidth  (default 0.8) 
%                  Width of the black-filled rectangle.
%                  The width is relative to the grid size.
%   .xdata  (default [1:n]) 
%                  x-coordinates of the image. 
%   .ydata  (default [1:m]) 
%                  y-coordinates of the image. 
%   fig  1x1  Figure handle. If not specified, a new figure window is opened.
% Outputs:
%   fig  1x1  Figure handle.
%   h    1x1  Handle of the image object. 
% See also: image, imagesc, imshow, text.
% 

% History:
% $Id: showim_values_decor.m 1074 2007-08-14 09:45:42Z kybic $
%
% 2007-04-11 Tomas Svoboda (TS): gathered isolated pieces of codes
%                                and created this function
% 2007-04-30 TS: new decoration
% 2007-06-08 TS: 'neg' color added
% 2007-06-27 TS: decor refinement 
% 2007-07-03 TS: handling of xdata and ydata added
% 2007-07-04 TS: better displaying of non-integer data
% 2007-08-09 TS: refinement for better looking of m-files

[r,c] = size(im);
howmany = length(unique(im));
values = linspace(1,0.5,howmany)';

try mycolmap = cfg.colormap; catch mycolmap = repmat(values,1,3); end;
try rs = cfg.rowshift; catch rs = 0.05; end;
try cs = cfg.colshift; catch cs = -0.1; end;
try txtcol = cfg.txtcol; catch txtcol = 'black'; end;
try fontsize = cfg.fontsize; catch fontsize = 16; end;
try gridcol = cfg.gridcol; catch gridcol = 'black'; end; 
try colormapping = cfg.colormapping; catch colormapping = 'scaled'; end
try rw = cfg.rectwidth; catch rw = 0.8; end
try xdata = cfg.xdata; catch xdata = [1:size(im,2)]; end;
try ydata = cfg.ydata; catch ydata = [1:size(im,1)]; end;

if islogical(im)
  mycolmap = [1,1,1];
end

% open a new figure window if no figure handle is specified
try figure(fig);catch fig=figure; end

h = image(im,'CDataMapping',colormapping,'Xdata',xdata,'Ydata',ydata); 
colormap(mycolmap);
hold on;
axis image

if ~islogical(im) % grayscale image is assumed
  for i=1:r,
    for j=1:c,
      x = xdata(j); y = ydata(i);
      if strcmp(txtcol,'neg')
        usecolor(1:3) = double(im(i,j)<127);
      else
        usecolor = txtcol;
      end
      if abs(round(im(i,j))-im(i,j))<eps % integer number
        str2disp = sprintf('%3d',im(i,j));
      elseif im(i,j)<1 % 1/integer
        str2disp = sprintf('1/%d',round(1/im(i,j)));
      else % general floating point number
        str2disp = sprintf('%.2f',im(i,j));
      end
      text(x+cs,y+rs,str2disp,'color',usecolor,'FontSize',fontsize,...
           'HorizontalAlignment','center','VerticalAlignment','middle');
      
    end
  end
else % binary image
  for i=1:r,
    for j=1:c,
      if im(i,j)
        rectangle('Position',[j-rw/2,i-rw/2,rw,rw],'FaceColor','k')
      end
    end
  end
end

% printing grid lines
xlim = get(gca,'Xlim');
xd = xlim(1):xlim(2);
ylim = get(gca,'Ylim');
yd = ylim(1):ylim(2);
for i=1:c,
  line([xd(i),xd(i)],ylim,'Color',gridcol);
end
for i=1:r,
  line(xlim,[yd(i),yd(i)],'Color',gridcol);
end

% the tick are typically unwanted here
set(gca,'TickLength',[0,0])

return; % end of showim_values