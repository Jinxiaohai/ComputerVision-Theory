function im_out = rotmask(im,method,datatype);
% ROTMASK averaging using rotating mask
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2006-2007

% Usage: im_out = rotmask(im,method,datatype)
% Inputs:
%   im  [m x n]  Input image.
%   method  (default 'vectorized')
%      String selecting the computational method: 
%      'loop' standard loop, most
%       readable code but slowest original formulation from the . 
%      'vectorized' essentially faster than
%       'loop' it still goes through all possible positions
%       in loops but the computation itself is vectorized.
%      'integral' uses integral image. Much faster
%       than other two implementations but memory hungry; single
%       precision is used  which may lead to small inaccuracies.
%   datatype  (default 'double')
%      Parameter for the 'integral' method.
%     It may be 'single' or 'double'. 
%     Variant 'double' always works 
%     correctly but can be too memory consuming for larger images. 
%     Choosing 'single' may resolve memory problems at the cost of 
%     losing precision.
% Outputs:
%   im_out  [m x n]  Filtered image. 
% See also: integralim.

% History:
% $Id: rotmask_decor.m 1074 2007-08-14 09:45:42Z kybic $
%
% 2006-03 Tomas Svoboda: first implementation and testing
% 2007-03-05 TS: decoration
% 2007-05-02 TS: new decor
% 2007-05-15 TS: essential speed up of 'vectorized' and 'integral'
%                implementation. decor changed accordingly
% 2007-05-24 VZ: typo
% 2007-08-09 TS: refinement for better looking of m-files 

if nargin<3
  datatype = 'double';
end
if nargin<2
  method = 'vectorized';
end


imdatatype = class(im);

VECTORIZED = strcmp(lower(method),'vectorized');
INTEGRAL = strcmp(lower(method),'integral');
LOOP = strcmp(lower(method),'loop');
  

if size(im,3)>1
  error('rot_mask does not work for full-colour images') 
end

mask_size = 9; % size of the rotating mask
mask=logical(zeros(5,5,mask_size));

im = double(im);

im_out = zeros(size(im));

if INTEGRAL
% Pre-compute integral images (summed area tables):
im_integral = feval( datatype, integralim(im) );
imsquare_integral = feval( datatype, integralim(im.^2) );
% The masks are defined in terms of distances from the 
% inspected pixel and organized in layers (one layer for 
% each of the 9 masks):
mask = zeros(2,4,9);
mask(:,:,1) = [-3 -3 0 0; -1 2 -1 2];
mask(:,:,2) = [-3 -3 0 0; -2 1 -2 1];
mask(:,:,3) = [-3 -3 0 0; -3 0 -3 0];
mask(:,:,4) = [-2 -2 1 1; -3 0 -3 0];
mask(:,:,5) = [-1 -1 2 2; -3 0 -3 0];
mask(:,:,6) = [-1 -1 2 2; -2 1 -2 1];
mask(:,:,7) = [-1 -1 2 2; -1 2 -1 2];
mask(:,:,8) = [-2 -2 1 1; -1 2 -1 2];
mask(:,:,9) = [-2 -2 1 1; -2 1 -2 1];
% Preparing data structures for the vectorized computations:
% the crucial point is to understand that the use of integral images 
% simplifies the computation of the variances.
% The mask structure indexes the corner positions for each of the
% 9 masks around each of the inspected pixels. These corner values
% are stored in the im_int_mat and im_sq_mat matrices. 
%
% The sum of all values under a 3x 3 mask is
% m(i-3,j-3)-m(i,j-3)-m(i-3,j)+m(i,j), where (i,j) are
% coordinates of the lower-right corner, see
% integralim. So, invert the signs of the middle 
% elements.
%
im_int_mat = zeros( 4,(size(im,1)-4)*(size(im,2)-4), 9,class(im_integral));
im_sq_mat  = zeros( 4,(size(im,1)-4)*(size(im,2)-4), 9,class(imsquare_integral));
row_pos = 3 : size(im,1)-2;
col_pos = 3 : size(im,2)-2;
for i = 1:9 % for each of the mask
  for j = [1 4] % for each of the +corner 
    row_mask_pos = row_pos(1)+mask(1,j,i)+1 : row_pos(end)+mask(1,j,i)+1;
    col_mask_pos = col_pos(1)+mask(2,j,i)+1 : col_pos(end)+mask(2,j,i)+1;
    im_int_mat(j,:,i) = ...
      reshape(im_integral(row_mask_pos,col_mask_pos),1,size(im_int_mat,2));
    im_sq_mat(j,:,i)  = ...
      reshape(imsquare_integral(row_mask_pos,col_mask_pos),1,size(im_sq_mat,2));
  end
  for j = [2 3] % for each of the -corner do the same
    row_mask_pos = row_pos(1)+mask(1,j,i)+1 : row_pos(end)+mask(1,j,i)+1;
    col_mask_pos = col_pos(1)+mask(2,j,i)+1 : col_pos(end)+mask(2,j,i)+1;
    im_int_mat(j,:,i) = ...
     -reshape(im_integral(row_mask_pos,col_mask_pos),1,size(im_int_mat,2));
    im_sq_mat(j,:,i)  = ...
     -reshape(imsquare_integral(row_mask_pos,col_mask_pos),1,size(im_sq_mat,2));
  end
end
% The use of two separate j-cycles, for [1 4]
% and [2 3] surprisingly proved to be almost twice as fast as
% post-changing of signs by using:
%   im_int_mat(2:3,:,:) = -im_int_mat(2:3,:,:);
%   im_sq_mat(2:3,:,:)  = -im_sq_mat(2:3,:,:);
% Compute sums and variances for each rotating mask.
sums = squeeze( sum(im_int_mat,1) )';
means = sums./mask_size;
sums_squares = squeeze( sum(im_sq_mat,1) )';
variances = mask_size*(means.^2) + sums_squares - 2*means.*sums;
% Identify the masks with the lowest dispersion as needed...
[foo,idx_mins] = min(variances);
% ... and pick up the means and use them for composition of the filtered
% image.
im_filt = means(sub2ind(size(means),idx_mins,[1:size(means,2)]));
% reshape to the original size
im_filt = reshape( im_filt, length(row_mask_pos), length(col_mask_pos) );
im_out(3:end-2,3:end-2) = im_filt;
else % VECTORIZED and LOOP methods loop over (almost) all pixels in image
% The masks are organized differently than in the integral implementation. 
% Individual masks are [5 x 5], i.e. they cover the complete neighborhood
% of the inspected pixel. In each mask there are nine 1's which index
% relevant pixels. All the masks are organized in a [5 x 5 x 9] array.
basic_shape = 1;
% create the templates and the middle mask
mask(1:3,3:5,1) = basic_shape;
mask(1:3,2:4,2) = basic_shape;
mask(2:4,2:4,9) = basic_shape;
% create the remaining masks by rotating the templates
for i = 3:8
  mask(:,:,i) = rot90( mask(:,:,i-2) );
end
% For each pixel 
% pick up the [5 x 5] relevant neighborhood, and
% compute variances and the mean from the one with the lowest
% dispersion.
variances = zeros(1,9);
for i = 3:size(im,1)-2
  for j = 3:size(im,2)-2
% The main trick in the vectorized code is the replication of 
% the [5 x 5] neighborhood of the inspected pixel into the 
% [5 x 5 x 9] array. Each of the masks is applied to a separate layer
% to mask-out the relevant values. The masked-out values are
% stacked into columns. The column-wise organized data are then
% processed in a standard Matlab fashion.
    if VECTORIZED
      % sub_mat = repmat( im(i-2:i+2,j-2:j+2), [1 1 9] );  
      % the code below replaces the slow repmat function
      sub_mat = im( i-2:i+2, j-2:j+2, ones(9,1) ); 
      % mask the values and organize into columns
      sub_mat = reshape( sub_mat(mask), mask_size, 9 ); 
      % compute means for each mask
      means = sum(sub_mat)/mask_size; 
      % compute variances for each mask
      variances = sum( (sub_mat-means(ones(mask_size,1),:)).^2 );
      % find the minimum
      [min_disp,idx_min] = min(variances);  
      % and take the mean belonging to the mask with minimal variance
      im_out(i,j) = means(idx_min); 
% The loop code is the simplest: it loops over each layer separately.        
%         
    elseif LOOP
      sub_im = im( i-2:i+2, j-2:j+2 ); % simple crop of the [5x5] subimage
      for m = 1:9 % for each mask
        % get the vector of values by masking
        vec = sub_im( mask(:,:,m) );
        % much faster than calling VAR function
        variances(m) = sum( (vec-sum(vec)/mask_size).^2 ); 
      end
      [min_disp,idx_min] = min(variances);
      im_out(i,j) = sum( sub_im(mask(:,:,idx_min)) ) / mask_size;
    else
      error('Unknown method');
    end
  end % for columns
  % informative print about progress after each row
  fprintf( 1, '\b\b\b\b\b\b\b\b %05.2f %%', 100*(i-2)/(size(im,1)-2) );
end % for rows
fprintf(1,'\b\b\b\b\b\b\b\b %05.2f %% \n',100)
end % if INTEGRAL

% convert the data type if appropriate
if strcmp(imdatatype,'uint8')
  im_out = uint8(round(im_out));
end
if strcmp(imdatatype,'uint16')
  im_out = uint16(round(im_out));
end
if strcmp(imdatatype,'double') | strcmp(imdatatype,'single')
  im_out = im_out/255;
end


return; % end of rotmask
