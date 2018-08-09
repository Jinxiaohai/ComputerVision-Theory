% demonstration of SHOWIM_VALUES function
% CMP Vision Algorithms http://visionbook.felk.cvut.cz 
% Tomas Svoboda, 2007

% $Id: $

clear all;
addpath ../.
cmpviapath('../.');
% create a directory for output images 
% if needed and does not already exist
out_dir = 'output_images/';
if (exist(out_dir)~=7)
  mkdir(out_dir);
end

imgray = uint8( round(255*rand(8,8)) ); % random gray scale image
imbw = imgray>127;                      % binary image by simple thresholding

% printing binary image
cfg.rectwidth = 0.6; % width of the black rectangle
fid = figure(1); clf;
fid = showim_values( imbw, cfg, fid );
exportfig(fid,[out_dir,'showim_binary.eps'])


% printing grayscale image
cfg.gridcol = 1/2*[1 1 1];          % grid in gray color
cfg.colormap = colormap(gray(256)); % grayscale image assumed
cfg.txtcol = 'neg';                 % numbers in negative color                
cfg.colshift = 0;                   % small tuning of the text position
fid = figure(2);  clf
fid = showim_values( imgray, cfg, fid );
exportfig(fid,[out_dir,'showim_grayscale.eps'])


