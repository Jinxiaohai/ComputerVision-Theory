function [X,L] = scenegen(type,varargin)
%SCENEGEN Create scene - points in space and their connections
%CMP Vision Algorithms http://visionbook.felk.cvut.cz
% An auxiliary function that generates a set of 2D or 3D points and
% possibly some connections in between. For use, see the demos of u2Hdlt, 
% cameragen. It is useful mainly for experiments where ground
% truth is needed.
%
% Usage: [X,L] = scenegen(type,N)
%  type    parameter defining the scene to be created. It could be 
%         'house' and 'random2D' 
%  N  1x1   number of points for 'random2D' scene 
%  X  [3 x N]  matrix with 3D points 
%  L  [l x 2]  matrix of connections between points, l
%		is number of connections 
% 

% History:
% $Id: scenegen_decor.m 1074 2007-08-14 09:45:42Z kybic $
% 
% 2007-01: Tomas Svoboda (TS): created
% 2007-03-09: Petr Lhotsky, decorization for CMPvia
% 2007-05-03: TS new decor
% 2007-08-09: TS refinement for better looking of the m-file

try numpoints = varargin{1}; catch numpoints = 10; end

w = 3; % width
h = 2; % height
l = 4; % depth (length)

if strcmp(type,'house')
  X = zeros(3,10);
% frontal side of the house
  X(:,1) = [0,0,0]';
  X(:,2) = [0,w,0]';
  X(:,3) = [0,w,h]';
  X(:,4) = [0,0,h]';
  X(:,5) = [0,w/2,1.5*h]';
% back side of the house
  X(:,6:10) = X(:,1:5)-repmat([l,0,0]',1,5);
% X(:,11:14) = [[1,1,0]',[2,1,0]',[2,2,0]',[1,2,0]'];
% X(:,15:18) = [[1,1,0]',[2,1,0]',[2,2,0]',[1,2,0]'];
  L = [1,2;2,3;3,4;4,1;3,5;4,5];
  L = [L;L+5];
  L = [L;1,6;2,7;3,8;4,9;5,10];
elseif strcmp(type,'random2D')
  X = zeros(3,numpoints);
  X(1,:) = 0; %yz plane
  X(3,:) = 1.5*h*rand(1,numpoints);
  X(2,:) = 1.2*w*rand(1,numpoints);
  L = [];
elseif strcmp(type,'random3D')
  error(sprintf('%s not yet implemented',type))
else
  error('unknown type of scene');
end

return; % end of scenegen

