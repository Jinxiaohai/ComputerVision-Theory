function q = init_model(conf);
% INIT_MODEL Initialize probability model for the Kernel-based tracking
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Petr Lhotsky, Tomas Svoboda, 2007
% 
% Usage: S = init_model(S,conf)
%
% {
%  conf  structure with the configuration
%   .h  size of the Epanechnikov kernel 
%   .img_x  size of the input image S.img, x coordinate 
%   .img_y  size of the input image S.img, y coordinate 
%   .table  lookup table for fast histogram computation 
%   .bins  number of histogram bins 
%  q  [1 x conf.bins] probabilities vector 

xl = -conf.h; xh = conf.h; nxw = xh-xl+1;
yl = -conf.h; yh = conf.h; nyw = yh-yl+1;
nw=nxw*nyw; 
iw=(0:(nw-1))';
Coord = [floor(iw/nyw+xl) mod(iw,nyw)+yl];  % Coordinates
Dist = sum(((Coord/conf.h).^2),2);          % Distance
idx = Dist<1;                               % Where distance is less than 1
Dist = Dist(idx);
Kern = epanech_kernel(Dist);                % Kernel weights
Hist = reshape(conf.model,[],1);
Hist = Hist(idx);
Hist = conf.table(Hist+1);                  % Histogram
q = zeros(1,conf.bins);
for u = 1:conf.bins
    q(u) = sum(Kern(Hist == u));
end
q = q / sum(Kern); % Normalize

return; % end of init_model