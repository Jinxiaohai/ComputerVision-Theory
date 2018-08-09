function model=exemplar_learn(trn,exemplar_fcn)
% EXEMPLAR_LEARN learning class exemplars
% 
% model = exemplar_learn(dataname,{exemplar_fcn=mean})
% 
% Input parameters
%   trn        - structure with training data
%    .X        - [N x num_vectors]
%    .y        - [1 x num_vectors] true labels
%   exemplar_fcn - function for the exemplar computation
%                if not specified mean is used
%
% Output parameters
%   model    - structure containing learned parameters
%    .exemplar - [N x num_classes] exemplars
%    .y      - [1 x num_classes] exemplar class labels
%    .W      - [N x num_classes] parameters of a general linear classifier
%    .b      - [1 x num_classes] g_s(x) = W_s^T x + b_s
%    .fun    - 'linclass'
%
% See also: mean

% History:
% 2006-11-29  Tomas Svoboda: created
% 2006-12-01  Tomas Svoboda: change of the input parameters
% 2007-06-24  TS: general linear classifier parameters added
% 2007-08-06  TS: etalon -> exemplar 

% default function is the mean
if nargin<2,
  exemplar_fcn = 'mean';
end

% finds class labels
classes = unique(trn.y);

% allocate memory for the model 
model.exemplar = zeros(size(trn.X,1),length(classes));

for i=1:length(classes),
  idx = find(trn.y==classes(i));
  model.exemplar(:,i) = feval(exemplar_fcn, trn.X(:,idx),2);
  model.y(i) = classes(i);
  model.W(:,i) = model.exemplar(:,i); % exemplars
  model.b(i) = -1/2*model.exemplar(:,i)'*model.exemplar(:,i); % b-parameter
end
model.fun = 'linclass';

return
  
