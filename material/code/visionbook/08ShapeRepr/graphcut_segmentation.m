function l=graphcut_segmentation(img) ;
% GRAPHCUT_SEGMENTATION Edge based binary segmentation using graphcut
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Usage: l = graphcut_segmentation(img)
%
% This function segments a grayscale image into two classes, bright
% background and dark foreground. It uses graph cut 
% driven by both intensity and edges. 
  
%  
% Initial segmentation is performed by k-means, providing mean
% intensities of the two classes. The function sort makes sure
% that foreground (dark) is the first cluster and background (bright) the
% second cluster.
  
[ny,nx,nc] = size(img);
d = reshape( img, ny*nx, 1 );
k = 2;
[l0 c] = kmeans( d, k );
[c,ind] = sort(c);
l0 = reshape( ind(l0), ny, nx );

% The data term Dc penalizes quadratic distance to class prototypes.
% The smoothness term Sc penalizes label changes between neighboring
% pixels.

Dc = zeros( ny, nx, k );
for i = 1:k
  dif = d - repmat( c(i,:), ny*nx, 1 );
  Dc(:,:,i) = reshape( sum(dif.^2,2), ny, nx );
end
Sc = 2 * ( ones(k)-eye(k) );

% We shall also use an edge term, to encourage label changes only across
% strong edges. Then, the graph cut algorithm is applied as usual.

Vc = edge(img);
Hc = Vc;

gch = GraphCut( 'open', Dc, Sc, exp(-5*Vc), exp(-5*Hc) );
[gch l] = GraphCut( 'expand', gch );
gch = GraphCut( 'close', gch );

% We return a binary image, with 1 representing foreground and 0 background.

l = (l==0);
