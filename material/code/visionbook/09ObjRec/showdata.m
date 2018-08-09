function last_fh = showdata(data,fh)
% SHOWDATA visualise datasets
% 
% last_fh = showdata(data,fh)
% 
% Input parameters
%   data - structure with data
%    .X  - [N x num_vectors]
%    .y  - [1 x num_vectors] class labels
%   fh           - figure handle of the first usable figure
%
% Output parameters
%   last_fh - figure handle of the last figure
%
% The function is not robust. For use with ocr_trn_data
% and ocr_tst_data only. Modification needed for use with more
% general datasets. See the comments inside.

% History:
% 2006-11-29  Tomas Svoboda: created
% 2006-12-01  Tomas Svoboda: change of the input parameters

% The scaling of the images is controlled by the variable scale. 
% Requires Image Processing Toolbox. It can be however, rewritten without
% the use of imresize if needed

scale = 4;

for i=1:10,
  last_fh=figure(fh+i-1); clf
  imall = zeros(scale*10*13,scale*10*13);
  count=1;
  for j=1:10,
	for k=1:10,
	  imall((j-1)*scale*13+1:j*scale*13,(k-1)*scale*13+1:k*scale*13) = imresize(reshape(data.X(:,(i-1)*100+count),13,13),scale,'nearest');
	  count=count+1;
	end
  end
  imshow(imall)
  title(sprintf('data for cipher %d',i-1),'Interpreter','none')
end


% visualize the data