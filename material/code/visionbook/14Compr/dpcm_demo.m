% DPCM_DEMO demonstration of the differential code pulse modulation
% CMP Vision Algorithms, visionbook@cmp.felk.cvut.cz
% http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007 

% History:
% $Id: dpcm_demo_decor.m 1079 2007-08-14 11:11:21Z svoboda $
% 
% 2007-06-15: Tomas Svoboda created and decorated
% 2007-08-15: TS refinement for better looking of the m-file


clear all;


OWN_QUANT = 0; % set to 1 if you want to specify a quantization table

addpath ../.
cmpviapath('../.');
% if necessary, create a directory for output images
out_dir = './output_images/';
if exist(out_dir)~=7
  mkdir(out_dir)
end 
if OWN_QUANT
  % example of user defined quantization table
  s = [4 16 32 256]';
  t = [2 12 24 64]';
  quantfn = zeros( 1, max(s) );
  for i=2:length(s)
    quantfn(s(i-1)+1:s(i)) = t(i);
  end
else % optimal Lloyd-Max quantization
  quantfn = 4; % levels
end

im = imread('images/horin.png');
im = uint8(imresize(im,0.5)); % just to speed up debugging
imvec = im(:); % make a vector from the image
[H_im, H_max] = dataentropy(im(:))
figure(10), clf
imshow(im);
title('Input image')
exportfig(gcf,[out_dir,'dpcm_image.eps']);
figure(11), clf
imhist(im)
title(sprintf('Histogram of the input image, entropy %2.2f',H_im))
exportfig(gcf,[out_dir,'dpcm_imhist'])

[a,diffs,quantfn,s,diffs_lossless] = dpcm( imvec, 3, quantfn );

figure(1), clf
stairs([-max(s):max(s)-1]',[-quantfn(end:-1:1);quantfn],'LineWidth',2)
axis([-max(s) max(s) 1.1*[-quantfn(end) quantfn(end)]])
grid on;
xlabel('zero mean prediction error')
ylabel('quantized prediction error')
title('quantization function')
exportfig(gcf,[out_dir,'dpcm_quantfn.eps'])


figure(20), clf
imagesc(reshape(diffs,size(im)));
axis image
title('quantized prediction errors')
colorbar
exportfig(gcf,[out_dir,'dpcm_errquant.eps'])
figure(21), clf
imagesc(reshape(diffs_lossless,size(im)));
axis image
title('non-quantized prediction errors')
colorbar
exportfig(gcf,[out_dir,'dpcm_err.eps'])

% analyze differences
figure(30)
[h] = histc(diffs,[-255:255]);
bar([-255:255],h)
xlabel('prediction error')
ylabel('frequency')
title(sprintf('histogram of quantized errors, entropy: %2.2f', dataentropy(diffs)))
exportfig(gcf,[out_dir,'dpcm_histerrquant.eps'])
figure(31)
[h] = histc(diffs_lossless,[-255:255]);
bar([-255:255],h)
xlabel('prediction error')
ylabel('frequency')
title(sprintf('histogram of the errors, entropy: %2.2f', dataentropy(diffs_lossless)))
exportfig(gcf,[out_dir,'dpcm_histerr.eps'])

H = dataentropy(diffs)

% Encode the quantized prediction errors
% by Huffman coding, see huffman.
code = huffman( diffs );                              % Huffman code
[diffs_encoded] = huffman_encode( diffs, code );      % Huffman encoding
comp_ratio = 8*prod(size(im)) / length(diffs_encoded) % compression ratio

% The decoding stage starts with Huffman decoding
% of the compressed signal. The first n image values are
% transmitted as well to allow the dpcm decoding.
diffs = huffman_decode( diffs_encoded, code );
n = length(a);
imrec = zeros( size(imvec) );
imrec(1:n) = imvec(1:n);
% The intensity value at position i is predicted from
% n previous values. The transmitted difference value is
% added to compensate a wrong prediction.
for i=(n+1):length(imrec) 
  imrec(i) = round( sum(a.*imrec(i-1:-1:i-n)) ) + diffs(i);
end
im_decoded = uint8(reshape(imrec,size(im))); % decoded image

figure(5), clf
imshow(im_decoded);
title('Reconstructed image');
exportfig(gcf,[out_dir,'dpcm_reconstructedim.eps'])

imdiff = double(im)-double(im_decoded);
figure(6), clf
imagesc(imdiff)
colormap(jet(256))
axis image
title('Difference image')
colorbar
exportfig(gcf,[out_dir,'dpcm_diffim.eps'])



