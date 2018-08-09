function [im_out] = jpegcomp(im,quantmatrix);
% JPEGCOMP JPEG compression
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
% A simple code that demonstrates the main principles of
% JPEG compression, . The function implements compression
% of one block only. Its typical use is, e.g., within
% blkproc. 
%
% Usage: [im_out] = jpegcomp(im,quantmatrix)
% Inputs:
%   im  [m x n]  Input image.
%   quantmatrix  [m x n]  Matrix of coefficients
%     for quantization of DCT2 coefficients.
% Outputs:
%   im_out  [m x n]  Compressed image.
% See also: dct2base.

% We assume an 8-bit grayscale image. First, subtract 128.
imshift = double(im) - 128;
% Second, compute the coefficients of the 2D Discrete Cosine Transform.
imdct2 = round( dct2(imshift) );
% Quantize the coefficients by using the quantization matrix
imdct2quant = round( imdct2./quantmatrix );

% The quantized coefficients normally get encoded by
% an entropy coding. Typical examples are Huffman coding and 
% arithmetic codes. The main underlying principle is that the most 
% frequent symbol (number) receives the shortest code and the least
% frequent the longest.

% The decompression stage starts with multiplication of the coefficients
% by the quantization matrix. Note that due to rounding in the previous step, the 
% true values are inevitably lost.
imdct2back = imdct2quant .* quantmatrix;

% Finally, call the inverse discrete cosine transform and add back the 
% subtracted 128.
imshiftback = idct2( imdct2back );
im_out = uint8( imshiftback+128 );
return

