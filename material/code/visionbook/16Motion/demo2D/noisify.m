function s_noise = noisify(S,conf)
%NOISIFY Noisify the samples with normal noise
%CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Add noise to samples according to the Covariance matrix.
% 
% Usage: s_noise = noisify(S,conf)
% Inputs:
%   S  struct  Structure with samples and weights.
%   conf  struct  Structure with configuration.
% Outputs:
%   s_noise  [dim x conf.N]  vector with samples.
% 
%
% Based on:
% About: Statistical Pattern Recognition Toolbox
% (C) 1999-2003, Written by Vojtech Franc and Vaclav Hlavac
% <a href="http://www.cvut.cz">Czech Technical University Prague</a>
% <a href="http://www.feld.cvut.cz">Faculty of Electrical Engineering</a>
% <a href="http://cmp.felk.cvut.cz">Center for Machine Perception</a>

[dim N] = size(S.s); % get dimension
[U,L] = eig(conf.Cov); % compute eigen values and vectors
s_noise = S.s + inv(U')*sqrt(L)*randn(dim,N); % dewhitening transform
