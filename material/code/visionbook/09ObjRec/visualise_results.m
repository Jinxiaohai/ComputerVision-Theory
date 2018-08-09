function fh_last = visualise_results(idx_error,match_table,data,datadesc,fh,show_im)
% VISUALISE_RESULTS textual and graphical visualisation of results
%
% fh_last = visualise_results(idx_error,match_table,data,datadesc,fh,show_im)
%
% Input parameters
%   idx_error   - [3 x num_errors] [index; true class label; wrong class label]
%                 it is used in the graphical visualisation a could be 
%                 useful in futher analysis
%   match_table - [num_class x num_class]
%                 How to interpret the table
%                 assume class_labels [1,num_class]
%                 class with class_labels(i) hass benn match_table(i,j) classified
%                 as class_labels(j). Naturally, for perfect classification, 
%                 the matrix will be diagonal. 
%   data        - structure containing the data were classified
%    .X         - [N x num_vectors] feature vectors
%    .y         - [1 x num_vectors] true class labels; if no error y==data.y
%   datadesc    - string describing the data, could be a filename
%   fh          - figure handle of the first figure if zero, only textual output
%   show_im     - 1-> show missclassified patterns
%               - 0-> do nothing (default value)
% 
% Output parameters
%   fh_last - handle of the last figure plotted
% 
% See also: class_results

% History:
% 2006-12-01  Tomas Svoboda: created

if nargin<5
  fh=0;
end

labels = unique(data.y);
num_classes = length(labels);

for i=1:num_classes,
  idx = find(idx_error(2,:)==labels(i));
  disp(sprintf('class "%d"  missclassified %4d times',i-1,length(idx)));
end

%%% 
% if nonzero fh
% visualize the mathing table
if fh
  figure(fh); clf;
  labels = [];
  for i=0:9,
	labels = [labels;num2str(i)];
  end
  imagesc([0:9],[0:9],match_table), 
  set(gca,'Xtick',[0:9],'XtickLabel',labels)
  set(gca,'Ytick',[0:9],'YtickLabel',labels)
  colorbar;
  xlabel('#times classified as')
  ylabel('True labels');
  title(['Matching table for ',datadesc],'Interpreter','none');
  hold on;
  for i=1:size(match_table,1),
	for j=1:size(match_table,2),
	  text(j-0.35-1,i+0.1-1,sprintf('%2d',match_table(i,j)),'color','white','FontSize',16)
	end
  end

  %%%
% if a non-zero figure handle is given
% show the missclassified data (images)
  if show_im
	fh = fh+1;
	disp('showing wrongly classified images')
	figure(fh);
	last_fig = fh;
	last_in_fig = 0;
	figure(last_fig); clf;   % open an new figure and clear it

	for i=1:length(idx_error), % for each error
	  last_in_fig = last_in_fig + 1;
	  if( last_in_fig > 25 )
		last_fig = last_fig + 1;
		last_in_fig = 1;
		figure(last_fig); clf;   % open an new figure and clear it
	  end

	  subplot( 5,5, last_in_fig );
% reshape the data vector to an image
% and scale up to get better visibility
	  imshow(imresize(reshape(data.X(:,idx_error(1,i)),13,13),8,'nearest'));
	  title(sprintf('%d -> %d',idx_error(2,i)-1,idx_error(3,i)-1))
	end
  end
end

try fh_last = last_fig; catch fh_last = fh; end;


return;
