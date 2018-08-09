% GRAPHCUTS_DEMO --- GraphCut segmentation example
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Example
% 
% We shall segment an image (Figure ??a) into two
% classes (the cat and the rest of the image) based on
% color. The first step is to create color prototypes for both classes.
% We use k-means clustering to do this automatically. Note that the
% image data first need to be reshaped to one row per pixel.
% Note also that since the k-means initialization is random, the final class
% labels are also assigned randomly. However, it is usually not
% difficult to identify the foreground class label, if necessary.
% We obtain the prototypes (clusters) in c and the induced
% segmentation in l0 (Figure ??b).


ImageDir='images/';%directory containing the images
addpath('..') ;
cmpviapath('..') ;

outputdir = './output_images/';
if exist(outputdir)~=7
    mkdir(outputdir)
end


if exist('GraphCut')~=2 || exist('GraphCutMex')~=3 || ...
      exist('GraphCutConstr')~=3 ,
  disp('ERROR: It appears that the GraphCut Matlab wrapper is not installed.');
  disp('Please install it from ') ;
  disp('         http://www.wisdom.weizmann.ac.il/~bagon/matlab.html') ;
  disp('to directory ../matlab_code/graphcut.') ;
  error([ 'GraphCut wrapper not installed.'])
end ;



img = im2double( imread([ImageDir 'cat.jpg']) );
[ny,nx,nc] = size(img);
d = reshape( img, ny*nx, nc ); 
k = 2; % number of clusters
[l0 c] = kmeans( d, k );
l0 = reshape( l0, ny, nx );

figure(1) ; imagesc(img) ; axis image ;  axis off ;
exportfig(gcf,[outputdir,'graphcut_input1.eps']) ;

figure(2) ; imagesc(l0) ; axis image ;  axis off ;
exportfig(gcf, [outputdir,'graphcut_kmeans.eps']) ;

% For each class, the data term Dc measures the distance of
% each pixel value to the class prototype. For simplicity, standard
% Euclidean distance is used. Mahalanobis distance (weighted by class
% covariances) might improve the results in some cases.  Note that the
% image intensity values are in the [0,1] interval, which provides
% normalization.  

Dc = zeros( ny, nx, k );
for i = 1:k
  dif = d - repmat( c(i,:), ny*nx,1 );
  Dc(:,:,i) = reshape( sum(dif.^2,2), ny, nx );
end

% The smoothness term Sc(i,j) is a matrix of costs associated
% with neighboring pixels having values i, j. We define the cost to
% be zero if i=j and a constant (2) otherwise. Increasing this
% constant strengthens the neighborhood constraints more and makes the
% segments larger (and vice versa).  

Sc = 2 * ( ones(k)-eye(k) );

% The graph cut problem is initialized by calling
% GraphCut('open',...) which returns a handle.
% GraphCut('expand',handle) performs the actual optimization and
% returns the labeling l (note that the class labels start with
% 0, unlike for kmeans). The optimization takes only a few
% seconds, depending on the parameter setting and image size. Finally,
% GraphCut('close') takes care of releasing the memory.  The
% segmentation results can be seen in
% Figure ??c,d. Note that while the segmentation
% result is not perfect, it is very good for a completely unsupervised
% algorithm. The algorithm successfully fills in the fence wires present
% in the k-means segmentation.  

handle  = GraphCut( 'open', single(Dc-min(Dc(:))), Sc );
[gch l] = GraphCut( 'expand', handle );
handle  = GraphCut( 'close', handle );

lb=imdilate(l,strel('disk',4))-l ; 

figure(3) ; image(img) ; axis image ;  axis off ;hold on ;
contour(lb,[1 1],'r','LineWidth',2) ; hold off ;
exportfig(gcf,[outputdir,'graphcut_output1.eps']) ;

figure(4) ; imagesc(l) ; axis image;  axis off ;
exportfig(gcf,[outputdir,'graphcut_segm1.eps']) ;


% 
% Our second example (Figure ??a) turns out to be
% more difficult due to non-uniform illumination and background. We
% proceed as before (after reducing the image to a convenient size
% 432x 288 pixels), except that we first convert the  image into
% the L*a*b color space, using only the a,b
% components for clustering and evaluating the data cost. Note that the
% a,b components are normalized to simplify relative weighting
% of the cost terms.  We ask the k-means algorithm for four clusters
% to capture the variability of the background. 

img = im2double( imresize(imread([ImageDir 'rhino2.jpg']), 0.125) );
[ny,nx,nc] = size(img);
imgc = applycform( img, makecform('srgb2lab') );
d = reshape( imgc(:,:,2:3), ny*nx, 2 );
d(:,1) = d(:,1)/max(d(:,1));   d(:,2) = d(:,2)/max(d(:,2));
k = 4; % number of clusters
[l0 c] = kmeans( d, k );
l0 = reshape( l0, ny, nx );

figure(1) ; imagesc(img) ; axis image ;  axis off ;
exportfig(gcf,[outputdir,'graphcut_input2.eps']) ;

figure(2) ; imagesc(l0) ; axis image ;  axis off ;
exportfig(gcf,[outputdir,'graphcut_kmeans2.eps']) ;


% The data and smoothness terms Dc and Sc are calculated 
% as before.

Dc = zeros( ny, nx, k );
for i = 1:k
  dif = d - repmat( c(i,:), ny*nx, 1 );
  Dc(:,:,i) = reshape( sum(dif.^2,2), ny, nx );
end
Sc = ones(k) - eye(k);

%
% The data and smoothness terms by themselves provide a good
% segmentation (Figure ??b,e). However, the
% results can be further improved if edge information is also taken
% into account, to encourage pixel label changes across edges and
% discourage them otherwise. We obtain the edge information (separately
% for horizontal and vertical directions) by applying a smoothed Sobel
% filter. We take a maximum over all three color channels and apply an
% exponential transformation on the result. The horizontal and vertical
% costs are then passed to GraphCut('open') as additional
% parameters.

g  = fspecial( 'gauss', [13 13], 2 );
dy = fspecial( 'sobel' );
vf = conv2( g, dy, 'valid' );

Vc = zeros( ny, nx );
Hc = Vc;

for b = 1:nc
  Vc = max( Vc, abs(imfilter(img(:,:,b), vf , 'symmetric')) );
  Hc = max( Hc, abs(imfilter(img(:,:,b), vf', 'symmetric')) );
end


gch=GraphCut( 'open', single(Dc-min(Dc(:))), Sc ); % ,exp(-5*Vc),exp(-5*Hc));
[gch l]=GraphCut('expand',gch);
gch=GraphCut('close', gch);

label=l(100,200) ;
lb=(l==label) ;
lb=imdilate(lb,strel('disk',1))-lb ; 

figure(3) ; image(img) ; axis image ; axis off ; hold on ;
contour(lb,[1 1],'r','LineWidth',2) ; hold off ; 
exportfig(gcf,[outputdir,'graphcut_output2.eps']) ;


figure(4) ; imagesc(l) ; axis image ; axis off
exportfig(gcf,[outputdir,'graphcut_segm2.eps']) ;


gch = GraphCut( 'open', Dc, 5*Sc,exp(-10*Vc), exp(-10*Hc) );
[gch l] = GraphCut( 'expand', gch );
gch = GraphCut( 'close', gch );

lb=(l==label) ;
lb=imdilate(lb,strel('disk',1))-lb ; 

figure(5) ; image(img) ; axis image ; axis off ; hold on ;
contour(lb,[1 1],'r','LineWidth',2) ; hold off ; 
exportfig(gcf,[outputdir,'graphcut_outputedge2.eps']) ;


figure(6) ; imagesc(l) ; axis image ; axis off
exportfig(gcf,[outputdir,'graphcut_segmedge2.eps']) ;

% Results are shown in Figure ??. Note that the
% edge information  improves the segmentation of the horn and of the
% legs of the animal slightly.
% 
% Graph cut segmentation is a very versatile and powerful segmentation
% tool. Its main advantage is the global optimality of the results
% together with a reasonable speed. However, some experimentation with
% cost terms appropriate for a particular task is usually required.

