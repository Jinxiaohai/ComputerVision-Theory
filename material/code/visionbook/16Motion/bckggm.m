function [model,idx,res] = bckggm(im,model,idx,cfg)
% BCKGGM Adaptive background modeling by using a mixture of Gaussians
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
% 
% This function computes a one-frame update
% of the background model and performs motion detection; it is an
% implementation of . Each pixel is modeled by
% a weighted mixture of Gaussians whose parameters and weights are
% continuously updated throughout the image sequence.
% 
% Usage: [model,idx,res] = bckggm(im,model,idx,cfg)
% Inputs:
%   im  [r x c]  Input image. This is one frame from a video sequence.
%   model  [r x c x K x n]  Multidimensional array containing all
%     statistics about pixels. If model is empty it is
%     initialized, see model_init for details.
%   idx  struct  Structure containing indexes (pointers) to
%     model. See the sub-function model_init
%     for details. Currently, four index groups are
%     used - idx.mu indexes means, idx.vars
%     variances, idx.w weights, and idx.bckg
%     background flags. For example, model(i, j, 1, idx.mu) is
%     a vector of means of Gaussian  1 for the pixel at
%     position i, j. The equality
%     model(i, j, 1, idx.bckg)==1 means that Gaussian  1
%     represents the background.
%   cfg  struct  Structure with configuration (init) information. 
%   .K      1x1  Number of Gaussians in the model, see model_init. 
%   .var    1x1  Initial variance, see model_init. 
%   .thr    1x1  Multiplicative coefficient that multiplies standard deviations
%                for thresholding differences, see findmatch. 
%   .alpha  1x1  Learning coefficient, see updatemodel. 
%   .T      1x1  Threshold decision about background/foreground, see findbckg.
% Outputs: 
%   model  [r x c x K x n]  Updated model of the background.
%   idx  struct  Structure containing indexes (pointers) to
%     model. The indexes are not changed throughout the
%     sequence: they are included among output parameters  for the
%     sake of consistency since bckggm also initializes the model.
%   res  struct  Structure containing results. res.segm
%     is the segmented image and res.bckg contains the
%     updated background image.

%
% Looping over all pixels in the image is 
% very slow. To make the code run acceptably fast we used the
% Matlab tool profile viewer and made some
% speed-ups at the cost of readability.
% The squeeze function just removes
% singleton dimensions; its frequent use slows
% down the code.
% Since we know which dimensions are equal to 1
% we can use the reshape function directly which is much 
% faster. The second speed up trick is 
% the replacement of repmat. Imagine we have a vector variable
% x of dimension n x 1 and we want to replicate it into a matrix
% xmat of size n x N, xmat=[x,x,x,...,x].
% The following two lines of code are equivalent:
% xmat = repmat( x, 1, N );
% xmat = x(:,ones(N,1));
% The latter is much 
% faster{This idea was found at
% http://www.psi.toronto.edu/ vincent/matlabindexrepmat.html.}.
% Despite these efforts, the Matlab implementation is still well beyond
% real-time, taking several seconds to process a modest 320 x 240 image.
% Fortunately, efficient background modeling can be performed on
% subsampled images, which also helps in reducing image noise (see
% the variable scaling in bckggm_demo). Pixels are inspected
% independently which allows for a multi-thread implementation which is particularly
% interesting, with prevailing multi-core CPUs. Also the creation of the
% background image is not necessary for the segmentation, it just
% eases debugging and
% analysis of the algorithm behavior. In time critical operations the relevant 
% part of the code can be entirely commented out.
% 


im = double(im);

% If there is no model, initialize it. See model_init.
if isempty(model)
  [model,idx] = model_init( im, cfg );
end

% Memory allocation for the results
res.segm = zeros( [size(im,1),size(im,2)], 'uint8' );
res.bckg = zeros( size(im) );
layers = size( im, 3 );

% Inspect each pixel and update its background model
for i = 1:size(im,1)
  for j = 1:size(im,2)
% Prepare the data.
% x is a vector containing layer values, for an RGB image thus x=[r,g,b].
% m
% is a matrix that contains all the background model for the inspected pixel, 
  % replacement for the the very slow x = squeeze( im(i,j,:) );
  x = reshape( im(i,j,:), layers, 1 );
  % The following two lines replace the very slow m = squeeze( model(i,j,:,:) );
  siz = size( model(i,j,:,:) );
  m = reshape( model(i,j,:,:), siz(3), siz(4) );
  weights = m(:,idx.w);
% Find the Gaussian that matches, see findmatch.
  [idxmatch,no_match] = findmatch( x, m, idx, cfg );
% Initialize a new Gaussian if no match is found. The newgauss function
% finds the Gaussian with minimal weight and replaces it by a new one.
  if no_match
    m = newgauss( x', m, idx, cfg );
% If a match is found then decrease the weights of non-matching Gaussians
% and re-normalize. Then update the model, see updatemodel.
  else
    % update weights
    % idx2update = find( [1:length(weights)]~=idxmatch );
    idx2update = ~idxmatch;
    weights(idx2update) = (1-cfg.alpha) * weights(idx2update);
    % renormalization
    weights = weights ./ sum(weights);
    m(:,idx.w) = weights;
    % update model
    m(idxmatch,:) = updatemodel( m(idxmatch,:), x', idx, cfg );
  end
% After the update of the model we have to decide which Gaussians
% represent the background. It is important to note that the background
% may change due to lighting changes, object movement, etc. The set of 
% `background' Gaussians have to change accordingly.
  idxbck = findbckg( m, idx, cfg );
  m(:,idx.bckg) = 0;        % clear the labels
  m(idxbck,idx.bckg) = 1;   % label '1' means background
% Compose the background image. This part is actually not necessary for
% the segmentation. However, it is convenient to see how the background
% evolves over time: this composition can be moved outside the bckggm
% function. The background image is computed as a weighted average of the mean
% values of the Gaussian.
  if isscalar(idxbck)
    res.bckg(i,j,:) = m(idxbck,idx.mu);
  else % weighted average 
    w_rel = m(idxbck,idx.w); % related weights
    res.bckg(i,j,:) = sum(w_rel(:,ones(length(idx.mu),1)) .* ...
                      m(idxbck,idx.mu))/sum(m(idxbck,idx.w));
  end
    % res.bckg(i,j,:) = sum( repmat(m(idxbck,idx.w),1,length(idx.mu)) ...
    %                          .*m(idxbck,idx.mu) )./sum(m(idxbck,idx.w));
% The pixel is labeled as foreground if there was no match at all 
% or the matched Gaussian(s) does not belong to the background.
  if sum(idxmatch)==0 | ~any(idxbck==find(idxmatch))
    res.segm(i,j) = 1;
  end
% Put the updated model matrix back in the data structure.
  model(i,j,:,:) = m;
  end % for j
end % for i

res.segm = logical(res.segm);

function [model,idx] = model_init(im,cfg)
% Usage: [model,idx] = model_init(im,cfg)
% Function model_init initializes the Gaussians by using the 
% current observation and the predefined values stored in cfg.

r = size(im,1); % image height
c = size(im,2); % image width
b = size(im,3); % layers (3 for RGB, 2 for RG, 1 for intensity image)

% Initial parameters. The means are approximately uniformly
% distributed along the diagonal of the feature space. Initial
% variance is taken from cfg.var and the weights are set equally.
shift = cfg.thr * sqrt(cfg.var);
initmu = linspace( 0+shift, 200-shift, cfg.K-1 )';
initvars = cfg.var * ones(cfg.K-1,1);
initw = 1/cfg.K;

% Symbolic names for the indexes improve the readability of the code.
idx.mu = 1:b;       % means
idx.vars = b+1;     % variances
idx.w = idx.vars+1; % weights
idx.bckg = idx.w+1; % background flags

% Memory allocation for the complete model
model = zeros( r, c, cfg.K, idx.bckg );

% Matrix of initial parameters that is added to each pixel beside
% the current value
initpars = ...
  [initmu(:,ones(b,1)) initvars initw(ones(1,cfg.K-1),:) zeros(cfg.K-1,1)];

% For each pixel in the image take the current observation as initialization 
% of the  and assign initial values to the rest of the Gaussians
for i = 1:r
  for j = 1:c
    model(i,j,:,:) = [squeeze(im(i,j,:))' cfg.var initw 1; initpars];
  end
end
return; % end of bckggm

function [idxmatch,no_match] = findmatch(x,model,idx,cfg)
% Usage: [idxmatch,no_match] = findmatch(x,model,idx,cfg)
% findmatch compares the actual observation x
% with all Gaussians and selects the one that matches. If no match is
% found, an empty array is returned.
% 
% Absolute distances between the means and the current observation. 
d = abs(model(:,idx.mu)' - x(:,ones(cfg.K,1)));
% Thresholding: Absolute distance in each channel (layer) is compared to
% cfg.thr-multiple of sigma-s. Only those Gaussians
% where distances in  layers are smaller than thresholds
% are accepted.
no_match = 0;
stds = sqrt( model(:,idx.vars) )';
thr_mat = cfg.thr * stds( ones(length(idx.mu),1), : );
id = find( all(d<thr_mat) );

% It can happen that several Gaussians match, and several possible strategies
% for selecting the `best' exist. Here one can select between two:
% either the one with minimal variance or the closest. Depending on time
% constraints, more advanced metrics such as Mahalanobis distance can be
% chosen.
if length(id)>1
  [minvar,idmin] = min( model(id,idx.vars) ); % minimal variance
  % [mind,idmin] = min( sum(d(:,id)) );       % closest 
  id = id(idmin);
elseif isempty(id)
  no_match = 1;
end
idxmatch(1:cfg.K) = logical(0);
idxmatch(id) = 1;
return; % end of find match

function m = newgauss(x,m,idx,cfg)
% Usage: m = newgauss(x,m,idx,cfg)
% newgauss replaces the Gaussian with 
% the lowest weight by a new one. The current observation
% initializes the mean. The variance of the new Gaussian
% is computed as double that of the largest among the remaining
% Gaussians. The weight is the minimal one, and the weights 
% are re-normalized.
% 
[minw,idmin] = min(m(:,idx.w));           % minimal weight
m(idmin,idx.mu) = x;                      % assign new observation
m(idmin,idx.vars) = 2*max(m(:,idx.vars)); % twice the highest variance
m(idmin,idx.w) = minw;                    % take the minimal weight
m(:,idx.w) = m(:,idx.w)/sum(m(:,idx.w));  % re-normalize wights
return; % end of newgauss


function m = updatemodel(m,x,idx,cfg)
% Usage: m = updatemodel(m,x,idx,cfg)
% First weight the learning constant by the `credibility' of the
% observation x. Clearly, the further the observation is from the 
% mean of the Gaussian the less influence it should have on the update.
% The probability is computed in a simplified way: the covariance
% matrix is assumed to be diagonal and all variances equal. It suffices
% to compute probability in one dimension. We skip the normalization
% of the probability value
% in order to be equal to 1 if x matches . 
% This speed-up learning trick is questionable.
% The probability value for the exact match is naturally lower for
% higher variance. This lower weighting of `flat' densities may be
% useful in some applications.
ro = cfg.alpha * exp( -0.5*(x(1)-m(idx.mu(1)))./sqrt(m(idx.vars)).^2 ); 
% update mean
m(idx.mu) = (1-ro)*m(idx.mu) + ro*x;
% update variances
m(idx.vars) = (1-ro)*m(idx.vars) + ro*sum((m(:,idx.mu)-x).^2);
return % end of updatemodel



function idxbck = findbckg(m,idx,cfg)
% Usage: idxbck = findbckg(m,idx,cfg)
% This selects the Gaussians that most probable represent background.
% The underlying idea is twofold: The background Gaussians presumably have 
% high weights which correspond to frequent observation, and
% low variances. The assumption is that we assume the total frequency
% of background is higher than cfg.T.
%
% First, sort Gaussians according to omega/sigma^2, best first.
sortcr = m(:,idx.w) ./ m(:,idx.vars);
[foo,idxsort] = sort( sortcr );
idxsort = idxsort(end:-1:1);
% Find the minimum number of sorted Gaussians whose sum
% exceeds the threshold cfg.T
idxbck = find( cumsum(m(idxsort,idx.w))>cfg.T );
B = idxbck(1);
idxbck = idxsort(1:B);
if isempty(idxbck)
  [foo,idxbck] = max( m(:,idx.w) );
end
return % end of findbckg

