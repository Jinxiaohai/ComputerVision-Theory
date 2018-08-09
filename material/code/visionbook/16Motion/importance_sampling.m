function [x_res,freq] = importance_sampling(x,p,varargin)
% IMPORTANCE_SAMPLING importance sampling
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
%
% Usage: [x_res,freq] = importance_sampling(x,p,Nnew,show,fid,save)
% Inputs:
%   x  [dim x N]  Matrix of N samples of dimension .
%   p  [1 x N]  Probabilities of samples.
%   Nnew  (default N)  Number of new samples.
%   show  (default 0)  If set to 1 the sampling steps are
%     graphically visualized. It works only for 1D data.
%   fid   (default gcf)  Figure handle for the graphical visualization.
%   save  (default 0)  Save the graphically visualized steps to disk. 
% Outputs:
%   x_res  [dim x Nnew]  Selected (sampled) samples from x.
%   freq  [1 x N]  Frequencies of selections, giving the number of
%     times a particular sample from x was selected.


try Nnew = varargin{1}; catch Nnew = length(x); end
try SHOW = varargin{2}; catch SHOW = 0; end
try fid = varargin{3}; catch fid = gcf; end
try SAVE_FIGS = varargin{4}; catch SAVE_FIGS = 0; end

cum_prob = cumsum(p);             % cumulative probability
x_res = zeros( size(x,1), Nnew ); % space for resampled samples
freq = zeros( size(x) );          % selection frequency of the old samples
if SHOW
  figure(fid), clf
  plot(x,cum_prob,'o-','LineWidth',3,'MarkerFaceColor','w','MarkerSize',10,'MarkerEdgeColor','b')
  axis([x(1) x(end) 0 cum_prob(end)])
  % plot(x,cum_prob,'*-','LineWidth',2)
  title('Cumulative distribution function');
  xlabel('x - data samples')
  ylabel('randomly generated uniform values');
  hold on
end
for i = 1:Nnew
  % selection sample from a uniform density 0...1
  r = rand;
  j = find( cum_prob==min(cum_prob(cum_prob>r)), 1 );
  % take the j-sample to the new sample set
  x_res(:,i) = x(:,j);
  % increment the frequency table
  freq(j) = freq(j) + 1;
  %)
  if SHOW
    line([x(1) x(j)],[r r],'Color','k','LineWidth',0.5)
    line([x(j) x(j)],[cum_prob(j),0],'Color','k','LineWidth',freq(j)*20/Nnew)
    pause(1/25)
    for f=1:length(freq)
      text(x(f),0.04,sprintf('%d',freq(f)),'Color','k','BackgroundColor','w','FontSize',14,'EdgeColor','k')
    end
    if SAVE_FIGS
      % print('-djpeg', '-r96', sprintf('impsampl_%03d',i))
      print('-depsc', sprintf('impsampl_%03d.eps',i))
    end
  end
  %(  
end
if SHOW
  plot(x,cum_prob,'o-','LineWidth',3,'MarkerFaceColor','w','MarkerSize',10,'MarkerEdgeColor','b')
  for i=1:length(freq)
    text(x(i),0.04,sprintf('%d',freq(i)),'Color','k','BackgroundColor','w','FontSize',14,'EdgeColor','k')
  end
end


return; % end of importance_sampling

