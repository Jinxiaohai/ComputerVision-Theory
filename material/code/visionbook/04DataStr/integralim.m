function im_out = integralim(im,shape);
% INTEGRALIM compute integral image (summed area tables)
% CMP Vision Algorithms http://visionbook.felk.cvut.cz 
% 
% Usage: im_out = integralim(im,shape)
% Inputs:
%   im  [m  x n]  Input image.
%   shape  (default 'full')  Defines the size of the output matrix. 
%     It has a similar meaning as in, e.g., conv2. 
%     The option 'same' makes the function
%     crop-out the ``zero column and row''  of the resulting integral image
%     which will be then of the same size as the input image.
%   im_out   Integral image.


if nargin<2
  shape = 'full';
end

% The algorithm is implemented in two ways. One is a more 
% classical for-loop implementation. It can be switched on by
% setting LOOP=1. The second one uses cumsum.
% The latter is much more compact, however both variants perform
% comparably.
LOOP = 0;

im = double(im);

% Create the `zero' column and row. 
im_padded = zeros( size(im)+[1 1] );
im_padded(2:end,2:end) = im;
% The `loop' version can be straightforwardly rewritten
% in some low-level language, like Java or C.
if LOOP
  im_out = im_padded;
  for i = 2:size(im_out,1)
    for j = 2:size(im_out,2)
      im_out(i,j) = im_out(i,j-1)+im_out(i-1,j)+im_padded(i,j)-im_out(i-1,j-1);
    end
  end
% The non-loop version actually hides the looping which is 
% implemented inside the cumsum. The first cumulative sum
% computes the row sum and the second sums the row-sums along the 
% columns.
else
  % s = cumsum(im_padded,2); % row cumulative sum
  im_out = cumsum( cumsum(im_padded,2), 1 );
end

if strcmp(shape,'same')
  im_out=im_out(2:end,2:end);
end


return; % end of integralim


