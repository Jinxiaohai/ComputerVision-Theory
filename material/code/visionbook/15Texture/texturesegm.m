function l=texturesegm(im,model,regul) ;
% TEXTURESEGM texture based segmentation
% CMP   Vision Algorithms http://visionbook.felk.cvut.cz
% 
% Texture descriptors can also be used for segmentation of images consisting
% of several different textures. Here we follow Unser  and
% show how wavelet texture descriptors
% (Section ??) can be used for this purpose.
% We proceed in three steps: 
%  We create a function waveletsegdescr which is
% derived from waveletdescr but instead of calculating the
% descriptors globally for the whole image, it calculates them for each pixel.
%  Function texturesegmtrain takes a training image
% with a known segmentation and creates a model of the classes
% (textures) in the image.  Finally, function
% texturesegm takes an unknown image and segments it using
% the learnt model. Graph cut segmentation
% (Section ??) is used to obtain spatially coherent
% segmentation. 
%
% Usage: texturesegm(im,model,regul)
% Inputs:
%   im  [m x n]  Input image to be segmented.
%      model  struct  Model of the texture classes as
%      returned by texturesegmtrain.
%   regul  (default 200)  Regularization for the GraphCut segmentation
%     algorithm, penalizing different class labels for neighborhood pixels. 
%     Increasing this parameter eliminates small regions but may decrease
%     accuracy.
% Outputs:
%   l  [m x n]  output labeling. Each pixel position contains
%     an integer 1... d corresponding to an assigned class; d is the
%     number of classes.
% See also: {waveletdescr, texturesegmtrain,
%   waveletsegdescr.}
% 
  
if nargin<3,
  regul=200 ;
end ;

% Texture descriptors f are calculated for each pixel of the image 
% and the probability p of a pixel belonging to a particular class
% is evaluated using  function pdfgauss ,
% see also Section ??.

f = waveletsegdescr( im, model.maxlevel, model.sigma );
[k,m,n] = size(f);
p = pdfgauss( reshape(f,k,m*n), model );
d = size(p,1);

%  The logarithm of p is used as the data term for the graph cut
%  segmentation (Section ??).

if exist('GraphCut')~=2 || exist('GraphCutMex')~=3 || ...
      exist('GraphCutConstr')~=3 ,
  disp('ERROR: It appears that the GraphCut Matlab wrapper is not installed.');
  disp('Please install it from ') ;
  disp('         http://www.wisdom.weizmann.ac.il/~bagon/matlab.html') ;
  disp('to directory ../matlab_code/graphcut.') ;
  error([ 'GraphCut wrapper not installed.'])
end ;


Dc = -single(log( reshape(p',m,n,d)+eps ));
Dc=Dc-min(Dc(:)) ;
Sc = regul*( ones(d)-eye(d) );
handle  = GraphCut( 'open', single(Dc-min(Dc(:))), Sc );
[gch l] = GraphCut( 'expand', handle );
handle  = GraphCut( 'close', handle );
l = l+1; % as GraphCut classes start at 0

