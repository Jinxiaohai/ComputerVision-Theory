function R = nfi2r(n,fi) 
% NFI2R  Computes rotation matrix, axis of rotation and the angle are given
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 1998-2007
%
% Usage: R = nfi2r(n,fi)
%  n  [3 x 1]  axis of rotation (vector of direction) 
%  fi  1x1     [rad] angle of rotation (counter clockwise) 
%  R  [3 x 3]  rotation matrix 

% History:
% $Id: nfi2r_decor.m 1074 2007-08-14 09:45:42Z kybic $
%
% T. Svoboda, 3/1998, CMP Prague 
% 2007-01-30: T. Svoboda, decoration for CMPvia
% 2007-03-09: Petr Lhotsky, standard header
% 2007-05-03: TS new decor
% 2007-08-09: TS refinement for better looking of m-files

% page 203 of the book:
% @BOOK{Kanatani90,
% AUTHOR             = {Kanatani, Kenichi},
% PUBLISHER          = {Springer-{V}erlag},
% TITLE              = {Group-{T}heoretical Methods in Image Understanding},
% YEAR               = {1990},
% ISSN_ISBN          = {3-540-51263-5},


n = n./norm(n,2);
cfi = cos(fi);
sfi = sin(fi);

R(1,1:3) = [ cfi+n(1)^2*(1-cfi), n(1)*n(2)*(1-cfi)-n(3)*sfi, n(1)*n(3)*(1-cfi)+n(2)*sfi ];
R(2,1:3) = [ n(1)*n(2)*(1-cfi)+n(3)*sfi, cfi+n(2)^2*(1-cfi), n(2)*n(3)*(1-cfi)-n(1)*sfi ];
R(3,1:3) = [ n(3)*n(1)*(1-cfi)-n(2)*sfi, n(3)*n(2)*(1-cfi)+n(1)*sfi, cfi+n(3)^2*(1-cfi) ];

R = R'; % due to reverse notation of Kanatani

return

