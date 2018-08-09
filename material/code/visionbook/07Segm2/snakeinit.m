function [x,y] = snakeinit()
%SNAKEINIT  Manually initialize a 2-D, closed snake 
%   [x,y] = SNAKEINIT(delta)
%
%   delta: interpolation step

%   Chenyang Xu and Jerry L. Prince, 4/1/95, 6/17/97
%   Copyright (c) 1995-97 by Chenyang Xu and Jerry L. Prince
%   Image Analysis and Communications Lab, Johns Hopkins University

hold on

x = [];
y = [];
n =0;

% Loop, picking up the points
disp('Left mouse button picks points.')
disp('Right mouse button picks last point.')

but = 1;
while but == 1
      [s, t, but] = ginput(1);
      n = n + 1;
      x(n,1) = s;
      y(n,1) = t;
      plot(x, y, 'r-');
end   

plot([x;x(1,1)],[y;y(1,1)],'r-');
hold off

