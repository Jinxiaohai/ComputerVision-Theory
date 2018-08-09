% demonstration of ROTMASK, averaging using rotating mask
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2006-2007
%
% $Id: rotmask_demo_decor.m 1074 2007-08-14 09:45:42Z kybic $

addpath ../.
cmpviapath('../.');
% create a directory for output images
% if necessary, and does not already exist
out_dir = './output_images/';
if exist(out_dir)~=7
  mkdir(out_dir)
end

im = imread('images/raising_moon_gray_small.jpg');
im = hist_equal(im);

imwrite(im,[out_dir,'rotmask_input.jpg']);

% A noisy night photo is used to demonstrate the filtering power.  
% All three methods are launched by default to emphasize the effectiveness
% of more advanced implementations.
% test all methods 
methods = {'loop' 'vectorized' 'integral'};
for i = 1:length(methods)
  disp(sprintf( ...
      'rotating mask, method _%s_ is running, please wait ...',methods{i}))
  tic
  im_out = rotmask( im, methods{i}, 'double' );
  time(i) = toc;
  disp(sprintf('elapsed time for method _%s_ %2.2f seconds',methods{i},time(i)));
end
try close(fig10); catch; end;
fig10=figure(10); clf
currpos = get(gcf,'Position');
set(gcf,'Position',[currpos(1:3),currpos(4)/4])
hold on
for i=1:length(methods),
  axis([0,0.3,-0.07,0])
  text(0,0,sprintf('Computation times for a [%d x %d] image',size(im,2), size(im,1)),'FontSize',16);
  text(0,-i*0.02,sprintf('%s: %2.2f seconds',methods{i},time(i)),'FontSize',14);
  axis off
end
print('-depsc2','-cmyk', [out_dir,'rotmask_computing_times.eps']);

figure(1), clf
imshow(im);
title('input image');
figure(2), clf
imshow(im_out);
title('filtered image');
imwrite(im_out,[out_dir,'rotmask_output.jpg']);

diff = sum(sum(abs(im-im_out)))/prod(size(im));
i = 1;
if 0 % testing convergence of the filtering process
  im_out_iter{i}=im_out;
  while diff>0.1
  i=i+1;
  im_out_iter{i}=rotmask(im_out_iter{i-1},'integral','double');
  figure(i+1); clf
  imshow(im_out_iter{i});
  title(sprintf('filtered image, iteration %d',i));
  diff = sum(sum(abs(im_out_iter{i}-im_out_iter{i-1})))/prod(size(im))
  end
end

