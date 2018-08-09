function F = dft_edu(f,u)
% DFT_EDU educative implementation of the direct DFT
% CMP Vision Algorithms, http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007-07-06
% Usage: F = dft_edu(f,u)
% Inputs:
%   f  [1 x N]  Function in time or spatial domain.
%   u  (default 0:N-1)  Frequencies.
% Outputs:
%   F  [1 x N]  F(u) values.
% See also: idft_edu, fft.

% History:
% $Id: dft_edu_decor.m 1074 2007-08-14 09:45:42Z kybic $
%
% 2007-07-02 Tomas Svoboda (TS) created
% 2007-07-04 TS contact email changed
% 2007-08-09 TS refinements of comments for better look of m-files


N = length(f);
if nargin<2
  u = 0:N-1; % all frequencies by default
end

F = 0;
omega = 2*pi*u/N; % angular frequency
for x = 0:N-1     % spatial or time positions
  F = F + f(x+1)*( cos(omega*x)-i*sin(omega*x) ); % cumulative sum
end
F = F/N; % normalization

return  % end of dft_edu

