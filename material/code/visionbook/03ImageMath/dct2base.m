function base = dct2base(blocksize,dctcoeff,rowidx,colidx)
% DCT2BASE computes basis images of 2D DCT
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
%
% Function dct2base computes basis images of the 2D
% Discrete Cosine Transform (DCT).
% The function serves mainly for demonstration purposes. 
% Usage: base = dct2base(blocksize,dctcoeff,i,j)
% Inputs:
%   blocksize  [2 x 1]  Size of the dct2 block.
%   dctcoeff  (default ones(blocksize))  Matrix of dct2 coefficients.
%   rowidx    (default 1:blocksize(1))   Row index(es).
%   colidx    (default 1:blocksize(2))   Column index(es).
% Outputs:
%   base  [blocksize blocksize]  4D array containing the basis images.
%     2D selection squeeze(base(i,j,:,:)) shows one basis function at
%     the i,j position.
% See also: dct2, idct2.

% assign default parameters
if exist('dctcoeff')~=1, dctcoeff = ones(blocksize); end;
if exist('rowidx')~=1,  rowidx = [1:blocksize(1)]; end;
if exist('colidx')~=1,  colidx = [1:blocksize(2)]; end;

a = zeros( blocksize ); 
if isscalar(rowidx) & isscalar(colidx)
  a(rowidx,colidx) = dctcoeff( rowidx, colidx );
  base = idct2( a );
else  % multiple basis requested
  base = zeros([blocksize blocksize]); % allocate space for all
  for i = rowidx
    for j = colidx
      a(i,j) = dctcoeff(i,j); % assign the relevant coefficient
      base(i,j,:,:) = idct2( a ); % compute the basis 2D function
      a(i,j) = 0; % zero the coefficient 
    end
  end
end

return; % end of dct2base


