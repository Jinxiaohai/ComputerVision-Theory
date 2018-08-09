% PARTICLE_FILTERING_DEMO Demo showing the usage of particle_filtering
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Petr Lhotsky, Tomas Svoboda 2007

clear all;
clear classes;
DEMOS_IDX = [1,2]; % index of demos to proceed [1,2]
ON_LINE = 1;     % display tracking on-line 
SAVE_FIGS = 0 & ON_LINE; % save on-line figures (works only for 1D demo) 
SAVE_IMAGES = 1;

out_dir = './output_images/';
% create a directory for output images
% if needed and does not already exist
if (exist(out_dir)~=7)
  mkdir(out_dir);
end


if any(DEMOS_IDX==1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEMO1D  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DIR_RESULTS = './Results/Particle_filtering/1D/';
if exist(DIR_RESULTS,'dir')
  % delete the old results
  delete([DIR_RESULTS '*']);
else % make it
  mkdir(DIR_RESULTS);  
end


% Example - tracking a 1D state
%
% This example shows the tracking of simple 1D system using particle
% filtering. The data are generated artificially in order to have 
% full control on the process. The 1D state evolves along a pre-defined path and 
% it is slightly corrupted by noise. The measurement function provides random measurement
% centered around the true state. Playing with parameters and observing 
% the behavior of the system is 
% easy and helps in understanding the particle filtering approach.

addpath('./demo1D');

% The whole method is robust
% and, once set, the parameters are usually applicable to many
% scenarios. Nevertheless,
% wrong parameters may lead to confusion. Knowing the
% meaning of the parameters is essential to fully understand the
% whole particle filtering procedure.
%
% [conf.steps ] Number of discrete time steps in
% state evolution. In real world setting it is dictated by
% the application for example the number of frames in a video sequence.
conf.steps = 100; % number of steps

%[conf.sigma_1 ] Standard deviation of the state variables.
% Used in the demonstration settings for generation of the signal.
conf.sigma_1 = 0.02; % standard deviation - system

% [conf.N ] Number of samples (particles). The higher the number of
% samples, the more accurate and more robust the estimate. 
% Use as many samples as you can afford to: in
% real systems, the measurement function takes most of the
% computational time which makes the computation cost linear in
% terms of this number. The number of samples is also 
% dictated by the dimensionality of the system (state). More
% dimensions require more samples.
conf.N = 150; % number of samples

% [conf.sigma_2 ] Standard deviation for the
% measurement function. In this artificial case the measurement
% p.d.f.\ is a mixture of a zero-mean Gaussian with sigma=
% conf.sigma_2 centered around the true state and a
% uniform distribution over the whole state domain. The uniform
% distribution with small weight simulates a non-zero response of a
% real measurement function. The measurement function p.d.f.\ is
% depicted in Figure ??. 
% For a more realistic example see function
% demo2D/measurement.
conf.sigma_2 = 0.5; % standard deviation for the measurement function

% [conf.Cov ] Covariance matrix of the state noise.
conf.Cov = 0.1; % covariance matrix - sampling (scalar for 1D)

% [conf.alpha ] Forgetting coefficient for
% the velocity model.
conf.alpha = 0.3; % factor for exponential forgetting - motion model


% The simulated system trajectory consists of two phases with
% harmonic motion and one with linear motion. There are
% discontinuities to demonstrate the robustness of tracking using
% particle filtering
% The observation of the system state is driven by a zero-mean
% normally distributed noise with standard deviation
% sigma_1. The generated state trajectory of the system is
% saved as Matlab mat-files into a directory
% DIR_RESULTS Edit the
% particle_filtering_demo file to use your own system: 
% to simulate a real situation we observe the system through some blur
% modeled as a zero-mean normally distributed noise with standard
% deviation sigma_2.
%
third = round(conf.steps/4);
X(1) = normrnd(0,conf.sigma_1);
for i = 1:(third-1)
  X(i+1) = X(i) + (sin(2*pi*i/third)-sin(2*pi*(i-1)/third)) + ...
           normrnd(0,conf.sigma_1);
end
X(third) = sin(3*pi/2) + normrnd(0,conf.sigma_1);
for i = third:(2*third-1)
  X(i+1) = X(i) + (sin(2*pi*i/third+3*pi/2)-sin(2*pi*(i-1)/third+3*pi/2)) + ...
           normrnd(0,conf.sigma_1);
end
increment = -2/(conf.steps-2*third);
X(2*third) = 1 + normrnd(0,conf.sigma_1);
for i = (2*third+1):conf.steps
  X(i) = X(i-1) + increment + normrnd(0,conf.sigma_1);
end
save([ DIR_RESULTS 'X'],'X');
% To initialize the algorithm the samples are normally distributed around 
% the initial known value. Their weights are uniform, since we have 
% no prior information. There is no history, thus the velocity of the motion 
% model is zero.

S.s   = normrnd( 0, conf.Cov, 1, conf.N ); % initialize samples
S.pi  = ones(1,conf.N) / conf.N;           % set uniform weights
S.v   = 0;                                 % initialize motion model
S.est = estimation( S, conf );             % set estimated value

save([DIR_RESULTS sprintf('step%04d',1)],'S');
howmany_samples = conf.N;
step_samples = round(conf.N/howmany_samples);
howmany_samples = length(1:step_samples:conf.N);
vec4samples = ones(1,howmany_samples);
figure(1), clf
step = 1;
if ON_LINE % on-line display of the tracking
  % plot(step,X(step),'r.','MarkerSize',20,'EraseMode','background');
  plot(1:length(X),X,'r.','MarkerSize',10,'EraseMode','background');
  plot(1:length(X),X,'r-','EraseMode','background');
  hold on
  plot(step,S.est,'b.','MarkerSize',15,'EraseMode','background');
  plot(step*vec4samples,S.s(1:step_samples:end),'g+','EraseMode','background')
  axis([[1 conf.steps] [-4 4]]);
  legend('state of the system','estimated value','samples','Location','SouthWest');
  drawnow
end
scr_size = get(0,'ScreenSize');
set(gcf,'Position',[0,1.8*scr_size(4)/3,scr_size(3),1.1*scr_size(4)/3])
xlabel('time step')
ylabel('state value')
if SAVE_FIGS
  print('-djpeg',[DIR_RESULTS,sprintf('pfilter1D_%03d',step)])
end

% The main tracking cycle is a repeated call of the particle_filtering
% function.
for step = 2:conf.steps             % for all generated states
  S.x = X(step);                  % states of the system 
  S = particle_filtering( S, conf ); % run particle filtering
  save([DIR_RESULTS sprintf('step%04d',step)],'S');
  if ON_LINE % on-line display of the tracking
  % plot(step,X(step),'r.','MarkerSize',20,'EraseMode','background');
  plot(step*vec4samples,S.s(1:step_samples:end),'g+','EraseMode','background')
  plot(step,S.est,'b.','MarkerSize',15,'EraseMode','background');
  plot(step,X(step),'r.','MarkerSize',20,'EraseMode','background');
  drawnow;
  if SAVE_FIGS
    print('-djpeg',[DIR_RESULTS,sprintf('pfilter1D_%03d',step)])
  end
  end
end
% This is the end of the main cycle. 
plot(1:conf.steps,X,'r-','LineWidth',2,'EraseMode','background');
line([third third]-1,get(gca,'Ylim'),'Color','r')
line((2*[third third])-1,get(gca,'Ylim'),'Color','r')



% Load results from mat-files
load([DIR_RESULTS 'X']);
est = zeros(1,conf.steps);
samples = zeros(conf.N,conf.steps);
for i = 1:conf.steps
  load([DIR_RESULTS sprintf('step%04d',i)]);
  est(i) = S.est;
  samples(:,i) = S.s;
end

plot(1:conf.steps,est,'b-','LineWidth',2,'EraseMode','background');

idx_ge = round(third/2); % good estimate of the state
idx_be = 2*third+3;      % bad estimate just after the break

line([idx_ge idx_ge],get(gca,'Ylim'),'Color','b')
line([idx_be idx_be]-1,get(gca,'Ylim'),'Color','b')
drawnow;

if SAVE_IMAGES 
  print('-depsc2','-cmyk',[out_dir,'PF_tracking_evolution.eps']);
end

ylim = get(gca,'Ylim');

figure(2); clf; hold on;
i = idx_ge;
A.s = [ylim(1):0.01:ylim(2)];
load([DIR_RESULTS sprintf('step%04d',i)]);

subplot(4,1,1);
A.x = S.x;
plot(A.s,measurement(A,conf));
hold on;
plot(S.x,0,'r.','MarkerSize',25);
title(['step ' num2str(i)]);
legend('measurement function','true state','Location','NorthEast');

subplot(4,1,2);
stem(S.s,S.pi);
hold on;
plot(S.est,0,'g.','MarkerSize',25);
axis([ylim,[0 max(S.pi)+0.01]]);
legend('weighted samples','estimated state','Location','NorthEast');

i = idx_be;
load([DIR_RESULTS sprintf('step%04d',i)]);
A.x = S.x;
subplot(4,1,3);
plot(A.s,measurement(A,conf));
hold on;
plot(S.x,0,'r.','MarkerSize',25);
title(['step ' num2str(i)]);
legend('measurement function','true state','Location','NorthEast');

subplot(4,1,4);
stem(S.s,S.pi);
hold on;
plot(S.est,0,'g.','MarkerSize',25);
axis([ylim,[0 max(S.pi)+0.01]]);
legend('weighted samples','estimated state','Location','NorthEast');

set(gcf,'Position',[0,scr_size(4)/3,scr_size(3)./2,2*scr_size(4)/3])

if SAVE_IMAGES
  print('-depsc2','-cmyk',[out_dir,'PF_weights_and_samples.eps']);
end


rmpath('./demo1D');

if all(DEMOS_IDX==1)
  return; % quit the demo script if only one demo is required
end
clear X
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% end demo1D  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if any(DEMOS_IDX==2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEMO2D  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2D Example - object tracking in an image sequence
% The second example consists of estimation of the motion of two white blobs
% randomly moving through a 2D scene.
% Both the background and the objects are corrupted by noise. Similarity
% is measured by a weighted sum of absolute intensity differences between the model
% and the image. The p.d.f.\ is essentially bimodal.
%

close all; % closing figures required for correct displaying
addpath('./demo2D');
SAVE_IMAGES = 1;
CREATE_IMAGES = 1;
DIR_RESULTS = './Results/Particle_filtering/2D/';
DIR_IMAGES = './Input_images/Particle_filtering/';
if exist(DIR_RESULTS,'dir')
  % delete the old results
  delete([DIR_RESULTS '*']);
else % make it
  mkdir(DIR_RESULTS);  
end

% Set parameters
conf.N = 1000; % Number of samples
conf.steps = 100; % Number of steps
conf.sigma = 3;  % noise in blob positions 
conf.Cov = diag([10 10]); % Covariance --- sampling
conf.alpha = 0; % Turn off the motion model
conf.blob = 10; % Size of the blob
conf.area = 20; % Size of the area around the sample to find the blob
conf.img_x = 200; % Width of the image
conf.img_y = 300; % Height of the image

% the object is defined by hand 
object = uint8(230*ones(2*conf.blob+1,2*conf.blob+1));

% Creation of the artificial images can be controlled by setting a variable
% CREATE_IMAGES.
% If set to 1, images will be created and saved to a directory specified in 
% variable DIR_IMAGES. If set to 0 the previously
% created images will be directly read from DIR_IMAGES. 

if CREATE_IMAGES
  disp('Creating images, please wait...');
  %% delete the old images or create the directory if does not exist
  if exist(DIR_IMAGES,'dir')
    delete([DIR_IMAGES '*']);
  else 
    mkdir(DIR_IMAGES);  
  end

  %% Create states of the system
  X{1} = [conf.img_x/2 conf.img_y/4 ;conf.img_x/2 conf.img_y*(3/4)];
  margins_max = round([(conf.img_x-conf.area)-1 (conf.img_y-conf.area)-1; ...
                       (conf.img_x-conf.area)-1 (conf.img_y-conf.area)-1]);
  margins_min = round([conf.area+1 conf.area+1; conf.area+1 conf.area+1]);
  for i = 2:conf.steps
    X{i} = X{i-1} + normrnd(0,conf.sigma,2,2);
    % Check the position
    idx = X{i} > margins_max;
    X{i}(idx) = margins_max(idx);
    idx = X{i} < margins_min;
    X{i}(idx) = margins_min(idx);
  end
  save([DIR_RESULTS 'X'],'X');

  %% Create and save images
  for i = 1:conf.steps
    Img = uint8(uniformd(0,128,conf.img_x,conf.img_y));
    x = round(X{i});
    % the objects are perturbed by uniform noise
    Img((x(1)-conf.blob):(x(1)+conf.blob),(x(3)-conf.blob):(x(3)+conf.blob)) = uint8(double(object)+uniformd(-10,10,size(object,1),size(object,2)));
    Img((x(2)-conf.blob):(x(2)+conf.blob),(x(4)-conf.blob):(x(4)+conf.blob)) = uint8(double(object)+uniformd(-10,10,size(object,1),size(object,2)));
    imwrite(Img,[DIR_IMAGES sprintf('img%04d.png',i)],'png');
  end
  disp('done');
end

Img = imread([DIR_IMAGES sprintf('img%04d.png',1)]);
[x y dim] = size(Img);
if dim > 1
  error('Only grayscale images supported');
elseif (x ~= conf.img_x) || (y ~= conf.img_y)
  conf.img_x = x;
  conf.img_y = y;
end
% To ensure good discrimination the differences between the model
% and image are masked by a weighting function with emphasis on the
% center,
% The object is predefined and its appearance in images 
% is always perturbed by some random noise.
offset = ( conf.area-conf.blob+1 );
conf.model = zeros( conf.area*2+1 );
conf.model( offset:offset+conf.blob*2, offset:offset+conf.blob*2 ) = object;
% conf.mask = ones(conf.area*2+1);
% conf.mask(offset:offset+conf.blob*2,offset:offset+conf.blob*2) = 5;
% construct a smooth weighting function
conf.mask = fspecial( 'gaussian', conf.area*2+1, conf.blob/2 );
conf.mask = conf.mask ./ sum(conf.mask(:));
figure(110), clf
imshow(uint8(conf.model),'InitialMagnification',round(100*(480/size(conf.model,2))));
axis on;
title('model of the object')
figure(111), clf
mesh(conf.mask)
title('weighting function')
drawnow;
if SAVE_IMAGES
  figure(110),
  print('-depsc2','-cmyk',[out_dir,'PF_objectmodel.eps']);
  figure(111),
  print('-depsc2','-cmyk',[out_dir,'PF_weightfunction.eps']);
end

% To initialize, the particle filtering samples are uniformly
% distributed through the observed scene with uniform weights.
S.s = [rand(1,conf.N)*conf.img_x; rand(1,conf.N)*conf.img_y]; 
S.pi = ones(1,conf.N)/conf.N; % set uniform weights
S.v = 0;                      % meaningless, velocity model not used 
S.est = estimation( S, 1, conf); % set estimated value
save( [DIR_RESULTS sprintf('step%04d',1)], 'S' );
% After resampling in particle_filtering the helper functions are used. 
% Note that drift_samples and
% estimation are void, because this experiment does not use a motion
% model.
% The main tracking cycle consists of repeated calling
% of the function particle_filtering. 
for step = 2:conf.steps
  S.img = imread( [DIR_IMAGES sprintf('img%04d.png',step)] ); % load image
  S = particle_filtering( S, conf ); % run particle filtering
  show_state(S,conf); % display current set of samples
  save( [DIR_RESULTS sprintf('step%04d',step)], 'S' ); % save structure S
end

step = 4;
[conf.XI,conf.YI] = meshgrid([0:step:conf.img_y], [0:step:conf.img_x]);
h = waitbar(0,'Processing probability maps');
for i = 1:conf.steps
  load([DIR_RESULTS sprintf('step%04d',i)]);
  Prob_map = griddata(S.s(2,:),S.s(1,:),S.pi,conf.XI,conf.YI,'cubic');
  Prob_map = Prob_map./max(Prob_map(:));
  Prob_map = im2uint8(imresize(Prob_map,step));
  waitbar(i/conf.steps);
  imwrite(Prob_map,[DIR_RESULTS sprintf('prob_map%04d.png',i)],'png');
end
close(h);

conf.DIR_IMAGES = DIR_IMAGES;
conf.DIR_RESULTS = DIR_RESULTS;

% The function show_results_PF serves for an off-line analysis
% of the tracking results. It displays a simple GUI that allows
% re-playing of results back and forth, frame-by-frame
% evaluation and displaying various data. It reads the data from
% disk, and can used on other compatible data, too.
show_results_PF( conf );

step = round(conf.steps/2);
load([DIR_RESULTS sprintf('step%04d',step)]);
S.img = imread([DIR_IMAGES sprintf('img%04d.png',step)]);
Prob_map = imread([DIR_RESULTS sprintf('prob_map%04d.png',step)]);

figure(4);
imshow(S.img);
hold on;
plot(S.s(2,:),S.s(1,:),'.','Color',[1 0 0]);
axis on;
title(sprintf('State of the system with samples in the step: %d',step));
if SAVE_IMAGES
  print('-depsc2','-cmyk',[out_dir,'PF_samples.eps']);
end

figure(5);
imagesc(Prob_map);
title(sprintf('Probability interpolated from the weights of the samples, step: %d',step));
colormap(cool);
colorbar;
if SAVE_IMAGES
  print('-depsc2','-cmyk',[out_dir,'PF_probability.eps']);
end


rmpath('./demo2D');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% end of 2D demo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

