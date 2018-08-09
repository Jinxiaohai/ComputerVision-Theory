
% Some examples of data structures and different 
% way of accessing the data

% simple [2x3] 2D array
A = [1,2,3; 4,5,6]
% three different indexes
image_idx  = [1 2]
linear_idx = sub2ind( size(A), image_idx(1), image_idx(2) )
[row_idx,col_idx] = ind2sub( size(A), linear_idx )
% three different indexes leading to the same array element
values = [A(image_idx(1),image_idx(2)) A(linear_idx) A(row_idx,col_idx)]
% make a vector
A_vec = A(:)
% linear index can be used directly
value = A_vec(linear_idx)
% selection of few values
few_values = A_vec(1:3)
% selection by a logical condition
selected_values = A_vec(A_vec>3)
% adding third row to the data
A(3,:) = -1

% a very simple cell array
L = {'monday' 3 'k'};
% accessing cells
L{1}, L{2}

% filling an array of structures
person(1).height = 145;
person(1).name   = 'John B.';
person(2).height = 195;
person(2).name   = 'Bobby B.';

% collecting all heights
all_heights = [person(1:end).height]

