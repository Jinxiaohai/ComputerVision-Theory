function [im_out,figs] = buttfilt(im,type,Do,n,padd_opt,fig)
% BUTTFILT Butterworth filter
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
%
% Usage: [im_out,figs] = buttfilt(im,type,Do,n,padd_opt,fig)
% Inputs:
%   im  [m x n x l]  Input image; if it is an RGB image, 
%                    filtering is applied to the intensity part only.
%   type    Type of the filter 'lp' for low-pass
%           and 'hp' for high-pass.
%   Do  1x1  Cut-off frequency of the filter.
%   n   1x1  Order of the filter.
%   padd_opt    Padding option, see paddedsize.
%   fig  1x1  Handle of the first figure for graphical display. If
%             fig=0 no figures will be displayed.
% Outputs:
%   im_out  [m x n x l]  Filtered image of the same size as the input.
%   figs  array  Array of structs containing information about the figures
%     .h figure handle, .fname filename for saving.

% History:
% $Id: buttfilt_decor.m 1074 2007-08-14 09:45:42Z kybic $
%
% 2007-05-16: Tomas Svoboda (TS) created from his old toy-code
% 2007-05-24: VZ
% 2007-08-09: TS refinement for better looking of m-file

figs = [];

if size(im,3)==3, % rgb image assumed 
  im_hsv = rgb2hsv(im);
  imval = im_hsv(:,:,3);
else	% gray scale image assumed
  imval = im; 
end
[im_height,im_width] = size(imval);

% Compute padding size if requested; remember that the discrete Fourier transform
% is periodic. Zero-padding is used to avoid unwanted effects resulting from
% the assumed periodicity
if strcmp( padd_opt, 'none' )
  ps = [im_height im_width];
else
  ps = paddedsize( [im_height im_width], padd_opt );
end

% Prepare a distance matrix which allows easy creation
% of the 2D Butterworth by using rc2d.
% More complicated filters can be created in a similar way
% by employing the bwdist function.
D = rc2d( ps, 'euclidean' );
Do = Do*ps(2)/im_width;

% Compute the Fourier spectrum of the input image by calling
% the standard fft2 function. Application of fftshift
% centers the direct component of the spectrum. Compute the matrix of
% the Butterworth
% filter. A high-pass filter is created by just flipping the low-pass one. 
F = fftshift( fft2(double(imval),ps(1),ps(2)) );
H = 1 ./ ( 1+(D./(Do+eps)).^n );
if strcmp( lower(type), 'hp' )
  H = 1-H;
end
% Filtering in the frequency domain means per element multiplication.
% Get back to the spatial domain after filtering.
G = F .* H; 
g = real( ifft2(fftshift(G)) );
g = g( 1:im_height, 1:im_width );

if size(im,3)==3  % rgb image assumed
  im_out = im_hsv;
  im_out(:,:,3) = g;
  im_out = hsv2rgb(im_out); 
else
  im_out = g;
  im_out(im_out>255) = 255;
  im_out(im_out<0) = 0;
  im_out = uint8(im_out);
end


if fig
  figs(1).h = figure(fig); clf
  imagesc(log(abs(F)+1));
  colormap(jet(256)), axis on, axis image, colorbar
  title('Shifted log(abs(FFT)) of the original image');
  figs(1).fname = sprintf('%s_fft_original.eps',type);
  %% print('-depsc', sprintf('%s_fft_original.eps',type));
  % print('-depsc2','-cmyk', sprintf('%s_fft_original.eps',type));

  figs(2).h = figure(fig+1); clf
  mesh(H(1:end,1:end));
  title(sprintf('%s Butt filter n=%d, Do=%d',type, n, Do))
  rotate3d on
  figs(2).fname = sprintf('%s_butt.eps',type);
  %% print('-depsc', '-zbuffer', '-r200', sprintf('%s_butt.eps',type))
  % print('-depsc2','-cmyk', '-zbuffer', '-r200', sprintf('%s_butt.eps',type))

  figs(3).h = figure(fig+2); clf
  % imagesc(log(abs(fftshift(fft2(g)))));
  imagesc(log(abs(G)+1));
  colormap(jet(256)), axis on, axis image, colorbar
  title('Shifted log(abs(FFT)) of the filtered image');
  figs(3).fname = sprintf('%s_fft_filtered.eps',type);
  %% print('-depsc', sprintf('%s_fft_filtered.eps',type))
  % print('-depsc2,'-cmyk', sprintf('%s_fft_filtered.eps',type))

end

return; % end of the buttfilt
