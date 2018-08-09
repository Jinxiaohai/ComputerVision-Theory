function c=cbanal(y)
% CBANAL Calculates cubic B-spline coefficients
% Usage: c = cbanal(y)
%
% Given values [y(1), y(2), ..., y(N)], find coefficients c_i
% such that 
% the interpolation equation is satisfied.  
% We form and solve a set of linear equations, which is simple and exact
% but might be slow for large N. The magic values [1/6, 2/3, 1/6] are
% the values of beta_3 at integers
% [beta_3(-1), beta_3(0), beta_3(1)].

N = length(y);
A = zeros(N);
y = y(:);

if N==1
  c = 1.5*y;
else
  A(1,1:2) = [2/3 1/6];
  A(N,N-1:N) = [1/6 2/3];
  for i = 2:N-1
    A(i,i-1:i+1) = [1/6 2/3 1/6];
  end
  c = A\y;  c = c';
end
