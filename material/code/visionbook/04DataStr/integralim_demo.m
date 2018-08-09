% COOC_DEMO demo for cooc
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2006-2007

% $Id: integralim_demo_decor.m 1074 2007-08-14 09:45:42Z kybic $

clear all;

addpath ../.
cmpviapath('../.');
% create a directory for output images
% if needed and does not already exist
out_dir = 'output_images/';
if (exist(out_dir)~=7)
  mkdir(out_dir);
end


% First create a simple image and define the region of interest.
im = ones( 8, 8, 'uint8' ); % image
nw = [3 3];                 % upper left corner
se = [6 7];                 % lower right corner
im( nw(1):se(1), nw(2):se(2) ) = 2; % intensity in the region

cfg.colormap = [1 1 1; 0.7 0.7 0.7];
fig = figure(1), clf
showim_values( im, cfg, fig );
% mark the region of interest
h = rectangle( 'Position',[nw(end:-1:1)-0.5,se(end:-1:1)-nw(end:-1:1)+1], ...
               'LineWidth',5, 'EdgeColor','white' );
h = rectangle( 'Position',[nw(end:-1:1)-0.5,se(end:-1:1)-nw(end:-1:1)+1], ...
               'LineWidth',2, 'EdgeColor','black' );
exportfig( fig,[out_dir,'intim_input_image.eps']);

% Compute the integral image and display it.
im_int = integralim( im, 'same' );
fig = figure(2), clf
fig = showim_values( im_int, [], fig );
h = rectangle('Position',[nw(end:-1:1)-0.5,se(end:-1:1)-nw(end:-1:1)+1],...
              'LineWidth',5,'EdgeColor','white');
h = rectangle('Position',[nw(end:-1:1)-0.5,se(end:-1:1)-nw(end:-1:1)+1],...
              'LineWidth',2,'EdgeColor','black');
% The sum of values inside the marked region is computed
% from the graphically emphasized values.
bgcol = 'black';
% third column encodes the sign
corners = [nw(1)-1 nw(2)-1  1; se(1) nw(2)-1 -1; ...
           nw(1)-1 se(2)   -1; se(1) se(2)    1];
for i = 1:4
  text( corners(i,2)-0.35, corners(i,1)+0.1, ...
    sprintf( '%+3d', corners(i,3)*im_int(corners(i,1),corners(i,2)) ), ...
    'BackgroundColor',bgcol, 'Color','white', 'FontSize',16, 'FontWeight','bold')
end
% get linear indexes
idx = sub2ind( size(im), corners(:,1), corners(:,2) );
% compute the sum of all region values
summed_values = sum( im_int(idx).*corners(:,3) )

exportfig(fig,[out_dir,'intim_integralim.eps']);


