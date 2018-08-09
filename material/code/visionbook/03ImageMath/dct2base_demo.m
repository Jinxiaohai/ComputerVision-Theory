% DCT2BASE_DEMO demonstration of DCT2 in imaging
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
%
% History:
% $Id: dct2base_demo_decor.m 1088 2007-08-16 06:34:55Z svoboda $

% sanity clear
clear all;

% adding path to other functions, integralim is needed
addpath ../.
cmpviapath('../.');
% create a directory for output images
% if necessary, and does not already exist
out_dir = './output_images/';
if exist(out_dir)~=7
  mkdir(out_dir)
end


blocksize = [8,8];
base = dct2base(blocksize);
 
r = blocksize(1); 
c = blocksize(2);

sep = 1;
baseall = zeros([blocksize.^2+blocksize.*sep+[sep,sep],3]);
baseall(:,:,1) = 0.9;
baseall(:,:,2) = 0.2;
baseall(:,:,3) = 0.1;
 
figure(1), clf
for i=1:r
  for j=1:c
    onebase = squeeze(base(i,j,:,:));
    % normalize the one dct base for better visibility
    onebase = onebase+abs(min(onebase(:)));
    onebase = onebase./(max(onebase(:))+eps);
    baseall(i*sep+[1+(i-1)*r:i*r],j*sep+[1+(j-1)*c:j*c],:) = squeeze(repmat(onebase,[1,1,3]));
    % but plot the true values
    subplot(r,c,(i-1)*c+j),
    imagesc(squeeze(base(i,j,:,:)));
    axis image, 
    axis off
  end
end
colormap(gray(256))

figure(2),
imshow(baseall,'InitialMagnification',480/size(baseall,2)*100)
title(sprintf('DCT2 base for [%dx%d] block',blocksize))
exportfig(gcf,[out_dir,sprintf('dct2base%dx%d.eps',blocksize)]);
im = imread('cameraman.tif');     
coeff = 1;
blocksize = coeff*[8 8];
colshift= 13;
rowshift= 4;
roi = [1+rowshift*blocksize(1),1+colshift*blocksize(2)];
roi = [roi, roi+blocksize-[1,1]]; % [upper left, lower right] 
imroi.orig = im(roi(1):roi(3),roi(2):roi(4));
imroi.dct2 = round(dct2(imroi.orig));
figure(10), clf
imshow(im)
drawrect(gcf,roi,2);
title('image block')
exportfig(gcf,[out_dir,'dct2demo_imageblock.eps'])
figure(11), clf
cfg.fontsize = 14;
cfg.colshift = 0.03;                   % small tuning of the text position
showim_values(imroi.dct2,cfg,gcf);
title('coefficients of the DCT2')
exportfig(gcf,[out_dir,'dct2demo_coeffs.eps'])
figure(12), clf
cfg.gridcol = 1/2*[1 1 1];          % grid in gray color
cfg.colormap = colormap(gray(256)); % gray scale image assumed
cfg.txtcol = 'neg';                 % numbers in negative color                
cfg.colshift = 0;                   % small tuning of the text position
cfg.fontsize = 16;
showim_values(imroi.orig,cfg,gcf);
title('image intensities')
exportfig(gcf,[out_dir,'dct2demo_intensities.eps'])


% Second demo shows pictorially how an image can be represented by a linear
% combination of dct2 basis functions

im = imread('cameraman.tif');     

coeff = 2;
blocksize = coeff*[32 32];
colshift=1/coeff*3;
rowshift=1/coeff*1;
region(1).roi = [1+rowshift*blocksize(1),1+colshift*blocksize(2)];
region(1).desc = 'hi_freq';
colshift=1/coeff*6;
rowshift=1/coeff*4;
region(2).roi = [1+rowshift*blocksize(1),1+colshift*blocksize(2)];
region(2).desc = 'standard';

SAVE_IM = 0;
local_outdir = './';
local_dirs = {'dct2demo_01/','dct2demo_03/','dct2demo_05/'};
perc = [5,20,50,100];

disp('Please wait: computes the basis functions ... ')
base = dct2base(blocksize,ones(blocksize));
disp('... done, incremental reconstruction starts ...')

for j = 1:length(region),
  roi = region(j).roi;
  roi = [roi, roi+blocksize-[1,1]]; % [upper left, lower right] 
  imroi.orig = im(roi(1):roi(3),roi(2):roi(4));
  imroi.dct2 = round(dct2(imroi.orig));
  % initialization of displaying image, just to speed up
  fig4 = figure(4);clf
  h_img = imshow(zeros(size(imroi.orig),'uint8'),'InitialMagnification',round(320/blocksize(2)*100));
  h_title = title('0 %% of most significant DCT2 coeffs');

  figure(3), clf
  imshow(im)
  drawrect(gcf,roi,2);

  [sorted_vals, idx_sorted] = sort(abs(imroi.dct2(:)),'descend');
  sorted_vals_norm = sorted_vals/sum(sorted_vals);
  idx4print = round(length(idx_sorted).*(perc/100));
  idx4disp = round(length(idx_sorted).*([1:100]/100));

  if SAVE_IM % prepare the directories for saving images
    for i=1:length(local_dirs)
      local_dir = [local_outdir,region(j).desc,'/',local_dirs{i}];
      if exist(local_dir)~=7
        mkdir(local_dir);
      end
    end
  end
  
  % figure(4)
  newim = zeros(blocksize);
  for i=1:length(idx_sorted)
    [r,c]=ind2sub(blocksize,idx_sorted(i));
    if SAVE_IM
      imwrite(uint8(newim),[local_outdir,region(j).desc,'/',local_dirs{1},sprintf('step%05d.jpg',i)],'Quality',90);
    end
    onebase = squeeze(base(r,c,:,:));
    newim = newim+imroi.dct2(r,c)*onebase;
    % imshow(uint8(newim),'InitialMagnification',round(320/blocksize(2)*100));
    set(h_img,'CDATA',newim);    
    % title(sprintf('%4.1f %% of most significant DCT2 coeffs',100*i/length(idx_sorted)))
    set(h_title,'String',sprintf('%3.0f %% of most significant DCT2 coeffs',100*i/length(idx_sorted)))
    if any(i==idx4disp), drawnow, end;
    if any(i==idx4print)
      exportfig(fig4,[out_dir,sprintf('dct2demo_%s_%03d_perc_used.eps',region(j).desc,perc(i==idx4print))]);
    end
    if SAVE_IM
      normbase = onebase+abs(min(onebase(:)));
      normbase = onebase./(max(onebase(:))+eps);
      imwrite(normbase,[local_outdir,region(j).desc,'/',local_dirs{2},sprintf('step%05d.jpg',i)],'Quality',90);
      imwrite(uint8(newim),[local_outdir,region(j).desc,'/',local_dirs{3},sprintf('step%05d.jpg',i)],'Quality',90);
    end
  end
end


