function y=cbinterp(c,x)
% CBINTERP Cubic B-spline interpolation
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Usage: y = cbinterp(c,x)
%
% Given cubic B-spline coefficients c, calculate a value at point x.  
% Various if cases determine which basis functions are non-zero
% and contribute.

lenc = length(c);
xf = floor(x) - 1;

if xf>=1 & xf<=lenc
  y = c(xf) * cbspln(x-xf);
else
  y = 0;
end
if xf+1>=1 & xf+1<=lenc
  y = y + c(xf+1)*cbspln(x-xf-1);
end
if xf+2>=1 & xf+2<=lenc
  y = y + c(xf+2)*cbspln(x-xf-2);
end
if xf+3>=1 & xf+3<=lenc
  y = y + c(xf+3)*cbspln(x-xf-3);
end
