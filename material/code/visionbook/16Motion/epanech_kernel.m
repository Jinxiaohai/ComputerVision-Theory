function k = epanech_kernel(x)
% epanech_kernel Compute the weight of the Epanechnikov kernel for vector x
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Petr Lhotsky, Tomas Svoboda, 2007

% History:
% $Id: epanech_kernel.m 1086 2007-08-14 13:41:41Z svoboda $

k = 2/pi*(1-x.^2);

k(abs(x) > 1) = 0;