function code=huffman(data,freq) ;
% HUFFMAN --- create Huffman code
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%  
% Entropy coding assigns to each input symbol a variable-length code 
% based on the symbol's frequency, so that an average (expected) 
% message length is
% minimized. Huffman coding , 
% in particular, assigns to each symbol a prefix-free binary code. 
%  
% The Huffman code is statistically optimal for large alphabets, provided that 
%  a separate code word is assigned to each symbol, and
%  the symbols are not correlated. 
% In other cases, coding several symbols together (as is done for example
% in arithmetic coding) may be more efficient.
%  
% The essence of the Huffman coder is first to generate a leaf node for
% each symbol and then to keep an ordered list of node
% probabilities, and in each step merge the two nodes with the smallest
% probabilities. The key point is maintaining the ordering when a new
% node is generated. Several methods exist with computational complexity
% (n log n) , 
% (where n is the alphabet length) using a priority queue, insertion
% sort with binary search, or
% two separate queues for leaves and non-leaf nodes. For simplicity and
% because of Matlab limitations,
% the method presented here sorts the list at each iteration, resulting
% in an overall complexity (n^2 log n). Fortunately, the time spent 
% creating the code
% is usually negligible with respect to calculating the frequencies and 
% the actual encoding and decoding.
% 
% The implementation consists of three parts: 
%  function huffman 
% creates the optimal code from data, or from a table of symbol probabilities,
%  function huffman_encode performs the encoding,
%  and  function huffman_decode the decoding.
% 
% Usage: code = huffman(data,freq)
% Inputs:
%   data  [n x 1]  Input data as a column vector, which must 
%     have integer values. If parameter freq is given,
%     parameter data does not influence the code.
%   freq  struct  Relative frequencies of the input symbols.
%     freq.f[i] is the relative frequency of the symbol freq.x[i].
%     The relative frequency must be defined for all symbols occurring in the
%     input data, also in subsequent encoding 
% by huffman_encode. 
% It does not have to be normalized.
%     If not specified, the frequencies are estimated from the data.[-.5ex]
% Outputs:
%   code  struct  Structure describing the generated Huffman code, to be used
%     by huffman_encode and huffman_decode.
% See also: huffman_encode, huffman_decode.

data = double(data);
  
if nargin<2,
  if size(data,2)~=1
    error('huffman: Input data must be a column vector') ;
  end

  if sum(round(data)~=data)>0
    error('huffman: Input data must be integer') ;
  end
end

% If symbol relative frequencies freq are given, we only check
% that all symbols are present and that none are repeated.

if nargin==2
  minval = min(freq.x);  maxval = max(freq.x);

  if length(setdiff(data,freq.x))>0
    error('huffman: Some input symbols not in the frequency table')
  end
  
  if length(freq.x)~=length(unique(freq.x))
    error('huffman: Input symbols are not unique in the frequency table')
  end
  if length(freq.x)~=length(freq.f)
    error('huffman: Incorrect length of the frequency table components.')
  end
  
% If freq is not given, the frequency table is calculated using
% histogramming (function histc).
  
  else
    minval = min(data);  maxval = max(data);
    freq.x = minval:maxval;
    freq.f = histc( data, freq.x ); 
  end

% We add code.offset to the input data so that the values 
% start at 1 and can be used for indexing. The frequency table is
% normalized to obtain probabilities.
code.offset = 1 - minval;
data = data + code.offset;
prob = freq.f / sum(freq.f);

% Symbols with non-zero probabilities are stored in code.values
% (to be used in function huffman_decode),
% symbols with zero probabilities are skipped. This 
% optimization is useful when a large range of input values
% does not appear in the input data. We create a table
% code.values_enc as an inverse of code.values. 
% The number of coded symbols (effective alphabet size) is stored in
% code.size.

ind = find(prob>0);
prob = prob(ind);
code.values = freq.x(ind) + code.offset;
code.values_enc = zeros( maxval-minval+1, 1 );
for i = 1:length(code.values)
  code.values_enc(code.values(i)) = i;
end

code.size = length(code.values);

% The leaf nodes of the coding tree are assigned numbers
% 1..., higher numbers correspond to non-leaf nodes.
% The array q contains unprocessed nodes waiting to be
% incorporated into the tree. It is initialized with the leaf nodes,
% sorted according to node (symbol) probabilities. The arrays
% prob and q share the same ordering which is maintained
% during further processing.
q = 1:code.size;
[prob,sort_index] = sort( prob, 'ascend' );
q = q(sort_index);

% Information about edges is stored in arrays code.zero[i]
% and code.one[i], which are indexed by the node number j
% such that i=j-code.size; they contain
% the index of the left and right child of the node j, respectively.
% The index of the last tree node is stored in last.
last = code.size;
code.zero = 0;
code.one = 0;

%
% The coding tree is built by an iterative procedure. In each step,
% two nodes with the lowest probabilities, which occupy the two first
% positions of the array q, are merged together. This is repeated 
% while there are nodes left.
while( length(q)>1 )
  last = last + 1;
  code.zero(last-code.size) = q(1);
  code.one(last-code.size) = q(2);
% The two former nodes are erased and the new node last is added to the 
% arrays q and prob. The arrays are sorted.
  q(2) = last;
  prob(2) = prob(1) + prob(2);
  q = q(2:end);
  prob = prob(2:end);
  [prob,sort_index] = sort( prob, 'ascend' );
  q = q(sort_index);
end

% At this point, the tree is built and last refers to the tree root.
code.root = last;

% We now build a table code.table containing for each tree node
% the corresponding binary code. Since the codes have variable length,
% we choose code.table to be a cell array.
% The tree nodes are processed starting
% from the root in decreasing order of node numbers which guarantees
% that each parent is processed before its children. Finally, 
% the encoding table is shortened since only leaf codes are used for
% encoding.

code.table = cell(last,1);
for i = last:-1:code.size+1
  code.table{code.zero(i-code.size)} = logical( [code.table{i} 0] );
  code.table{code.one(i-code.size)} = logical( [code.table{i} 1] );    
end

code.table = code.table(1:code.size);

% The shortest and longest code is computed. This can be used to obtain
% bounds on the code or message size, see huffman_decode.
code.shortest = length(code.table{1});
code.longest = code.shortest;

for i = 2:code.size
  ln = length(code.table{i});
  if ln>code.longest
    code.longest = ln;
  elseif ln<code.shortest
    code.shortest = ln;
  end
end

