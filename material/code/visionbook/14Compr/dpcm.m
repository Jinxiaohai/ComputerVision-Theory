function [a,diffs,quantfn,s,diffs_lossless] = dpcm(im,n,quantfn)
% DPCM Differential Pulse Code Modulation
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
% Usage: [a,diffs,quantfn,s,diffs_lossless] =  dpcm(im,n,quantfn)
% Inputs:
%   im  [m x 1]  Input data. Bit depth is assumed to be 8.
%   n  1x1  Order of the linear predictor.
%   quantfn  1x1 or [256 x 1]  Number of levels for Lloyd-Max optimal 
%     quantization or a user-specified quantization table.
% Outputs:
%   a  [n x 1]  Parameters of the linear predictor.
%   diffs  [m x 1]  Quantized prediction errors.
%   quantfn  [256 x 1]  Quantization table.
%   s  [levels+1 x 1]  Decision levels of the quantization table.
%   diffs_lossless  [m x 1]  Non-quantized prediction errors.

% History:
% $Id: dpcm_decor.m 1079 2007-08-14 11:11:21Z svoboda $
% 
% 2007-06-15: Tomas Svoboda created and decorated
% 2007-08-15: TS refinement for better looking of the m-file

im = double(im(:));
numpix = length(im);


% Parameters of the linear predictor a_k are estimated
% by a least squares solution, using function pinv. 
F = zeros( numpix-n, n );
for i = (n+1):numpix
  F(i-n,:) = im(i-1:-1:i-n);
end
% LSQ solution of over-constrained set of equations
a = pinv(F) * im(n+1:end);

% The quantization table is computed by Lloyd-Max optimal quantization by using
% the function lloydmax.
% If the quantization table is user-specified, zero mean is assumed.
if isscalar(quantfn)   % understood as Lloyd-Max quantization levels 
  [quantfn,s,mean_e,diffs_lossless] = lloydmax( a, im, quantfn );
else
  mean_e = 0;          % zero mean of prediction errors
  s = length(quantfn); % just auxiliary parameter for displaying
end
if nargout==5          % diffs_lossless requested, useful for demo
  diffs_lossless = diffcomp( a, im, [0:255]', 0 );
end

quantfn = quantfn(:);

% Compute the quantized prediction errors using diffcomp.
diffs = diffcomp( a, im, quantfn, mean_e );
return % end of the dpcm

function diffs = diffcomp(a,im,quantfn,mean_e)
% Usage: diffs = diffcomp(a,im,quantfn,mean_e)
% Inputs:
%   a  [n x 1]   Parameters of the linear predictor.
%   im  [m x 1]  Input data. Bit depth is assumed to be 8.
%   quantfn  [256 x 1]  Quantization table.
%   mean_e  1x1  Mean of the prediction error.
% Outputs:
%   diffs  [m x 1]  Quantized prediction errors.
n = length(a); % order of the predictor
diffs = zeros( size(im) );
% first n prediction erors
diffs(1:n) = sign(diffs(1:n)) .* quantfn(abs(diffs(1:n))+1);
p_im = zeros( size(im) );
% first n predicted values
p_im(1:n) = im(1:n);
for i=(n+1):length(diffs)
  % predicted value
  p_im(i) = round( sum(a.*(diffs(i-1:-1:i-n)+p_im(i-1:-1:i-n))) );
  % zero mean prediction error
  e = im(i) - p_im(i) - mean_e;
  % quantization by using lookup table
  diffs(i) = sign(e+eps) * quantfn(abs(e)+1);
end
return % end of diffcomp

function [quantfn,s,mean_e,diffs] = lloydmax(a,im,levels)
% Usage: [quantfn,s,lappdf_mean,diffs] = lloydmax(a,im,levels)
% Inputs:
%   a  [n x 1]   Parameters of the linear predictor.
%   im  [m x 1]  Input data. Bit depth is assumed to be 8.
%   levels  1x1  Number of quantization levels. Supported 
%               values [2, 4, 8].
% Outputs:
%   quantfn  [256 x 1]  Quantization table.
%   s  [levels+1 x 1]   Decision levels of the quantization table.
%   mean_e  1x1  Mean of the prediction error.
%   diffs  [m x 1]  Non-quantized prediction errors.

% First, compute non-quantized differences and estimate the parameters
% of the Laplacian distribution.
diffs = diffcomp(a,im,[0:255]',0);
lappdf_mean = median(diffs); % mean
lappdf_std = 1/length(diffs) * sum(abs(diffs-lappdf_mean)); % standard deviation

% Tabulated reconstruction levels of the Lloyd-Max quantization 
% for the Laplacian distribution of unit variance .
switch levels
 case 2, t=[0.707];
 case 4, t=[0.395 1.810];
 case 8, t=[0.222 0.785 1.576 2.994];
 otherwise error(sprintf('lloydmax: %d levels not supported'))
end
t = t'*lappdf_std; % de-normalized the tabulated values

% The decision levels are in the middle between neighboring the reconstruction levels.
s = zeros( size(t) );
for i=1:length(t)-1
  s(i+1) = (t(i)+t(i+1)) / 2;
end
s = round(s);

% The quantfn is a look-up table (LUT) for any positive
% prediction error up to 256.
s = [s; 256]; 
quantfn = zeros( 1, 256 );
for i=2:length(s)
  quantfn(s(i-1)+1:s(i)) = t(i-1);
end

% Round the values of the LUT and return the mean of the 
% error distribution.
quantfn = round(quantfn);
mean_e = lappdf_mean;
return % end of lloydmax

