function S = particle_filtering(S,conf)
% PARTICLE_FILTERING Particle filtering (Condensation)
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Petr Lhotsky, Tomas Svoboda, 2007
%
% Usage: S = particle_filtering(S,conf)
% Inputs:
%   S  struct  Structure with samples and weights. 
%   .x [dim x 1]  State of the system. This represent the true
%     state of the system. It is used for demonstration purposes
%     only. It is normally unknown. dim denotes dimensionality of
%     the state space.
%   .s    [dim x N]  Matrix containing N samples (particles).
%   .pi   [1 x N]    Weights of the samples.
%   .v    [dim x 1]  Predicted velocity - motion model.
%   .est  [dim x 1]  Estimated value - estimated state of the observed system.
%   conf  struct     Structure with configuration.
%   .N    1x1        Number of samples.
%   .Cov  [dim x dim]Noise covariance matrix.
%   .alpha  1x1      Factor for the exponential forgetting of the
%     motion model; 
%     lower values put the accent on the history and 
%     higher values on the actual movement; 0 turns the motion model off.[-.75ex]
% Outputs:
%   S  struct  The same structure as for input, but at time step k+1.

% $Id: particle_filtering_decor.m 1086 2007-08-14 13:41:41Z svoboda $
% 
% History:
%
% 2007-02-8 Petr Lhotsky: created
% 2007-03-12 Petr Lhotsky: redesign of the structure
% 2007-03-30 Tomas Svoboda (TS): re-decoration
% 2007-04-30 TS: new decoration and some errors in the parameter
%            description fixed
% 2007-05-07 TS: importance sampling made a separate function+demo
% 2007-08-14 TS: refinement of better looking of m-file

% The filtering procedure consists of the following steps:
% Resample data S_ using importance sampling. The sampling
% procedure draws samples from the set such that samples with higher
% weights are likely to be picked more times. Since the total
% number of samples is preserved, some samples with lower weights might
% not be
% selected at all. Note that we are still using the states at time t-1.
% The importance sampling step is performed by
% function importance_sampling.
S.s = importance_sampling( S.s, S.pi );

% Predict the state for time t, and add noise.
% Prediction is here only a simple motion drift, see drift_samples.
% See function noisify for details of adding noise. 
S.s = drift_samples( S, conf );
S.s = noisify( S, conf );

% The correction (measurement) step evaluates the likelihood of how well the samples 
% This function depends on the application, see a simple
% measurement1D or a more realistic measurement2D.
S.pi = measurement( S, conf );

% normalize weights
S.pi = S.pi ./ sum(S.pi);

% Compute a pointwise state estimate from the samples. It is worth mentioning
% that the computation of the state estimate may be meaningless in
% some situations, especially for
% multimodal distributions.
S.est_old = S.est;
S.est = estimation( S, conf );

% Update the state velocity which is needed for the simple
% drift. Simple exponential forgetting is applied. The velocity
% does not need to be used in some applications.
S.v = conf.alpha*(S.est-S.est_old) + (1-conf.alpha)*S.v;


return; % end of particle filtering

