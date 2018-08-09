function D = rc2d(imsize,metrics)
% rc2d computes distance matrix of given size
% CMP Vision Algorithms, http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
%
% D = rc2d(imsize,metrics)
% Inputs: 
% imsize [2 x 1] [number_of_rows x number_of_columns]
% metrics string possible options 'euclidean','cityblock','chessboard'
% Outputs:
% D [imsize] distance matrix
%
% See also: bwdist, rc2d_demo

r = imsize(1);
c = imsize(2);

x = [0:c-1];
y = [0:r-1];

idx = find(x>=c/2);
x(idx) = x(idx)-c;

idx = find(y>=r/2);
y(idx) = y(idx)-r;

X = fftshift(repmat(x,r,1));
Y = fftshift(repmat(y',1,c));

switch lower(metrics)
 case 'euclidean'
  D = sqrt(X.^2+Y.^2);
 case 'cityblock'
  D = abs(X) + abs(Y);
 case 'chessboard'
  D = max(abs(X),abs(Y));
end
  

return;
