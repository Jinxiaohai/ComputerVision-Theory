function ret=drawrect(fig,roi,lw,col);
% DRAWRECT draws a rectangle 
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
% 
% ret=drawrect(fig,roi,lw,col)
% Inputs:
% fig        figure handles
% roi [4x1]  [upper left, lower right] 
% Optional:
% lw  1x1    line width, defaults to 1
% col string rectangle color, defaults to 'r'
% 
% Output
% ret   figure handle

% History
% $Id: drawrect.m 1079 2007-08-14 11:11:21Z svoboda $

try linewidth = lw; catch linewidth = 1; end
try color = col; catch color = 'r'; end
   

figure(fig),
hold on

line([roi(2),roi(4),roi(4),roi(2),roi(2)],[roi(1),roi(1),roi(3),roi(3),roi(1)],'LineWidth',linewidth,'Color',color)

ret=fig;
return
