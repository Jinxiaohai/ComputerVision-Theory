% LINSEP_DEMO linearly separable training set
% CMPvia CMP Vision Algorithms, http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007-07-04

% History:
% $Id: linsep_demo_decor.m 1074 2007-08-14 09:45:42Z kybic $
%
% 2006-07-24 Tomas Svoboda (TS) created from his own old demo code


clear all;

addpath ./data
addpath ../.
cmpviapath('../.',1);
% if necessary, create a directory for output images
out_dir = './output_images/';
if exist(out_dir)~=7
  mkdir(out_dir)
end 

% The demonstration shows the use of three classifiers on a linearly
% separable 2D 5-class data. 

axisvec = 1.2*[-1,1,-1,1];
xticks  = axisvec(1):(axisvec(2)-axisvec(1))/6:axisvec(2);
yticks  = axisvec(3):(axisvec(4)-axisvec(3))/6:axisvec(4);

% The data are prepared beforehand. New test data can
% be interactively prepared by calling the stprtool function createdata.
% The data are organized in a simple structure: data.X is a 
% [dim  x N] matrix containing the data feature vectors, data.y is 
% a [1 x N] vector with class labels. 
dataname = 'my_pentagon';
if exist([dataname '.mat'])==2
  data = load(dataname);
else
  error('data file does not exist. New data can be created by createdata')
end

% options for plotting function pboundary
plotopt.gridx = 500;
plotopt.gridy = 500;
plotopt.line_style = 'k-';
plotopt.fill = 0;
fid = figure(1); clf

% k-Nearest Neighbors (k-NN) classifier
for neighbours = 1  % you may test various odd numbers
  model = knnrule( data, neighbours ); % organize data for classification
  figure(fid);  clf
  ppatterns( data ); % display the data
  axis(axisvec);  axis square;  grid on
  set( gca, 'XTick',xticks, 'YTick',yticks, 'Box','on' )
  pboundary( model, plotopt );  % display the separating hypersurface
  title(sprintf('%d-nearest neighbour classifier',neighbours));
  % print('-depsc',sprintf('%s_%dnn_class.eps',dataname,neighbours));
  exportfig(gcf,[out_dir,sprintf('%s_%dnn_class.eps',dataname,neighbours)])
end



% exemplar classifier
clear model;
model = exemplar_learn( data, 'mean' );

figure(2), clf
hold on
markers = {'x','o','*','d','^'};
colors = {'b','r','g','k','m'};
for i=model.y,
  plot(model.exemplar(1,i),model.exemplar(2,i),[markers{i},colors{i}],'MarkerSize',15,'LineWidth',3)
end
axis(axisvec); axis square, grid on
set(gca,'XTick',xticks,'YTick',yticks,'Box','on')
title('minimum distance from exemplars')
pboundary( model, plotopt ); % decision boundary
[y,dfce] = linclass( data.X, model ); % classification of the training set
idx_mismatch = find( y~=data.y );    % localize mismatches
for i=idx_mismatch % print the mismatches clearly
  plot( data.X(1,i), data.X(2,i),'o', 'LineWidth',1, 'Color','black', ...
       'MarkerSize',12, 'MarkerFaceColor',[1 0.8 0.8])
end
ppatterns( data ); % plot the training data
drawnow;
exportfig(gcf,[out_dir,sprintf('%s_exemplar_class.eps',dataname)])

% perceptron
figure(3); clf 
ppatterns(data,5);
axis(axisvec); axis square, grid on
set(gca,'XTick',xticks,'YTick',yticks,'Box','on')
drawnow;
grid on;
model = mperceptron( data );
pboundary( model, plotopt );
[y,dfce] = linclass(data.X,model); % classification of the training set
idx_mismatch = find(y~=data.y)    % localize mismatches
title('perceptron')
exportfig(gcf,[out_dir,sprintf('%s_mperceptron_class.eps',dataname)])

figure(4); clf 
ppatterns(data,5);
axis(1.1*[min(model.W(1,:)),max(model.W(1,:)),min(model.W(2,:)),max(model.W(2,:))]); 
axis equal; grid on;
model = mperceptron(data);
pboundary(model,plotopt);
hold on
for i=1:size(model.W,2),
  plot(model.W(1,i),model.W(2,i),[markers{i},colors{i}],'MarkerSize',15,'LineWidth',3)
end
% plot two lines line as an example
line(model.W(1,[3,4]),model.W(2,[3,4]),'Color','blue')
line(model.W(1,[1,5]),model.W(2,[1,5]),'Color','blue')
set(gca,'Box','on')
title('Exemplars and separating hyperplanes found by perceptron')
exportfig(gcf,[out_dir,sprintf('%s_mperceptron_with_exemplars.eps',dataname)])


