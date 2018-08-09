% BOUNDARYDESR_DEMO Demo showing the usage of boundarydesc
% CMP Vision Algorithms http://visionbook.felk.cvut.cz

% Example
% 
% We use the same input images as in 
% regiondescrdemo
% which we store to structure imgs.

clear all ; close all ;
addpath('..') ;
cmpviapath('..') ;

if (exist('output_images')~=7)
  mkdir('output_images');
end


ImageDir='images/';%directory containing the images

imgs(1).img = im2double( rgb2gray( imread([ImageDir 'objectsA1.jpg']) ) );
imgs(2).img = im2double( rgb2gray( imread([ImageDir 'objectsA2.jpg']) ) );
imgs(3).img = im2double( rgb2gray( imread([ImageDir 'objectsA3.jpg']) ) );

% One way of obtaining the boundaries needed for boundary descriptors
% would be to apply the function bwboundaries on the
% graph cut segmentation from
% Section ??. Here we show an alternative method using
% snake segmentation (Section ??) that finds the boundaries
% (contours) directly. The segmentation is encapsulated in function
% snake_segmentation. For each object to be
% segmented we provide the parameters of the initial circular contour
% within the object and also the parameters kappa and lambda (see
% Section ??) that sometimes need to be adjusted so that the
% snake stops at the desired boundary. The resulting boundaries are stored in
% the structure b(i).o(j).xy, where i is the image
% number and j the object number.

if 1,
b(1).o(1).xy = snake_segmentation( imgs(1).img,  80, 120, 10, 0.2, 0.05 );
b(1).o(2).xy = snake_segmentation( imgs(1).img, 123,  80,  1, 0.4, 0.15 );
b(1).o(3).xy = snake_segmentation( imgs(1).img, 180, 100, 10, 0.2, 0.05 );

b(2).o(1).xy = snake_segmentation( imgs(2).img, 110, 100, 10, 0.2, 0.05);
b(2).o(2).xy = snake_segmentation( imgs(2).img,  40,  90, 10, 0.2, 0.05);
b(2).o(3).xy = snake_segmentation( imgs(2).img, 137,  54,  1, 0.4, 0.15);

b(3).o(1).xy = snake_segmentation( imgs(3).img, 150, 120, 10, 0.30, 0.05);
b(3).o(2).xy = snake_segmentation( imgs(3).img,  90,  50, 10, 0.20, 0.05);
b(3).o(3).xy = snake_segmentation( imgs(3).img, 166,  66,  1, 0.65, 0.20);

% To save time, the boundaries can be saved using save boundaries b
% and later restored using load boundaries, as usual.

  save boundaries b
else
  load boundaries
end

% The top row in Figure ?? shows the
% detected boundaries.


for i=1:3,
  figure(i) ;
  imagesc(imgs(i).img) ; colormap(gray) ;
  axis image ; axis off ; hold on ;
  colors='rgb' ;
  for j=1:length(b(i).o),
    plot(b(i).o(j).xy(1,:),b(i).o(j).xy(2,:),[ colors(j) '-' ],...
      'LineWidth',2) ;
  end ;
  exportfig(gcf,['output_images/boundarydescr_initial' num2str(i) ...
                    '.eps']) ;
  hold off 
end ;

%
% The boundary descriptors w_i are found for all objects in all
% images and stored 
% into matrix b(i).phi, where each row corresponds to one
% object of image i. The descriptors  are then normalized by the
% median value of w_i over all images to compensate for their uneven
% amplitude. This improves the classification performance even though
% it is not strictly necessary for our simple case. Other normalizations
% (e.g.\ by variance or maximum) are also possible and likely to work well.


phis = [];
for i = 1:3
  for j = 1:length(b(i).o)
    xy = b(i).o(j).xy;  xy=[xy; xy(1,:)]; % close the contour
    phi = boundarydescr(xy);
    b(i).phi(j,:) = phi';  phis = [phis phi];
  end
end
mphi = median( phis, 2 );
for i = 1:3
    b(i).phi = b(i).phi ./ repmat( mphi', length(b(i).o), 1 );
end

% A casual glance shows that the normalized descriptors characterize the
% objects well:

% The object matching is performed by a nearest neighbor classifier
% as in Section ??. The function
% nnmatch calculates for each object
% in images 2 and 3 the index of the `most similar' object in image 1,
% where similarity is measured as the Euclidean distance of the
% descriptor vectors.

b(1).ind = 1:length(b(1).o);
b(2).ind = nnmatch( b(1).phi, b(2).phi );
b(3).ind = nnmatch( b(1).phi, b(3).phi );

% The final matching can be displayed as follows:

for i = 1:3
figure(i+3);
  imagesc(imgs(i).img);  colormap(gray);
  axis image;  axis off;  hold on
  colors = 'rgbcmyk';
  for j = 1:length(b(i).o)
    plot( b(i).o(j).xy(1,:), b(i).o(j).xy(2,:), ...
	  [colors(b(i).ind(j)) '-'], 'LineWidth',2 );
  end
  hold off 
exportfig(gcf,['output_images/boundarydescr_final' num2str(i) '.eps']) ;
end


