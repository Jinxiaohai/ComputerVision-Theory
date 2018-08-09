function [error_rate,idx_error,match_table] = class_results(y, data, datadesc)
% CLASS_RESULTS analyse classification results and optionally visualise them
%
% [error_rate,idx_error] = class_results(y, data, datadesc, {fh=0})
% 
% Input parameters:
%   y        - [1 x num_vectors] class labels, result of the classification
%   data     - structure containing the data were classified
%    .X      - [N x num_vectors] feature vectors
%    .y      - [1 x num_vectors] true class labels; if no error y==data.y
%   datadesc - string describing the data, could be a filename
% 
% Output parameters:
%   error_rate  - error rate
%   idx_error   - [3 x num_errors] [index; true class label; wrong class label]
%                 it is used in the graphical visualisation a could be 
%                 useful in futher analysis
%   match_table - [num_class x num_class]
%                 How to interpret the table
%                 assume class_labels [1,num_class]
%                 class with class_labels(i) hass benn match_table(i,j) classified
%                 as class_labels(j). Naturally, for perfect classification, 
%                 the matrix will be diagonal. 
%
% See also: visualise_results, etalon_class, linclass

% History:
% 2006-11-29  Tomas Svoboda: created
% 2006-12-01  Tomas Svoboda: functionality splitted with visualise_results

if nargin<4
  fh = 0; % no visualisation be default
end

% find the positions where the classification
% does not match the true labels
idx = find(y~=data.y);

% [index; true class label; wrong class label]
% can be used for futher analysis of the classifier
idx_error = [idx;data.y(idx);y(idx)];

% percentage of errors
error_rate = length(idx)/length(y);

% print the results to the stdout
disp(sprintf('classification_result on %s data: %d out of %d missclassified',datadesc,size(idx_error,2),length(y)))



labels = unique(data.y);
num_classes = length(labels);
match_table = zeros(num_classes,num_classes);

for i=1:num_classes,
  idx_class = find(data.y==labels(i));
  for j=1:num_classes,
	idx = find(y(idx_class)==j);
	match_table(i,j) = length(idx);
  end
end

return;