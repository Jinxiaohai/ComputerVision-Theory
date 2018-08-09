function h=haralick(im,maxdist) ;
% HARALICK calculate Haralick texture descriptors
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%   
% Classical texture descriptors based on co-occurrence matrices were
% introduced by Haralick  and are useful
% mainly for texture classification. 
% For each angle phi in {0,
% 45, 90, 135} and distance
% d in {1... d_} 
% defining a co-occurrence matrix
% , we shall calculate
% five texture descriptors: energy, entropy, contrast, inverse difference
% moment (homogeneity), and
% correlation. 
%  The distance d=0 is treated
% specially: it only makes sense to calculate energy and entropy in this case
% since the
% co-occurrence matrix is diagonal.  The descriptors for all
% (phi,d) are concatenated into a feature vector.
%
% Usage: h = haralick(im,maxdist)
% Inputs:  
%   im  [m x n]  Input image of type uint8. It should 
%     contain a sufficiently large patch of homogeneous texture to analyze;
%     a typical size might be 100x 100 pixels,
%     depending on resolution. Images must be of
%     the same size for feature vectors to be comparable.
%   maxdist  (default 10)  Maximum distance d_ between
%     pixels to consider - to be chosen depending on the characteristic scale
%     of the texture. Increasing d_ increases computational
%     complexity and the number of
%     features generated.
% Outputs:
%   h  [k x 1]  Feature vector of length
%     k=20 d_+2, characterizing the input texture im.
% See also: waveletdescr, cooc.
% 
% The restriction to {uint8 is necessary for the
%   co-occurrence matrix calculation in cooc.}
% 

if nargin<2,
  maxdist=10 ;
end ;
  
if not(isa(im,'uint8')),
  error('haralick: im must be class uint8.') ;
end ;

% Generate the offset vector for a function cooc which is used 
% for calculating the co-occurrence matrices, each row corresponds to one
% offset. We go over distances d in {1... d_}
% and angles phi in {0,
% 45, 90, 135}. Note that only angles smaller
% than 180 need to be considered thanks to the symmetry of the
% co-occurrence matrix formulation used .

t = (1:maxdist)';
z = 0*t;
offs = [t z; z t; t t; -t t];
n = size( offs, 1 );

% First the descriptors for d=0 are evaluated using function
% hfeatures and only energy and entropy are retained. Then, the
% descriptors for all other offsets are evaluated and stored into
% the output vector h. Note that the asymmetric co-occurrence matrix
% returned by cooc is made symmetric to correspond to the
% definition .

h0 = hfeatures( cooc(im,[0 0]) );
h = [h0(1:2); zeros(5*n,1)];

for i = 1:n
  c = cooc(im,offs(i,:));  c = c+c';
  h(5*i-2:5*i+2) = hfeatures(c);
end

function f = hfeatures(c)
% Usage: f = hfeatures(c)
% Given a symmetric co-occurrence matrix c, this function
% evaluates the five texture descriptors:
% energy, entropy, contrast, inverse difference moment (homogeneity), 
% and correlation 
% [Equations :??--??].

[nc,mc] = size(c);  [x,y] = meshgrid( 1:nc, 1:mc );
f0 =  sum(sum( c.^2 ));              % energy
f1 = -sum(sum( c.*log(c+eps) ));     % entropy
f2 =  sum(sum( abs(x-y).*c ));       % contrast
f3 =  sum(sum( c./(1+abs(x-y)) ));   % inverse difference moment
mx =  sum(sum( x.*c ));  my = sum(sum( y.*c ));
sx =  sum(sum( (x-mx).^2.*c ));
sy =  sum(sum( (y-my).^2.*c ));
f4 =  sum(sum( (x-mx).*(y-my).*c )) / sqrt(sx*sy); % correlation
f  = [f0 f1 f2 f3 f4]';
  
