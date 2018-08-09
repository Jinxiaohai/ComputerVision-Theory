% DFT2D_DEMO demonstration of 2D Discrete Fourier Transform
% CMP Vision Algorithms, http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007-07


clear all;

set(0,'DefaultAxesFontSize',14)
addpath ../.
cmpviapath('../.');
% create a directory for output images
% if needed and does not already exist
out_dir = 'output_images/'
if (exist(out_dir)~=7)
  mkdir(out_dir);
end

% We make use of 3 different input images. The first two are
% artificially created of intentionally low resolution
% for easy study. The third one, a real image, 
% reveals how the 2D DFT can be used to analyze image structure
% and it is particularly interesting when reconstructing from 
% a limited number of frequencies. First create the artificial data:
xrange = 0:39; 
yrange = 0:29;
[x,y] = meshgrid(xrange,yrange);
M = size(x,2); N = size(y,1);

freq.signal.x = 3; % frequency in x-direction
freq.signal.y = 5; % frequency in y-direction
omega.signal.x = 2*pi*freq.signal.x/M; % angular frequency for x
omega.signal.y = 2*pi*freq.signal.y/N; % angular frequency for y

freq.noise.x = 15;
freq.noise.y = 10;
omega.noise.x = 2*pi*freq.noise.x/M; % angular frequency for x
omega.noise.y = 2*pi*freq.noise.y/N; % angular frequency for y


% The first image is a linear combination of two harmonic waves of different
% frequency. 

% carrier signal
data(1).f = cos( omega.signal.x*x ) + cos( omega.signal.y*y );
% superpose harmonic noise 
data(1).f = data(1).f + 0.1*cos(omega.noise.x*x) + 0.1*cos(omega.noise.y*y);
data(1).f = data(1).f + 1; % make the mean value non zero
data(1).desc = 'coscos';


%
% The second image is a harmonic wave with particular orientation
% defined by the ratio between omega.signal.y and omega.signal.x.
data(2).f = cos( omega.signal.x*x + omega.signal.y*y ); % carrier signal
data(2).f = data(2).f + 0.1*randn( size(data(1).f) );   % perturb by random noise
data(2).desc = 'slantedcos';

% The real snapshot contains noticeable linear structures.
data(3).f = imread('images/glassblocks.png');
data(3).desc = 'glassblocks';

for i=1:length(data),
  [N,M] = size(data(i).f);
  xrange = 0:M-1;
  yrange = 0:N-1;
  f = data(i).f;
  figure(i*10+1), clf
  imagesc(f,'Xdata',xrange([1,end]),'Ydata',yrange([1,end]))
  axis image
  xlabel('x'), ylabel('y');
  colormap(gray(256));
  title('Original Image')
  exportfig(gcf,[out_dir,'dft2d_',data(i).desc,'_image.eps'])

  F = fft2(f);
  figure(i*10+2), clf
  imagesc(log(abs(F).^2+1),'Xdata',xrange([1,end]),'Ydata',yrange([1,end]))
  xlabel('u'), ylabel('v');
  negmap = repmat([255:-1:0]'/255,1,3);
  colormap(negmap);
  grid on;
  axis image
  title('log of Fourier spectrum')
  exportfig(gcf,[out_dir,'dft2d_',data(i).desc,'_dft.eps'])

  figure(i*10+3), clf
  xaxis = [-xrange(floor(M/2)+1) xrange(round(M/2))];
  yaxis = [-yrange(floor(N/2)+1) yrange(round(N/2))];
  % imagesc(log(abs(fftshift(F))+1),'Xdata',xaxis,'Ydata',yaxis)
  imagesc(log(abs(fftshift(F)).^2+1),'Xdata',xaxis,'Ydata',yaxis)
  negmap = repmat([255:-1:0]'/255,1,3);
  colormap(negmap);
  grid on;
  axis image
  % change the ticklabels accordingly
  t = str2num(get(gca,'XTickLabel'));
  t(t<0) = M+t(t<0);  set(gca,'XTickLabel',t);
  t = str2num(get(gca,'YTickLabel'));
  t(t<0) = N+t(t<0);  set(gca,'YTickLabel',t);
  xlabel('u'),  ylabel('v'),
  title('log of shifted Fourier spectrum')
  exportfig(gcf,[out_dir,'dft2d_',data(i).desc,'_dftshifted.eps'])
end

for i=1:length(data)
  [N,M] = size(data(i).f);
  xrange = 0:M-1;
  yrange = 0:N-1;
  xaxis = [-xrange(floor(M/2)+1) xrange(round(M/2))];
  yaxis = [-yrange(floor(N/2)+1) yrange(round(N/2))];
  D = rc2d([N,M],'euclidean');
  F_shifted = fftshift(fft2(data(i).f));
  radii = linspace(1,max(M,N)/2,25);
  idxsave = [2,5,10,25];
  for j=1:length(radii)
    r = radii(j);
    mask = zeros(N,M);
    mask(D<r)=1;
    Fo_shifted = F_shifted.*mask;
    fo = real(ifft2(fftshift(Fo_shifted)));
    figure(i*10+4),clf
    imagesc(fo,'Xdata',xrange([1,end]),'Ydata',yrange([1,end]))
    colormap(gray(256))
    xlabel('x'), ylabel('y');
    title(sprintf('Reconstructed image, r=%d',round(r)));
    axis image
    if any(idxsave==j)
      exportfig(gcf,[out_dir,'dft2d_',data(i).desc,sprintf('_image_rec_r%03d.eps',round(r))]);
    end
    figure(i*10+5), clf
    imagesc(log(abs(F_shifted).^2+1),'Xdata',xaxis,'Ydata',yaxis)
    xlabel('u'), ylabel('v');
    hold on
    rectangle('Position',[[0,0]-r,2*r,2*r],'Curvature',1,'LineWidth',3,'EdgeColor','y')
    rectangle('Position',[[0,0]-r,2*r,2*r],'Curvature',1,'LineWidth',1,'EdgeColor','b')
    plot(0,0,'b+','MarkerSize',15,'LineWidth',3)
    % colormap(jet(256))
    colormap(negmap)
    grid on;
    axis image
    t = str2num(get(gca,'XTickLabel'));
    t(t<0) = M+t(t<0);  set(gca,'XTickLabel',t);
    t = str2num(get(gca,'YTickLabel'));
    t(t<0) = N+t(t<0);  set(gca,'YTickLabel',t);
    xlabel('u'),  ylabel('v'),
    title(sprintf('log of shifted Fourier spectrum, r=%d',round(r)));
    if any(idxsave==j)
      exportfig(gcf,[out_dir,'dft2d_',data(i).desc,sprintf('_dft_shift_r%03d.eps',round(r))]);
    end
    pause(0.1)
  end
end


