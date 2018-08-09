function [w] = measurement(S,conf)
%MEASUREMENT Evaluation of the samples
%CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Usage: w = measurement(S,conf)
%  S  struct  Structure with samples and weights. 
%  conf  struct  Structure with configuration. 
%   .sigma_2  [1]  Standard deviation of the noise.
%  w  [1 x N] Vector with measurements for each sample. 
% Function measurement evaluates each sample according to a measurement
% function and returns a likelihood of each sample.
% The measurement function is modeled by a Gaussian centered around the 
% true value and a small constant is added to represent a non-zero
% response of a real measurement function.
% This is 
% an approximation of an ideal which should be smooth and
% peak at the true value. The non-zero observation likelihood further away from the true state
% also prevents samples from dying prematurely. 
% See demo2D/measurement for a more
% realistic measurement function.
%


w = normpdf((S.s-S.x),0,conf.sigma_2) + 0.1;
return
