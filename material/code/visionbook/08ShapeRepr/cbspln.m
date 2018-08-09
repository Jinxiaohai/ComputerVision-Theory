function y=cbspln(x)
% CBSPLN Evaluate one cubic B-spline
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Usage: y = cbspln(x) 
%
% Evaluate beta_3(x) for given x .
% Uses the fact that beta_3 is an even function and branches to
% evaluate the polynomial corresponding to the particular interval,
% factorized to minimize the operation count.

x = abs(x);
if x>2
  y = 0;
else
  if x>1
    y = (2-x)^3/6;
  else
    y = 2/3 - x^2*(1-x/2);
  end
end
