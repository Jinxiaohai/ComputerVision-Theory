function c_matrix=cooc(im, offsets)
% COOC   Creates co-occurrence matrix of a grayscale image. 
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Petr Nemecek, Tomas Svoboda, 2006-2007
% 
% Function cooc computes the non-symmetrical
% co-occurrence matrix of a grayscale image .
% The algorithm used can be described for an image im as:
% c_matrix = zeros(256);
% for i = 1:height_of_image 
%   for j = 1:width_of_image
%     find all the pixels in spatial relation to the pixel of interest (i,j)
%     for I = 0:255       
%       if one or more pixels in spatial relation with (i,j) is of intensity I
%       then c_matrix(im(i,j)+1,I+1)= c_matrix(im(i,j)+1,I+1)+1;
%     end         
%   end
% end
% It does not matter if there are one or more pixels in 
% relation with the pixel of interest and possessing 
% the same intensity. The corresponding 
% element of c_matrix will always be increased just by 1. 
%
% The implementation is highly vectorized and 
% probably not understandable on first reading.
%
% 
% Usage: c_matrix = cooc(im,offsets)
% Inputs:
%   im       [m x n]  Matrix of class uint8 representing a grayscale image.
%   offsets  [N x 2]  Matrix defining the N spatial relations used for 
%     co-occurrence matrix computation. Each row of offsets 
%     defines one pixel in relation with the pixel of interest. 
%     Left and right column of offsets 
%     represents its relative row- and column-offset respectively.
%     E.g. if offsets=[1 0], the pixel
%     is 1 row down and 0 columns to the right, i.e. a
%     southern neighbor.
% Outputs:
%   c_matrix  [256 x256]  Co-occurrence matrix of the input image im.
%     Each row/column corresponds to one intensity
%     level of the grayscale 0--255 i.e., row/column
%     1 corresponds to 0 and row/column 256
%     corresponds to 255.
%

% History:
% $Id: cooc_decor.m 1074 2007-08-14 09:45:42Z kybic $ 
%
% 2007-02-19: Petr Nemecek (PN) created
% 2007-03-27: Tomas Svoboda (TS) proper header, tex-like commented
% 2007-04-??: Vit Zyka new decor, introducing new macros
% 2007-04-27: TS some code improvements
% 2007-05-02: VZ simple typography changes
% 2007-06-27: TS refinement of the decor
% 2007-08-09: TS refinement for better looking of m-files


% INPUT CONTROL:
% control if the input image im is of class uint8 - if not, convert it
if ~isa(im,'uint8')
    im=uint8(im);
    warning([mfilename ': Input variable im is not of class uint8. im converted to uint8 format.']);
end
% control if the input variable offsets is a 2-D array of integer values    
iptcheckinput(offsets,{'numeric'},{'integer','2d'},mfilename,'offsets',2);


% Initialization of variables:
num_shades = 256; % number of shades of grey in the grayscale
num_pixels = numel(im); % number of pixels in the image
num_relations = size(offsets,1); % number of different offsets
size_im = size(im);

% Create two column vectors of the row and column coordinates of all pixels: 
[idx_col,idx_row] = meshgrid( 1:size_im(2), 1:size_im(1) );
idx_col = idx_col(:);  idx_row = idx_row(:);

% By adding all the offsets to the pixel coordinates create two matrices 
% idx_row_neighbour, idx_col_neighbour of size 
% [num_pixels num_relations]
% representing the row- and column-coordinates of all the pixels that are
% in relation with the pixels with indexes idx_row, idx_col.
idx_row_neighbour = [];  idx_col_neighbour = [];
for i=1:num_relations
  idx_row_neighbour = [idx_row_neighbour idx_row+offsets(i,1)];
  idx_col_neighbour = [idx_col_neighbour idx_col+offsets(i,2)];
end

% Replicate idx_row, idx_col so that it is the same size as 
% idx_row_neighbour, idx_col_neighbour.
idx_row = repmat( idx_row, 1, num_relations );
idx_col = repmat( idx_col, 1, num_relations );

values=im( sub2ind(size_im,idx_row,idx_col) ); % pixel values corresponding to idx_row,idx_col:
values_neighbour=zeros( num_pixels, num_relations, 'uint8' );% Matrix of zeros of size idx_row_neighbour,idx_col_neighbour
 

% For all of the pixel positions defined by idx_row_neighbour, 
% idx_col_neighbour
% decide whether they are in or out of the image borders:
I = (idx_row_neighbour<=size_im(1)) & (idx_row_neighbour>0) & ...
    (idx_col_neighbour<=size_im(2)) & (idx_col_neighbour>0); 

% To each pixel assign the intensity values of pixels that are in
% spatial relation r. The function sub2ind converts matrix
% indexes into a linear index.
values_neighbour(I) = ...
  im( sub2ind(size_im, idx_row_neighbour(I),idx_col_neighbour(I)) );

result = [];
for a = 1:(num_relations-1) % primary pixel
  for b = (a+1):num_relations % pixel in relation
    select = (values_neighbour(:,a)~=values_neighbour(:,b)) | ~I(:,b);
    I(:,a) = I(:,a) .* select;
  end
  result = [result; [values(I(:,a)) values_neighbour(I(:,a),a)]];
end
result = [result; [values(I(:,end)) values_neighbour(I(:,end),end)]];
result = uint16( result+1 ); % uint8 does not fit the range 1--256

c_matrix = accumarray( result, 1, [num_shades num_shades] );
return; % end of cooc
