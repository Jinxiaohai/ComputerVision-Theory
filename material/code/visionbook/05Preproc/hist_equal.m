function [im_out,H,Hc,T] = hist_equal(im)
% HIST_EQUAL histogram equalization
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2006-2007
% 
% Usage: [im_out,H,Hc,T] = hist_equal(im)
% Inputs:
%   im  [m x n]  Input image. 
% Outputs:
%   im_out  [m x n]   Equalized image. 
%   H       [1 x 256] Histogram of the input image. 
%   Hc      [1 x 256] Cumulative histogram of the input function. 
%   T       [1 x 256] Transformation function of the intensity. 
% See also: histeq.

% History:
% $Id: hist_equal_decor.m 1074 2007-08-14 09:45:42Z kybic $
%
% 2006-01 Tomas Svoboda created
% 2007-03-05 TS: decorated
% 2007-05-02 TS: new decor
% 2007-05-24 TS: typo
% 2007-08-09 TS: refinement for better looking of m-file

if size(im,3)>1,
  warning('Colour image in the input, HIST_EQUAL process it as grayscale')
end

if isa(im,'uint8');  % 8-bit depth
  levels = 2^8;
elseif isa(im,'uint16'); % 16-bit depth
  levels = 2^16;
elseif isa(im, 'float'); % actually unknown but 8-bit assumed
  warning('Bit depth could not be recognised, 8-bit image is assumed');
  levels = 2^8;
  if max(max(im))>1;
  im = round(im);
  im(im<0)   = 0;
  im(im>255) = levels-1;
  else
  im = uint8(round(im*255));
  end
end


% The intensities are typically [0,255] but Matlab starts
% indexes at 1. Doing the +1 shift only once saves some computation time.
imp = uint32(im)+1;

% Compute the histogram of the input image first.
% Scan every pixel and increment the relevant member of H; 
% if pixel p has intensity g_p perform H[g_p]=H[g_p]+1. 
% The number of levels is determined from the bit depth
% of the input image.
H = zeros(1,levels); % allocate memory
% scan all pixels ...
for i=1:size(im,1)
  for j=1:size(im,2)
    % pixel intensity indexes the accumulator
    H(imp(i,j)) = H(imp(i,j)) + 1; 
  end
end

% Form the cumulative image histogram H_c.
Hc = zeros(size(H));
Hc(1) = H(1);
for i=2:size(Hc,2)
  Hc(i) = Hc(i-1)+H(i);
end

% Create the look-up table
% normalizing the cumulative histogram to have integer values between
% 0--(levels-1),
% typically [0,255].
T = round( (levels-1)/(size(im,1)*size(im,2)) * Hc );


% Apply the look-up table
% to each level in the input image.
% Formally, rescan the image and write an output image
% with gray levels g_q, setting g_q=T[g_p].
% memory allocation for the new image
im_out = zeros(size(im)); % same size as the input image
im_out = T(imp);
% Note from the last row how elegantly Matlab allows the use of the
% look-up table. T is a 1 x 256 vector in which
% T(i) contains an intensity value that replaces
% i-1. The image itself is here understood as a set of
% indexes that point to the vector T.  
% In a classical language it would be:
% for i=all pixels in image
%   im_out(i) = T(imp(i));
% end

% convert the data type if appropriate
if isa(im,'uint8')
  im_out = uint8(round(im_out));
end
if isa(im,'uint16')
  im_out = uint16(round(im_out));
end
if isa(im,'float')
  im_out = im_out/(levels-1);
end

return; % end of hist_equal

