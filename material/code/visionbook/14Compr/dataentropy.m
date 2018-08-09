function [H,Hmax]=dataentropy(data,bins);
% DATAENTROPY estimates information entropy of the data
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
%
% Usage: [H,Hmax]=dataentropy(data,bins)
% Inputs:
% data  [N x 1]  Integer input data. 
% bins  (default data driven)  Positions of the bins. 
%                              By default it adapts to the data. 
% Outputs:
% H  1x1  Entropy. 
% H_max  (default 1x1)  Maximimal entropy of the data if they were 
%                       uniformly distributed. 
% See also: histc

% History
% $Id: dataentropy_decor.m 1079 2007-08-14 11:11:21Z svoboda $

data = double(data(:));

if nargin<2
  offset = 0-min(data);
  data = data+offset;   % shift the data
  maxval = max(data);
  bins = 0:maxval;      % bin for each element
end

% Estimate the probability density by using the histogram
p = histc(data,bins);

% To avoid log of zero.
p(p==0) = [];

p = p./numel(data);

H = -sum(p.*log2(p));

% maximum entropy in case of uniform probability distribution
if nargout>1
  Hmax = ceil(log2(maxval+1));
end

return
