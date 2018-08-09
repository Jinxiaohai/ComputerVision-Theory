function f = ifft_edu(F,x)
% IDFT_EDU educative implementation of the inverse DFT
% CMP Vision Algorithms, http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007-07
% Function idft_edu is an implementation of the inverse 
% Discrete Fourier Transform. The emphasis is on the fact that 
% the spatial function is composed as a linear combination of 
% harmonic functions of different frequency and amplitude. 
% Usage: f = ifft_edu(F,x)
% Inputs:
%   F  [1 x N]  Coefficients of the DFT.
%   x  (default [0:N-1])  Spatial positions.
% Outputs:
%   f  [1 x N]  Spatial function on the domain defined by x.
% See also: dft_edu, ifft.

% History
% $Id: idft_edu_decor.m 1074 2007-08-14 09:45:42Z kybic $

N = length(F);
if nargin<2
  x = 0:N-1;   % all positions by default
end

f = 0;
for u = 0:N-1  % all frequencies
  omega = 2*pi*u/N; % angular frequency
  f = f + real(F(u+1))*cos(omega*x) - imag(F(u+1))*sin(omega*x); % cumulative sum
end

return % end of idft_edu

