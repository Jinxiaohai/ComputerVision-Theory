%BCKGGM_DEMO demonstration of adaptive background modeling
%CMP Vision Algorithms http://visionbook.felk.cvut.cz


% Example of adaptive background modeling
% One sample sequence is provided. You can test your own 
% or download more test data from the . The demonstration reads
% sequence of images sequentially and displays and saves
% various output images. Display is optimized for saving figures,
% and the on-line demonstration may require a different setting, see the code.
% The demonstration saves eight images per frame into cfg.output.dir, see
% the comments in the code. 
%
% The adaptiveness of the algorithm is illustrated on a simple office sequence, see
% Figure ??. Five Gaussians were used and one particular pixel 
% is studied. A simple moving object, local and global background changes are all present
% in the sequence. Despite the fact that the algorithm parameters were not tuned at all,
% it performs quite well. The notable exceptions are the strong shadows cast by the 
% moving person on the doors. It is interesting to see how the background image evolves
% over time. The lower left graphs on 
% Figures ??, ??
% represent the Gaussians. Only the Red and Green observations are shown for better
% clarity. The weights of the Gaussians are written as numbers in gray
% rectangles and coded by the width of the red circles. The circle radius is equal
% to cfg.exp.thr * sigma_k. The video showing the results on the 
% complete sequence is available at the .
% 

clear all;

addpath ../.
cmpviapath('../.');
% create a directory for output images
% if needed and does not already exist
if (exist('output_images')~=7)
  mkdir('output_images')
end

cfg.input.dir = './images/Office/';
cfg.input.basename = 'img01_%04d'; 
cfg.input.fmt = 'jpg';

% Demo saves 8 images per each frame
% into cfg.output.dir/cfg.output.dirs{1-8} directories
% 01Input       ... input frames
% 02Bckg        ... background image saved with imwrite
% 03Segm        ... binary image with segmentation mask
% 04ImSegm      ... segmentation mask applied to the input image
% 05ImPoint     ... image with the point of interest
% 06ImSegmPoint ... 04ImSegm with the marked point
% 07Observ      ... graph with the observations
% 08BckgPrint   ... the same as 02Bckg but printed via print command
cfg.output.dir = '/local/temporary/svoboda/output_images/Office_faster/';
cfg.output.fmt = 'png';
cfg.output.dirs = {'01Input/','02Bckg/','03Segm/','04ImSegm/','07Observ/','05ImPoint/','06ImSegmPoint/','08BckgPrint/'};


cfg.exp.alpha = 0.01;
cfg.exp.K = 5;
cfg.exp.var = 30; % initial variance  % 50 for noisy Erlangen data
cfg.exp.idx = [1:1:1070]; % [2:10:354];   % 212 for Erlangen data, 354 for advbgst, 1-4956 ETH_EFloor
cfg.exp.thr = 2.5;
cfg.exp.T = 0.6;

model = [];
idx = [];
scaling = 1/2;

% create the output directories is needed
for i=1:length(cfg.output.dirs),
  if ~(exist([cfg.output.dir,cfg.output.dirs{i}])==7)
  mkdir([cfg.output.dir,cfg.output.dirs{i}]);
  end
end

point4study = [254,360]/2; % advgst1_21
point4study = [146,89]; % Office (G9)

R=[];G=[];

% main background modeling cycle
for i=cfg.exp.idx,
  fprintf('processing frame: %3d \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b',i)
  im = imread([cfg.input.dir,sprintf(cfg.input.basename,i),'.',cfg.input.fmt]);
  imw = size(im,2);imh = size(im,1);
  imwrite(im,[cfg.output.dir,cfg.output.dirs{1},sprintf('im_%04d.jpg',i)],'jpg');
  im4seg = imresize(im,scaling);
  [model,idx,res] = bckggm(im4seg,model,idx,cfg.exp);
  if size(res.bckg,3)<3
    res.bckg = res.bckg(:,:,1);
  end
  res.bckg = uint8(imresize(res.bckg,1/scaling,'nearest',1));
  figure(1)
  imshow(im), set(gca,'Position',[0,0,1,1]), set(gcf,'Position',[100,100,imw,imh]);
  hold on, plot(point4study(2),point4study(1),'g+','LineWidth',3,'MarkerSize',15), hold off
  % title(sprintf('frame: %3d',i))
  print('-dpng','-r0',[cfg.output.dir,cfg.output.dirs{6},sprintf('im_with_point_%04d.png',i)])
  figure(2), set(gca,'Position',[0,0,1,1]), set(gcf,'Position',[100,100,imw,imh]);
  imshow(res.bckg), set(gca,'Position',[0,0,1,1])
  % title(sprintf('background model after frame: %3d',i))
  imwrite(res.bckg,[cfg.output.dir,cfg.output.dirs{2},sprintf('bckg_%04d.jpg',i)],'jpg');
  print('-dpng','-r0',[cfg.output.dir,cfg.output.dirs{8},sprintf('bkcg_%04d.png',i)])
  % post-process segm, just clean the one-pixel impuls noise
  res.segm = bwmorph(res.segm,'clean');
  % res.segm = bwmorph(res.segm,'open',[1,1]');
  res.segm = logical(imresize(res.segm,1/scaling,'nearest'));
  figure(3),
  imshow(res.segm), set(gca,'Position',[0,0,1,1]), set(gcf,'Position',[100,100,imw,imh]);
  % title(sprintf('segmentation for frame: %3d',i))
  imwrite(res.segm,[cfg.output.dir,cfg.output.dirs{3},sprintf('segm_%04d.jpg',i)],'jpg','Quality',90);
  % overlay
  imsegm = uint8(double(im).*repmat(double(res.segm),[1,1,size(im,3)]));
  figure(4),
  imshow(imsegm), set(gca,'Position',[0,0,1,1]), set(gcf,'Position',[100,100,imw,imh]);
  hold on, plot(point4study(2),point4study(1),'g+','LineWidth',3,'MarkerSize',15), hold off
  print('-dpng','-r0',[cfg.output.dir,cfg.output.dirs{7},sprintf('imsegm_with_point_%04d.png',i)])
  imwrite(imsegm,[cfg.output.dir,cfg.output.dirs{4},sprintf('imsegm_%04d.jpg',i)],'jpg');
  % visualization of a one point
  figure(5), clf
  axis equal
  axis([0 255 0 255])
  xlabel('R'),ylabel('G'),
  % title(sprintf('frame %3d',i))
  grid on;
  hold on
  % accumulate RG observations
  p = round(point4study*scaling);
  m = squeeze(model(p(1),p(2),:,:));
  r = cfg.exp.thr*sqrt(m(:,idx.vars));
  for j=1:size(m,1),
  plot(m(j,idx.mu(1)),m(j,idx.mu(2)),'r+','LineWidth',3,'MarkerSize',10)
  h = rectangle('Position',[m(j,idx.mu(1:2))-[r(j),r(j)],2*[r(j),r(j)]],'Curvature',[1,1],...
          'EdgeColor',1-m(j,idx.w)*[1,1,1],'LineWidth',2);
  if m(j,idx.bckg)
    set(h,'EdgeColor','r','LineWidth',5*(1+m(j,idx.w)/cfg.exp.T)-4)
  end
  plot(m(j,idx.mu(1)),m(j,idx.mu(2)),'r+','LineWidth',3,'MarkerSize',10)
  txtshift = (0.7*r(j)+2)*[1,1];
  txtalign = 'left';
  postext = [m(j,idx.mu(1)),m(j,idx.mu(2))]+txtshift;
  if any(postext>255),
    postext(postext>255) = postext(postext>255)-2*txtshift(postext>255);
    txtalign = 'right';
  end
  text(postext(1),postext(2),sprintf('%2.3f',m(j,idx.w)),'HorizontalAlignment',txtalign,...
     'BackGroundColor',0.9*[1,1,1])
  end
  R = [R,im4seg(p(1),p(2),1)];
  G = [G,im4seg(p(1),p(2),2)];
  for j=1:length(R),
  plot(R(j),G(j), 'o'),
  end
  % show the last observation in green to emphasize it
  plot(R(end),G(end), 'go', 'MarkerSize', 5, 'LineWidth',2),
  hold off;
  set(gcf,'Position',[100,100,imw,imh]);
  drawnow;  
  print('-depsc2','-cmyk',[cfg.output.dir,cfg.output.dirs{5},sprintf('observ_%04d.eps',i)])
  print('-dpng','-r0',[cfg.output.dir,cfg.output.dirs{5},sprintf('observ_%04d.png',i)])
end

figure(10), clf
plot(cfg.exp.idx,R,'r-','LineWidth',2)
hold on
plot(cfg.exp.idx,G,'g-','LineWidth',2)
legend('Red channel','Green channel','Location','NorthWest')
title(sprintf('accumulated observations in point [%d %d]',point4study))
xlabel('frame No.')
ylabel('Value')
grid on
print('-depsc2','-cmyk',[cfg.output.dir,'accumulated_observations.eps'])

