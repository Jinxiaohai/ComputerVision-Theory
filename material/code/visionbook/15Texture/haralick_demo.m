% HARALICK_DEMO --- Demo for haralick
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Example
% 
% We consider ten texture samples from the Brodatz
% collection{Available in digital form for example from 
% http://sipi.usc.edu/database.} ,
% see Figure ??.  



close all ;
clear all ;
addpath('..') ;
cmpviapath('..',1) ;

if (exist('output_images')~=7)
  mkdir('output_images');
end


rand('state',1) ;
randn('state',1) ;


% Set the following to 0 to avoid recalculation
if 1,
  if 1,
    prepare_texture_data() ;
  else
    load textures
  end ;
  
% Haralick texture descriptors are calculated for each patch in the
% training and test sets and stored into a structure suitable for use by 
% the  , function mlcgmm, later on.
  
ntrain = size( textures_train, 2 );
h0 = haralick( textures_train(1).patch );
n = size(h0,1);
features_train.X = zeros( n, ntrain );
features_train.y = zeros( 1, ntrain );
features_train.X(:,1) = h0;
features_train.y(1) = textures_train(1).class;
for i = 2:ntrain
disp([ 'Calculating feature for training patch ' num2str(i) ]) ;
  features_train.X(:,i) = haralick( textures_train(i).patch );
  features_train.y(i) = textures_train(i).class;
end

ntest = size(textures_test,2);
features_test.X = zeros(n,ntest);
features_test.y = zeros(1,ntest);

for i = 1:ntest
  disp([ 'Calculating feature for test patch ' num2str(i) ]) ;
  features_test.X(:,i) = haralick( textures_test(i).patch );
  features_test.y(i) = textures_test(i).class;
end

% As the descriptor calculation may take a few minutes, for convenience
% the precomputed descriptors can be saved and later restored.
save features features_test features_train ntrain ntest
else
load features
end

% The training data is normalized so that all features have zero mean
% and unit standard deviation. This improves numerical stability of the
% subsequent steps.

m = mean( features_train.X, 2 );
X = features_train.X - repmat(m,1,ntrain);
v = sqrt( var(X') )';
features_train.X = X ./ repmat(v,1,ntrain);

% There are 202 features, which is too many given that we only have
% 18 training patches (on the average) per class. We
% choose the 10 most relevant ones using function goodfeatures.

ind = goodfeatures( features_train, 10 );
features_train.X = features_train.X(ind,:);

% We use the maximum probability normal classifier,
% function maxnormalclass and determine
% the parameters of the Gaussian distributions for each class using
%  function mlcgmm . Because of the
% relative scarcity of training data, we make the additional
% assumption of diagonality of the class covariance matrices. This
% completes the training phase.
model = mlcgmm( features_train, 'diag' );

% To classify the test data, we normalize them using the parameters
% m and v determined from the training data.
% We also select the previously determined subset of `good' features
% ind. The classification itself is performed by function
% maxnormalclass which provides a vector ytest with
% class labels for each test sample.
features_test.X = (features_test.X-repmat(m,1,ntest)) ./ repmat(v,1,ntest);
features_test.X = features_test.X(ind,:);
ytest = maxnormalclass( features_test.X, model );

% The classification results are quite good, given the simple classifier
% and limited amount of training data. The overall classification
% accuracy (the ratio of correctly classified patches with respect to
% all test patches) is 94%. 
% The results can also be presented as
% a confusion matrix, see Table ??.
% The number in row i and column j is the number of patches
% from class j classified as i. (Ideally, all off-diagonal elements
% should be zero.)

k = max( model.y );
c = zeros(k);
for i = 1:ntest
  c(ytest(i),features_test.y(i)) = c(ytest(i),features_test.y(i))+1;
end

c

disp(['Total classification accuracy: ' num2str(sum(diag(c))/sum(c(:)))]);

write_confusion_matrix(c,'haralick_table.tex');

