function y=rangesearch(g,b) ;
% Return a set of points containing all points in bounds [bmin ; bmax]
% (and maybe more).
  
d=size(b,2) ;
gn=size(g.c) ;
bi= int32(max(min(((b-repmat(g.minx,2,1)) ./ repmat(g.v,2,1))+0.5,...
              repmat(gn,2,1)),ones(2,d))) ;

% create a set of cells to consider
a=cell(1,d) ;
for i=1:d,  
    a{i}=[bi(1,i):bi(2,i)] ; 
end ;
[l{1:d}]=ndgrid(a{1:d}) ;
ind=sub2ind(size(g.c),l{1:d}) ;
y=cat(1,g.c{ind(:)}) ;