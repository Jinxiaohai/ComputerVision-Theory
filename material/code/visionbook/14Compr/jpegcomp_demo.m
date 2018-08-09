% Demonstration of jpeg compression
% CMP Vision Algorithms, http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007

% History:
% $Id: jpegcomp_demo_decor.m 1079 2007-08-14 11:11:21Z svoboda $
% 
% 2007-05-24 Tomas Svoboda (TS): created, based on his own old code
% 2007-08-15 TS: refinement for better looking

% The basis of lossy JPEG compression is illustrated on a gray scale image.
% Actual JPEG compression is slightly more complex, see .
% The main steps in JPEG compression can be summarized as follows:
%  Compute DCT2 for each of non-overlapping image blocks. 
%  Quantize the coefficients.
%  Compress the quantized coefficients by an entropy coding.
%  Compress the direct components of the block wise DCT2s separately 
% by a predictive coding.
% We show the compression and decompression on a selected image block.

clear all;

addpath ../.
cmpviapath('../.');
% If necessary, create a directory for output images
out_dir = './output_images/';
if exist(out_dir)~=7
  mkdir(out_dir)
end

% specification of the image block
coeff = 1/2;
blocksize = coeff * [32 32];
colshift = (1/coeff)*3;
rowshift = (1/coeff)*1;
roi = [1+rowshift*blocksize(1) 1+colshift*blocksize(2)];
roi = [roi roi+blocksize-[1 1]]; % [upper left, lower right] 
% config value for calling showim_values 
cfg.fontsize = 8;

% Setting the demonstration parameters: quantcoeff determines
% the matrix for quantization of the DCT2 coefficients.
% Higher values give higher compression ratio but also
% more severe
% image degradation. The quantization matrix may vary. Modern 
% digital still photo cameras and image processing packages
% typically use different quantization matrices to allow for different 
% compression 
% settings{See,
% e.g. http://www.impulseadventure.com/photo/jpeg-quantization.html.}.
% Try different values of quantcoeff
% and observe the compression ratio
% and the compression artifacts. Select a different image block
% and compare the compression ratios. 
quantcoeff = 100;  
quantmatrix = quantcoeff * ones(blocksize);
quantmatrix( 1:1/4*blocksize(1), 1:1/4*blocksize(2) ) = 1/10 * quantcoeff;
quantmatrix( 1/4*blocksize(1)+1:1/2*blocksize(1), 1:1/2*blocksize(2) ) ...
  = 1/2 * quantcoeff;
quantmatrix( 1:1/4*blocksize(1), 1/4*blocksize(2)+1:1/2*blocksize(2) ) ...
  = 1/2 * quantcoeff;
quantmatrix = round( quantmatrix );

figure(99)
showim_values(quantmatrix,cfg,gcf);
title('Quantization matrix')
exportfig(gcf,[out_dir,'jpeg_quantmatrix.eps'])

% Read a test image and compute DCT2 coefficients for each
% individual non-overlapping block.
im = imread( 'cameraman.tif' );
J = blkproc( double(im)-128, blocksize, @dct2 );

fig=figure(1); clf
imshow(im),
axis on;
hold on
title('Original image')
drawrect(fig,roi,2);
exportfig(fig,[out_dir,'jpeg_imagewithroi.eps'])


fig=figure(2); clf
imagesc(log(abs(J)+1));
colormap(jet(256));
colorbar;
axis image;
title('log(abs(J)+1)')
drawrect(fig,roi,2);
exportfig(fig,[out_dir,'jpeg_image_dct2coeff.eps'])


imroi = im( roi(1):roi(3), roi(2):roi(4) );
imroi_shifted = double(imroi) - 128;
imroi_dct2 = round( dct2(imroi_shifted) );

% setting some config values for displaying the image values
% see the showim_values functon
cfg.colormapping = 'scaled';
cfg.colormap = colormap(gray(256));
cfg.txtcol = 'neg';
cfg.gridcol = 1/2*ones(1,3);
figure(10); clf
showim_values(imroi,cfg,gcf); 
title('Original image block')
exportfig(gcf,[out_dir,'jpeg_win_int.eps']);

cfg = [];
cfg.fontsize = 8;

figure(4); clf
showim_values(imroi_dct2,cfg,gcf);
title('DCT2 coefficients')
exportfig(gcf,[out_dir,'jpeg_win_dct2coeff.eps']);

% quantization of the DCT2 coefficients
imroi_dct2quant = round( imroi_dct2./quantmatrix );
figure(5); clf
showim_values(imroi_dct2quant,cfg,gcf);
title('Quantized DCT2 coefficients')
exportfig(gcf,[out_dir,'jpeg_win_dct2coeff_quantized.eps']);


% entropy of the quantized data
[H,Hmax] = dataentropy(imroi_dct2quant)
% compression by Huffman encoding
code = huffman( imroi_dct2quant(:) );
[data_encoded] = huffman_encode( imroi_dct2quant(:), code );
% compare the size (8 bit image assumed)
comp_ratio = prod(size(imroi))*8 / length(data_encoded)

data_decoded = huffman_decode( data_encoded, code );
% reshape the data to fit the date size
imroi_dct2quant = reshape( data_decoded, size(imroi) );
% reconstruction phase
imroi_dct2back = imroi_dct2quant .* quantmatrix;
% inverse DCT2
imroi_imshiftedback = idct2( imroi_dct2back );
imroi_imback = uint8( imroi_imshiftedback+128 );

figure(6); clf
showim_values(imroi_dct2back,cfg,gcf);
title('dct2 coefficients from the quantized data');
exportfig(gcf,[out_dir,'jpeg_dct2from_quantized.eps']);

figure(7); clf
imagesc(imroi_imshiftedback), colormap(gray(256));  axis image; colorbar
title('idct2 applied to the quantized data');

% setting some config values for displaying the image values
% see the showim_values function
cfg.colormapping = 'scaled';
cfg.colormap = colormap(gray(256));
cfg.txtcol = 'neg';
cfg.gridcol = 1/2*ones(1,3);
figure(8); clf
showim_values(imroi_imback,cfg,gcf);
title('recovered intensities');
exportfig(gcf,[out_dir,'jpeg_recovered_intensities.eps'])




