function s_drift = drift_samples(S,conf)
%DRIFT_SAMPLES Drift samples according to the velocity of the motion model
%CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Usage: s_drift = drift_samples(S,conf)
%  S  struct  Structure with samples and weights. 
%  conf  struct  Structure with configuration. 
%  s_drift  [dim x N] Drifted samples. 
% Drift samples according to the velocity model. 
% This is a simple demonstration function.
% A more general predictor is naturally possible.
%

s_drift = S.s + S.v;
return

