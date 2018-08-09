% WAVELETDESCR_DEMO --- Demo for wavaletetdescr
% CMP Vision Algorithms http://visionbook.felk.cvut.cz 
%
% Example
% We compare the classification performance of wavelet descriptors 
% waveletdescr with co-occurrence matrix based descriptors 
% generated by haralick. We use the same set of textures 
% (Figure ??), the same set of training and
% testing patches, and the same classifier. The source code from
% Section ?? can be re-used, with all
% occurrences of haralick replaced by waveletdescr.
% The only difference is that for wavelet descriptors no feature
% selection is needed, since with the default settings (maxlevel=3)
% only 10 features are generated.
% 
% Notice that calculating  wavelet descriptors is many times
% faster than calculating the descriptors generated by
% haralick. Also the performance is better, with an
% overall classification accuracy 97%, see Table ??.
%



close all ;
clear all ;
addpath('..') ;
cmpviapath('..',1) ;
if (exist('output_images')~=7)
  mkdir('output_images');
end
rand('state',1) ;
randn('state',1) ;

load textures ;

if 1,
  
  ntrain = size(textures_train,2) ;
  h0 = waveletdescr(textures_train(1).patch) ;
  n = size(h0,1) ;
  features_train.X = zeros(n,ntrain) ;
  features_train.y = zeros(1,ntrain) ;
  features_train.X(:,1) = h0 ;
  features_train.y(1) = textures_train(1).class ;
  for i = 2:ntrain,
    disp([ 'Calculating feature for training patch ' num2str(i) ]) ;
    features_train.X(:,i) = waveletdescr(textures_train(i).patch) ;
    features_train.y(i) = textures_train(i).class ;
  end ;

  ntest = size(textures_test,2) ;
  features_test.X = zeros(n,ntest) ;
  features_test.y = zeros(1,ntest) ;

  for i = 1:ntest,
    disp([ 'Calculating feature for test patch ' num2str(i) ]) ;
    features_test.X(:,i) = waveletdescr(textures_test(i).patch) ;
    features_test.y(i) = textures_test(i).class ;
  end ;

  save featuresw features_test features_train ntrain ntest

else

  load featuresw

end ;

m = mean(features_train.X,2) ;
X = features_train.X-repmat(m,1,ntrain) ;
v = sqrt(var(X'))' ;
features_train.X = X./repmat(v,1,ntrain) ;

model = mlcgmm(features_train,'diag') ;
features_test.X = (features_test.X-repmat(m,1,ntest))./repmat(v,1,ntest) ;
ytest = maxnormalclass(features_test.X,model) ;
k = max(model.y) ;
c = zeros(k) ;
for i = 1:ntest,
  c(ytest(i),features_test.y(i)) = c(ytest(i),features_test.y(i))+1 ;
end ;

c

disp(['Total classification accuracy: ' num2str(sum(diag(c))/sum(c(:)))]) ;

write_confusion_matrix(c,'waveletdescr_table.tex') ;