function s_drift = drift_samples(S,conf)
%DRIFT_SAMPLES Drift samples according to the velocity of the motion model
%CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Drift samples according to the velocity of the motion model. S.v
% is the velocity - predicted difference between the current and new state.
%
% Usage: s_drift = drift_samples(S,conf)
%   S  Structure with samples and weights.
%   conf  Structure with configuration.
% Outputs:
%   s_drift  Drifted samples.
% 
%

% No motion model for this experiment
s_drift = S.s;
