% OCR_DEMO demonstration of optical character recognition
% CMPvia CMP Vision Algorithms, http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007

% $Id: ocr_demo_decor.m 1074 2007-08-14 09:45:42Z kybic $


clear all;

%
addpath ./data
addpath ../.
cmpviapath('../.',1);
% if necessary, create a directory for output images
out_dir = './output_images/';
if exist(out_dir)~=7
  mkdir(out_dir)
end 

methods = {'kNN','exemplar','perceptron'};
method = methods{3} % 1-kNN, 2->exemplar, 3->perceptron 
                    % kNN means k-nearest neighbor (nejblizsi soused)


% load the data
%   data - structure with data
%    .X  - [N x num_vectors]
%    .y  - [1 x num_vectors] class labels
trn_data = load('ocr_trn_data');   % training set
tst_data = load('ocr_tst_data');   % test set 

%%
if 0	% change to 1 if you want to see the data
  fh = figure;
  fh = showdata(trn_data,fh);
  fh = showdata(tst_data,fh);
end


%
switch method
 case 'kNN'
  model = knnrule(trn_data,1);
 case 'exemplar'
  model = exeplar_learn(trn_data,'mean');
  for i=1:size(model.W,2)
    figure(10+i-1),clf
    imshow(reshape(model.W(:,i), 13,13), 'InitialMagnification',800);
    title(sprintf('exemplar for %d', i-1))
    exportfig(gcf,[out_dir,sprintf('exeplar_mean_%d.eps',i-1)]);
  end
 case 'perceptron'
  disp('Learning perceptron, please wait ...');
  model = mperceptron(trn_data);
  disp('...perceptron learned')
  for i=1:size(model.W,2)
    figure(10+i-1),clf
    imshow(reshape(model.W(:,i), 13,13), [],'InitialMagnification',800);
    title(sprintf('exemplar for %d', i-1))
    exportfig(gcf,[out_dir,sprintf('exemplar_perceptron_%d.eps',i-1)]);
  end
 otherwise 
  error('Unknown method')
end



data4class = tst_data; 
datadesc = 'test set';

%
switch method
 case 'kNN'
  labels = knnclass(data4class.X,model);
 case 'exemplar'
  labels = linclass(data4class.X,model);
 case 'perceptron'
  [labels,dfce] = linclass(data4class.X,model);
 otherwise 
  error('Unknown method')
end

%
% general purpose analysis of the classification results
% and its graphical visualization it should work for any classifier
[error_rate,idx_error,match_table] = class_results(labels,data4class,datadesc);
fh = figure;
show_missclassified_images = 0; % change to 1 if you want to see the wrongly classified patterns
fh_last = visualise_results(idx_error,match_table,data4class,datadesc,fh,show_missclassified_images);
exportfig(fh_last,[out_dir, sprintf('ocr_results_%s',method)]);


