% IMPORTANCE_SAMPLING importance sampling
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007

% History:
% $Id: importance_sampling_demo_decor.m 1138 2007-12-15 19:39:12Z svoboda $
%
% 2007-05-07 Tomas Svoboda (TS): created

% sanity clear
clear all;
addpath ../.
cmpviapath('../.');
out_dir = './output_images/';
if (exist(out_dir)~=7) 
  mkdir(out_dir);
end
REPEATED_RESAMPLING = 0;
SAVE_VISUALISATION = 0; % save intermediate visualisation
set(0,'DefaultAxesFontSize',14)


% a simple 1D example
x = [1 2 3 4 5 6 7 8 9 10]; % samples
w = [1 1 6 1 3 1 9 1 0 1];  % weights
w = w./sum(w);              % normalize weights
fid = figure(1);  clf;
% request for 100 new samples and graphical visualization
[x_new,freq] = importance_sampling( x, w, 100, 1, fid, SAVE_VISUALISATION );
pos=get(fid,'Position');
set(fid,'Position',[0,0,1.1*pos(3:4)]);
print('-depsc','-cmyk',[out_dir,'impsamp_explanation.eps']) 

if SAVE_VISUALISATION
  figure(2),
  bar(w);
  xlabel('x variable')
  ylabel('relative frequency')
  print('-depsc','-cmyk',['impsamp_inputdensity.eps']) 
  figure(3),
  bar(freq);
  xlabel('x_{new} variable')
  ylabel('frequency')
  print('-depsc','-cmyk',['impsamp_outputdensity.eps']) 
end

% repeated sampling shows a convergence process
if REPEATED_RESAMPLING
  % First, create uniformly distributed samples. 
  N = 100;
  x = rand(1,N);

  xrange = [0,1];
  yrange = [0,14];
  xwhere = [0:0.05:1];

  figure(100),
  hist(x,xwhere);
  set(gca,'Xlim',xrange);
  set(gca,'Ylim',yrange);
  xlabel('sample position')
  ylabel('frequency')
  title('histogram of the data before resampling')
  %print('-depsc',[out_dir,'impsamp_historig.eps'])
  print('-depsc2','-cmyk',[out_dir,'impsamp_historig.eps'])

  % For clarity, show only one resample step.
  % Play with iterations to see how the process converges.
  for i=1:10,
    % The weights follow a normal distribution
    w = normpdf(x,1/4,0.2);
    w = w./sum(w);  
    figure(10), clf
    stem(x,w)
    set(gca,'Xlim',xrange)
    xlabel('sample position')
    ylabel('sample weight (probability)')
    title('samples weights (probability)')
    %print('-depsc',[out_dir,'impsamp_weights.eps'])
    print('-depsc2','-cmyk',[out_dir,'impsamp_weights.eps'])
    x_old = x;
    % Resample the data by using importance sampling.
    [x,freq] = importance_sampling(x,w);
    figure(1), clf
    hist(x,xwhere);
    set(gca,'Ylim',yrange);
    set(gca,'Xlim',xrange)
    xlabel('sample position')   
    ylabel('frequency')
    title('histogram of the data after resampling')
    %print('-depsc',[out_dir,'impsamp_histresampled.eps'])
    print('-depsc2','-cmyk',[out_dir,'impsamp_histresampled.eps'])
    % show the frequency
    figure(30),clf
    stem(x_old,freq)
    set(gca,'Xlim',xrange)
    xlabel('sample position')
    ylabel('#-times selected into new set')
    title('frequency of the selection')
    %print('-depsc',[out_dir,'impsamp_selectionfreq.eps'])
    print('-depsc2','-cmyk',[out_dir,'impsamp_selectionfreq.eps'])
    % noisify
    % x = x + 0.01*randn(1,N);
  end
end




