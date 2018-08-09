function [s,theta,acc]=hough_lines(varargin);
%HOUGH_LINES Hough transform line detection.
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Find all straight lines in an image using the Hough transform
%  : the input of this routine is an
%  edge image, obtained for example by the Canny edge detector 
%  We use the (theta,s) line parameterization, with origin in the
%  center of the image .
%  
% Usage: [s,theta,acc] = hough_lines(im,theta_step,s_step,thresh)
% Inputs:
%  im   [m x n]  Input edge image: non-zero values are edges,
%                 the value corresponds to edge strength. This may be
%                 used for weighting the edges by the gradient magnitude.
%  theta_step  (default /360)  Discretization step for the
%    angle theta in radians.
%  s_step  (default 1)  Discretization step for the radius s
%    in pixels.
%  thresh  (default 0.5)  Values above thresh*max(acc)
%    in the accumulator acc are considered to correspond to valid lines.
% Outputs:
%   s  [k x 1]  Vector containing the s parameters of the lines found.
%   theta  [k x 1]  Vector containing the theta parameters of
%     the lines found.
%   acc  [_s x _theta]  The accumulator.
%
% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
im=double(varargin{1});

% Handle the input variable theta_step. If unspecified assign theta_step=pi/360
if nargin>1
    theta_step=varargin{2};
else
    theta_step = pi/360;
end

% Handle the input variable s_step. If unspecified assign s_step=1
if nargin>2
    s_step=varargin{3};
else
    s_step= 1;
end

if (nargin>3)
    threshold= varargin{4};
else
    % If the threshold value is not specified at the input, use 0.5* max(acc)
    % where max(acc) is the maximum value in the accumulator (multiplication 
    % by max(acc) follows later):
    threshold= 0.5;
end

% Set limits for theta and s to cover all pixels in the
% image, initialize the accumulator acc and pre-calculate whatever will be needed
% later.
[m,n] = size(im);
theta_min = 0;
theta_max = pi-theta_step;
s_max = sqrt( (m*m +n*n)/4 ) + s_step;
theta = theta_min:theta_step:theta_max;
theta_num_values = length(theta);
s_num_values = round( 2*s_max/s_step ) + 1;
s_num_half = ceil( s_num_values/2 );
cos_theta = cos(theta);
sin_theta = sin(theta);
acc = double( zeros(s_num_values,theta_num_values) );


% Find coordinates of all edge pixels with respect to the image center.
[i,j,edge_value] = find(im);
edge_value = edge_value/max(edge_value);
center_x = n/2;
center_y = m/2;
x = j-center_x;
y = center_y-i; 

% The heart of the algorithm is a loop over all edge pixels, 
% incrementing the appropriate
% accumulator cells. Observe how the values of s and theta correspond
% to the accumulator coordinates. Two tricks are used to speed up the
% execution: First, s is calculated in parallel for all theta. Second,
% lin_idx_offset converts - also in parallel - the 2D indices
% into a linear index. This is similar to the Matlab function
% sub2ind but much faster.

lin_idx_offset = (0:(theta_num_values-1)) * s_num_values; % auxiliary table

for l = 1:length(x)
  s = x(l)*cos_theta + y(l)*sin_theta; % calculate s for all theta
  s = round(s/s_step) + s_num_half;    % accumulator coordinates
  lin_idx = lin_idx_offset + s;        % find linear indices
  acc(lin_idx) = acc(lin_idx) + edge_value(l); % increment the accumulator
end

% The accumulator is thresholded and non-maximal suppression is applied: we
% keep only those accumulator cells whose values are equal to
%  a maximum in a 5 x 5 neighborhood. 
% This helps to generate a unique response
% for each line. To correctly handle maxima at accumulator boundaries 
% between (theta=0,s) and (theta=,-s), we create an extended
% `wrapped-around' accumulator acc_rep. 
idx = find(acc>threshold*max(max(acc)));
num_n = 24; % number of neighbors
wid = 5;    % width of the neighbourhood
w_h = (wid-1)/2;
acc_rep = [acc(end:-1:1,end-w_h+1:end) acc acc(end:-1:1,1:w_h)]; 
acc_rep_offset = w_h*s_num_values; % the offset between acc_rep and acc

% The 2D offsets of neighboring cells are combined into linear
% offsets and stored in neighborhood_offsets. The indices
% of all cells idx above the threshold are
% augmented by the indices of their neighbors and stored in
% neighborhoods_idx, one neighborhood per row.
[neighborhood_offsets_n neighborhood_offsets_m] = meshgrid(-w_h:w_h);
neighborhood_offsets_n = neighborhood_offsets_n( [1:num_n/2 (num_n/2)+2:end] );
neighborhood_offsets_m = neighborhood_offsets_m( [1:num_n/2 (num_n/2)+2:end] );
neighborhood_offsets = ...
  s_num_values*neighborhood_offsets_n + neighborhood_offsets_m;
neighborhoods_idx = repmat( idx+acc_rep_offset, 1, num_n ) + ...
                    repmat( neighborhood_offsets, length(idx), 1 );

% We need to handle the boundary cases - whenever an index falls outside the
% accumulator, the cell is effectively ignored by replacing the index
% with the index of the neighborhood
% center cell. 
out_idx = find( ...
  (neighborhoods_idx<1) + ...
  (neighborhoods_idx>((2*w_h+s_num_values)*theta_num_values)) );
neighborhoods_idx(out_idx) = neighborhoods_idx( rem(out_idx-1,s_num_values)+1 );

% Finding the local maxima consists of taking only such
% elements from idx at which the corresponding accumulator cell is 
% at least equal to the maximum of the neighborhood; this can be written
% very concisely in Matlab. Finally, surviving indices are converted
% to the corresponding parameter values s and theta.
local_maxima_idx = idx( acc(idx)>=max(acc_rep(neighborhoods_idx),[],2) );
s = s_step * ( rem(local_maxima_idx,s_num_values) - s_num_half );
theta = theta_step*floor(local_maxima_idx/s_num_values) + theta_min;

