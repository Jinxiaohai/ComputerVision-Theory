% HUFFMAN_DEMO
% CMP Vision Algorithms http://visionbook.felk.cvut.cz 
%
% Example
%
% Encode a simple string of unique integers:

addpath('..') ;
cmpviapath('..') ;

data = [-1; 2; 3; 6; 7];
code = huffman( data );
data_encoded = huffman_encode( data, code );

% The encoded message is:
% data_encoded' =  0   0   0   1   1   1   0   1   1   1   1   0

% and can be decoded as:

data_decoded = huffman_decode( data_encoded, code );

% data_decoded' = -1   2   3   6   7


% If some input symbols are repeated, the encoding is more efficient,
% i.e., the encoded message is shorter.

data = [2; 2; 2; 2; 6];
code = huffman(data);
data_encoded = huffman_encode( data, code );


% The same result can be obtained if we supply huffman with the
% frequency table. 

freq.x = [2 6];  freq.f = [4 1]; 
code = huffman( [], freq );
data_encoded = huffman_encode( data, code );



% In the next example we generate n=10^5  8-bit integers with 
% (approximately) normal random distribution with mean 128 and standard
% deviation sigma=30, and encode them with huffman.

rand('state',0);
randn('state',0);

n = 100000;
data = round( random('normal',128,30,n,1) );
data(data>256) = 256;  data(data<1) = 1;
tic
code = huffman( data );
toc
tic
data_encoded = huffman_encode( data, code );
toc

% We verify that data is correctly decoded and calculate the length
% of the encoded data.

tic
data_decoded = huffman_decode( data_encoded, code );
toc
dif = sum( abs(data_decoded-data) )
len = length( data_encoded )

