function skel = thinning(varargin)
% THINNING Morphological thinning with a given structural element
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%
% Sequential thinning  repeatedly
% subtracts the image boundary identified using the hit-or-miss 
% transformation . Thinning can be used to
% obtain a homotopic substitute of a skeleton or to prune spurs in the 
% skeleton. The outcome is determined by the shape of the structuring
% element.
%
% Usage: skel = thinning(im,el,it)
% Inputs:
%   im  [m x n]  Binary input image.
%   el  [p x q x 2 x s]  s different structuring
%     elements are used for the thinning; the
%     shape of each element is defined by a binary matrix
%     [p x q] and there are two separate elements
%     supplied for the hit-or-miss transformation.
%   it  (default 0)  Number of iterations; if zero, iterates
%     until idempotency is reached.
% Outputs:   
%   sket  [m x n]  Result of thinning.
% See also: bwmorph.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
im = varargin{1};
el = varargin{2};

% handle the input variable it. If unspecified assign it = 0
if nargin>2
  it = varargin{3};
else
  it = 0;
end

for r = 1:2
  for s = 1:size(el,4)
    el_rot(:,:,r,s,1) = squeeze( el(:,:,r,s) );
    el_rot(:,:,r,s,2) = squeeze( el(end:-1:1,:,r,s) )';
    el_rot(:,:,r,s,3) = squeeze( el_rot(end:-1:1,:,r,s,2) )';
    el_rot(:,:,r,s,4) = squeeze( el(:,end:-1:1,r,s) )';
  end
end

k = 1;
for s = 1:size(el_rot,4)
  for t = 1:size(el_rot,5)
    el_hit(k) = strel( 'arbitrary', squeeze(el_rot(:,:,1,s,t)) );
    el_miss(k) = strel( 'arbitrary', squeeze(el_rot(:,:,2,s,t)) );
    k = k+1;
  end
end

while true
  skel = im;    
  for k = 1:size(el_hit,2)
    im = im - bwhitmiss( im, el_hit(k), el_miss(k) );
  end
  it = it - 1;
  if sum(skel(:)-im(:))==0 | it==0, break; end;
end
skel = im;

return


