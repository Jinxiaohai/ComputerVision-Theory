% READPOINTFILE -- read point file in T. Cootes' format
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
function xy=readpointfile(filename) ;
% Usage: xy = readpointfile(filename)
% 
% Read a file filename with point coordinates 
% in the format used for T. Cootes' hand point data: the first
% line contains the number of points N, the remaining lines contain
% each two
% numbers corresponding to the x and y coordinates.
% It returns a 2x N array of point coordinates.
  
f  = fopen( filename );
n  = fscanf( f, '%d', 1 );
xy = fscanf( f, '%g', [2 n] );
