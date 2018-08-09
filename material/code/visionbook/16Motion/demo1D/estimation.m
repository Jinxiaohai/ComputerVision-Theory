function est = estimation(S,conf);
%ESTIMATION The best guess for the state of the system - estimated value
%CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Usage: est = estimation(S,conf)
%  S  struct  Structure with samples and weights. 
%  conf  struct  Structure with configuration. 
%  est  [dim x 1] Value of the predicted state. 
% Computes the best guess for the state of the system 
% as the weighted average of the samples 
% x = sum_i^N,
% which is implemented as a scalar product of vectors 
%  and s.
%

est = [S.pi]*[S.s]';
return % end of estimation
