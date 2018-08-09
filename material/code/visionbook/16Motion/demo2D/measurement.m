function w = measurement(S,conf)
%MEASUREMENT Evaluation of the samples
%CMP Vision Algorithms http://visionbook.felk.cvut.cz
%Petr Lhotsky, Tomas Svoboda
% 
% Usage: w = measurement(S,conf)
%  S  struct  Structure with samples and weights; 
%      see particle_filtering
%      for explanation of the structure. 
%  conf  struct  Structure with configuration. 
%  w  [1 x N]  Vector with evaluations. 
% An example measurement function for 2D blob 
% tracking. 
% 
%

[img_x, img_y, dim] = size(S.img);
w = zeros(1,conf.N);

for i = 1:conf.N % for each sample
  x = round(S.s(1,i));
  y = round(S.s(2,i));
  % select a rectangular image area around the sample position
  x_low = max( [(x-conf.area) 1] );
  x_hi  = min( [(x+conf.area) img_x] );
  y_low = max( [(y-conf.area) 1] );
  y_hi  = min( [(y+conf.area) img_y] );
  % check if the area is in the image
  if x_low<x_hi && y_low<y_hi && ...
     x_hi-x_low==2*conf.area && y_hi-y_low==2*conf.area
    area = double( S.img(x_low:x_hi,y_low:y_hi) );
    % compute weighted sum of absolute differences
    diff =  abs(conf.model-area) .* conf.mask;
% The higher the sum of absolute differences (SAD) the worse the match. 
% For the evaluation we need the opposite: the better the match 
% the higher value of the weight. We subtract the sum from
% 255 which is the highest intensity value:
% 1/SAD is also possible, which has a much sharper peak around the 
% best match. The sharpness may be regularized by adding a higher
% value than eps.
    % w(i) = 1/(sum(sum(diff))+eps);
    w(i) = 255-sum(sum(diff));
  else
  % if outside image assign some low value
    w(i) = 0.001;
  end
end
return % of the measurement 2D
