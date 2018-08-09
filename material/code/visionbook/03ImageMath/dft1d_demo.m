% DFT1D_DEMO demonstration of 1D Discrete Fourier Transform
% CMP Vision Algorithms, http://visionbook.felk.cvut.cz
%
% Tomas Svoboda, 2007-07-06, svoboda@cmp.felk.cvut.cz

% History:
% $Id: dft1d_demo_decor.m 1074 2007-08-14 09:45:42Z kybic $
% 

clear all;
close all;

set(0,'DefaultAxesFontSize',14)

STEP_FN = 0;
COS_FN = ~STEP_FN;

addpath ../.
cmpviapath('../.');
% create a directory for output images
% if needed and does not already exist
out_dir = 'output_images/'
if (exist(out_dir)~=7)
  mkdir(out_dir);
end

% The main purpose of this section is to explain the
% principles of the Discrete Fourier Transform. We do not discuss
% the more efficient Fast Fourier Transform (FFT),
% which is widely available in many packages. However, the full 
% physical comprehension of the DFT is often undervalued. 

x = 0:59; % spatial positions (domain of the spatial function)
N = length( x );
if STEP_FN % step function
  step_pos = round(N/3); % position of the step
  f(1:step_pos) = 1;
  f(step_pos+1:N) = 0;
elseif COS_FN
freq_signal = 3;   % frequency
T = N/freq_signal; % period
omega = 2*pi/T;    % angular frequency
freq_noise = 20;   % frequency of the noise
omega_noise = 2*pi*freq_noise/N; 
f = cos(omega*x) + 0.5*sin(omega_noise*x); % mix the low and high frequency
f = f + 0.2*randn(size(x)); % perturb by some random noise 
f = f + 0.3; % shift, make the mean value non-zero
else
  error('unknown type of function')
end

axesvec = [x(1) x(end) (1-sign(min(f))*0.1)*min(f) (1+sign(max(f))*0.3)*max(f)]

figure(1), clf
pos = get(gcf,'Position')
set(gcf,'Position',[pos(1:3),0.7*pos(4)])
plot(x,f,'-k')
axis(axesvec)
hold on
plot(x,f,'o','MarkerFaceColor','w','MarkerEdgeColor','k')
grid on;
xlabel('x')
ylabel('f(x)')
title('spatial function')
exportfig(gcf,[out_dir,'dft1d_signal.eps'])

u = 0:N-1; % frequency domain
F = dft_edu( f, u );
figure(5), clf
pos = get(gcf,'Position')
set(gcf,'Position',[pos(1:3),0.7*pos(4)])
stem(u,abs(F));
hold on
xlabel('u')
ylabel('|F(u)|')
title('DFT, |F(u)|')
grid on;
exportfig(gcf,[out_dir,'dft1d_dft.eps'])


% Displaying of the harmonic function with increasing frequency
%
figure(2),
pos = get(gcf,'Position');
set(gcf,'Position',[pos(1:2),pos(3),0.7*pos(4)])
% harmonic functions
for u=0:round(N/2) % spatial frequency
  figure(2),clf
  omega = 2*pi*u/N;
  T = 2*pi/omega;
  plot(x,cos(omega*x),'b')
  hold on
  plot(x,sin(omega*x),'k')
  axis(axesvec)
  line([N/2 N/2], axesvec(3:4),'Color','r','LineWidth',3)
  grid on
  legend('cos(\omega x)','sin(\omega x)')
  xlabel('x')
  title(['\omega = 2\pi u/N; ',sprintf('u = %2d',u)])
  if u==1
    exportfig(gcf,[out_dir,'dft1d_sincos.eps']);
  end
  pause(0.1)
end
set(gcf,'Position',pos)

savefreq = [freq_signal,freq_noise];
u_all = [0:N-1];
figure(3), clf
pos = get(gcf,'Position')
set(gcf,'Position',[pos(1:3),0.7*pos(4)])
for u=0:round(N/2),
  Fo = F; Fo(u+2:end-u) = 0;
  figure(5),
  u_used = u_all;
  u_used(u+2:end-u) = [];
  stem(u_used,abs(F(u_used+1)),'Color','red','LineWidth',2);
  legend('original','used')
  if any(u==savefreq)
    exportfig(gcf,[out_dir,sprintf('dft1d_dft_used_%02d',u)])
  end
  f_harm = idft_edu(Fo);
  figure(3),
  % plot(x,f,'-k')
  hold on
  plot(x,f,'-og','MarkerFaceColor','w','MarkerEdgeColor','g','LineWidth',1)
  h_fharm = plot(x,real(f_harm),'b','LineWidth',2);
  legend('original','reconstructed','Re\{F(u)\}cos(\omega x)','Im\{F(u)\}sin(\omega x)')
  set(gca,'Box','on')
  axis(axesvec)
  % plot(x,imag(f_harm),'r')
  % plot(x,abs(f_harm),'g')
  grid on;
  title(sprintf('used frequencies: 0 - %2d',u))
  xlabel('x'); ylabel('f(x)')
  if u==0
    F_re = real(F(u+1));
    F_im = imag(F(u+1));
  else
    F_re = real(F(u+1))+real(F(N+1-u));
    F_im = imag(F(u+1))-imag(F(N+1-u));
  end
  omega = 2*pi*u/N;
  plot(x,F_re*cos(omega*x),'k','LineWidth',0.5)
  plot(x,-F_im*sin(omega*x),'r','LineWidth',0.5)
  if any(u==savefreq)
    exportfig(gcf,[out_dir,sprintf('dft1d_idftused_%02d',u)])
  end
  pause(0.5)
  set(h_fharm,'Visible','off')
end
 

