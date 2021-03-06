function data_encoded = huffman_encode(data,code)
% HUFFMAN_ENCODE Huffman encoding
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% http://visionbook.felk.cvut.cz
%
% Usage: data_encoded = huffman_encode(data,code)
% Inputs:
%   data  [n x 1]  Integer valued input data as a column vector, as in 
%     function huffman_encode.
%   code  struct  Huffman code generated by huffman. 
%     For optimal results, the code should be generated using the same input
%     data or using correct symbol frequencies. In any case, 
%     the code must include all symbols of the input data,
%     otherwise an error occurs.
% Outputs:
%   data_encoded  [m x 1]  
%     Binary encoded message of class logical.
% See also: huffman, huffman_decode.


data = double(data);
  
if size(data,2)~=1
  error('huffman_encode: Input data must be a column vector')
end

if sum(round(data)~=data)>0
  error('huffman_encode: Input data must be integer')
end

% The coding is straightforward: Input symbols are mapped to
% symbols using function code.values_enc and for each coded
% symbol its code is fetched from code.table and appended to the
% output string. j is an index to the output array 
% data_encoded.
% 
% A recurrent problem in Matlab is how to efficiently create an array if
% its size is not known in advance. Here we estimate the maximum possible
% size of the output string, which is then shortened if necessary.
% (Compare this with the dynamic allocation used 
% in *.)

n = length(data);
data = data + code.offset;
data_encoded = false( code.longest*n, 1 );
j = 1;
for i = 1:n
  s = code.values_enc( data(i) );
  if s==0
    error('huffman_encode: There is no code for some input symbols.')
  end
  word = logical( code.table{s} );
  last = j + length(word) - 1;
  data_encoded(j:last) = word;
  j = last + 1;
end
data_encoded = data_encoded(1:j-1);
