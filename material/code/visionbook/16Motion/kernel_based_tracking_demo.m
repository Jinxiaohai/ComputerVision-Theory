% KERNEL_BASED_TRACKING_DEMO Demo showing the usage of kernel_based_tracking
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Petr Lhotsky, Tomas Svoboda, 2007
%
% History:
% $Id: kernel_based_tracking_demo_decor.m 1086 2007-08-14 13:41:41Z svoboda $
%
% 2007-03-23 Petr Lhotsky: created
% 2007-04-06 Tomas Svoboda: modified towards book compatibility
%                           comments extended
% 2007-06-06 TS: directory handling fixed

% adding path to otherCMPvia functions
addpath ../.
cmpviapath('../.');
% create a directory for output images
% if necessary, and does not already exist
out_dir = './output_images/';
if exist(out_dir)~=7
  mkdir(out_dir)
end

CREATE_IMAGES = 1; % create new images?
INIT_INTERACTIVE = 0; % initialize the tracking by click?
                      % if 0 -> relies on init_track function 
DIR_RESULTS = './Results/Kernel_based_tracking/';
DIR_IMAGES = './Input_images/Kernel_based_tracking/';
if exist(DIR_RESULTS,'dir')
  % delete the old results
  delete([DIR_RESULTS '*']);
else % make it
  mkdir(DIR_RESULTS);  
end
if exist(DIR_IMAGES,'dir')
  % delete the old images
  delete([DIR_IMAGES '*']);
else % make it
  mkdir(DIR_IMAGES);  
end
% Example - 2D blob tracking by using a histogram

% Set parameters
conf.steps = 100; % Number of steps
conf.img_x = 200; % Width of the image
conf.img_y = 300; % Height of the image
conf.blob = 13; % Size of the blob
conf.margin = 5; % Minimal distance from the blob to the edge of the image
conf.sigma = 5; % Standard deviation - system
conf.h = 15; % Kernel size, in pixels
conf.bins = 32; % Number of bin of the histogram
conf.grid = [0 255]; % Range of the histogram
conf.table = histtable(conf); % Compute the lookup table for histogram
conf.iters = 20; % maximal number of the iterations in one cycle
conf.treshold = 0.4; % threshold for the end-condition of the mean-shift cycle


% The demonstration simulates a frequent scenario: 2D blob tracking
% by using a histogram for target modeling. 
% The artificially generated images contain a moving bright blob on a
% dark background - both the blob and the background are corrupted
% by noise. The target (blob) is modeled
% by its histogram. As the histogram is a general-purpose
% representation the demonstration code should
% be directly applicable to real-world scenarios, perhaps with the
% exception of the automatic 
% initialization which is often tricky.
if CREATE_IMAGES
    disp('Creating test images, please wait...');
    %% Create states of the artificial system
    X{1} = [conf.img_x/2 conf.img_y/2]; % Initial position is in the center of the image
    margins_max = round([(conf.img_x-(conf.margin+conf.h))-1 (conf.img_y-(conf.margin+conf.h))-1]);
    margins_min = round([conf.margin+conf.h+1 conf.margin+conf.h+1]);
    for i = 2:conf.steps
        X{i} = X{i-1} + normrnd(0,conf.sigma,1,2);
        % Check the position
        idx = X{i} > margins_max;
        X{i}(idx) = margins_max(idx);
        idx = X{i} < margins_min;
        X{i}(idx) = margins_min(idx);
    end

    %% Create and save images
  %% The object is noisy but the same for all frames
  object = uint8(uniformd(200,255,2*conf.blob+1,2*conf.blob+1));
    for i = 1:conf.steps
        Img = uint8(uniformd(0,128,conf.img_x,conf.img_y));
        x = round(X{i});
        Img((x(1)-conf.blob):(x(1)+conf.blob),(x(2)-conf.blob):(x(2)+conf.blob)) = object;
        imwrite(Img,[DIR_IMAGES sprintf('img%04d.png',i)],'png');
    end
    disp('done');
end
% To enable easy testing of the algorithm, the user can select the region which
% will be tracked. For these particular data it is done automatically, see 
% the function init_track.
% Grab the region to track
Img = imread([DIR_IMAGES sprintf('img%04d.png',1)]);
[x y dim] = size(Img);
if dim > 1
    error('Only grayscale images supported');
elseif (x ~= conf.img_x) || (y ~= conf.img_y)
    conf.img_x = x;
    conf.img_y = y;
end
figure(1);
h_img = imshow(Img);

while true
  if INIT_INTERACTIVE  
  title('Click in the center of the target object');
  conf.center = round(ginput(1));
  else % try to get it automatically;
  conf.center = init_track(Img);
  end
  xl = max(conf.center(1)-conf.h,1);
  xh = min(conf.center(1)+conf.h,conf.img_y);
  yl = max(conf.center(2)-conf.h,1);
  yh = min(conf.center(2)+conf.h,conf.img_x);
  hold on;
  angle = (0:0.01:2*pi);
  circ_x = sin(angle)*conf.h;
  circ_y = cos(angle)*conf.h;
  h_circ = plot(conf.center(1)+circ_x,conf.center(2)+circ_y,'r');
  if (xh-xl == 2*conf.h) && (yh-yl == 2*conf.h)
  break % leave
  else
  warning('Area is too small');
  end
end
conf.model = Img(yl:yh,xl:xh);

% Compute the probability model of the target model
conf.q = init_model(conf);

% Initialize the position in the first step
S.y = conf.center;
save([DIR_RESULTS sprintf('step%04d',1)],'S');

% The tracking runs in a cycle. First the input image is read from a
% file, then the new position of the object is computed using kernel-based
% tracking. The results are saved.
figure(1)
y0 = conf.center;
iters = zeros( 1, conf.steps );
for step = 2:conf.steps % all frames in the sequence
  S.img = imread( [DIR_IMAGES sprintf('img%04d.png',step)] );
  S = kernel_based_tracking( S, y0, conf, 0 );
  y0 = S.y;
  save([DIR_RESULTS sprintf('step%04d',step)],'S');
  iters(step) = S.iter;
  figure(1)
  set(h_img,'CDATA',S.img);
  set(h_circ,'XData',S.y(1)+circ_x);
  set(h_circ,'YData',S.y(2)+circ_y);
  title(['step: ' int2str(step)]);
  drawnow;
end

figure(2); clf
imshow(conf.model);
axis off;
exportfig(gcf,[out_dir,'KBT_target.eps'])

figure(3), clf
bar(conf.q)
title('Histogram of the target');
xlabel('bin Id of the histogram');
ylabel('probability');
exportfig(gcf,[out_dir,'KBT_model.eps'])

figure(4), clf
[maxit, i] = max(iters); % round(conf.steps/2);
load([DIR_RESULTS sprintf('step%04d',i)]);
imshow(S.img);
axis off ;
hold on;
title('Example of an input image');
exportfig(gcf,[out_dir,'KBT_image.eps'])


% analyze results for the case with maximum
% number of mean-shift iterations
[maxit, i] = max(iters); % round(conf.steps/2);
load([DIR_RESULTS sprintf('step%04d',i-1)]);
worst.img = imread([DIR_IMAGES sprintf('img%04d.png',i)]);
% launch the kernel based tracking once again
% for the worst frame and with the verbosity parameter
worst = kernel_based_tracking(worst,S.y,conf,1);

% print the interesting figures
figure(10)
% zoom into it
axis([worst.y(1)+3*[-conf.h,conf.h], worst.y(2)+3*[-conf.h,conf.h]]);
exportfig(gcf,[out_dir,'KBT_iters_imgs.eps'])

figure(15)
exportfig(gcf,[out_dir,'KBT_iters_hists.eps'])



load([DIR_RESULTS sprintf('step%04d',i)]);
Prob_map = zeros(conf.img_x,conf.img_y);
h = waitbar(0,'Processing full similarity surface for one frame, please wait');
for x = 1:1:conf.img_x
    for y = 1:1:conf.img_y
        xl = max(y-conf.h,1);
        xh = min(y+conf.h,conf.img_y);
        yl = max(x-conf.h,1);
        yh = min(x+conf.h,conf.img_x);
        candidate = S.img(yl:yh,xl:xh);
        nxw = xh-xl+1; nyw = yh-yl+1;
        nw=nxw*nyw; iw=(0:(nw-1))';
        Coord = [floor(iw/nyw+xl) mod(iw,nyw)+yl]; % Coordinates
        Dist = sum((((Coord-repmat([y x],nw,1))/conf.h).^2),2); % Distance
        idx = Dist<1; % Where the distance is less than 1 - kernel is greater than 0
        Dist = Dist(idx);
        Coord = Coord(idx,:);
        Kern = epanech_kernel(Dist); % Compute the kernel weights
        Hist = reshape(candidate,[],1);
        Hist = Hist(idx);
        Hist = conf.table(Hist+1); % Compute the histogram using lookup table
        p = zeros(1,conf.bins);
        % Probability of the bin u (p_u)
        for u = 1:conf.bins
            p(u) = sum(Kern(Hist == u));
        end
        p = p/sum(Kern); % Normalize
        Prob_map(x,y) = sum(sqrt(conf.q(:).*p(:)));
    end
    waitbar(x/conf.img_x);
end
close(h);

figure(4)
subplot(4,1,[1 3]);
plot(iters(2:end),'.','MarkerSize',30);
title('Number of iterations during steps');
xlabel('step');
ylabel('iterations');
subplot(4,1,4);
hist(iters(2:end),max(iters));
exportfig(gcf,[out_dir,'KBT_iters.eps'])

figure(5)
imagesc(Prob_map);
axis image;
axis on;
colorbar;
title(sprintf('Similarity surface of the frame %d',i));
exportfig(gcf,[out_dir,'KBT_similarity.eps'])

conf.DIR_RESULTS = DIR_RESULTS;
conf.DIR_IMAGES = DIR_IMAGES;
show_results_KBT(conf);

