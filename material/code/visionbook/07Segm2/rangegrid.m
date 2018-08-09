function g=rangegrid(x,v) ;
% Create a grid structure for proximity queries from a set of points x
% and optionally also a set of spacings v

[n,d]=size(x) ;

maxx=double(max(x,[],1)) ;
minx=double(min(x,[],1)) ;

if nargin<2,
  v=ones(1,d) ;
end ;

gn=max(ceil((maxx-minx) ./ v),ones(1,d)) ;

if prod(gn)>1e6,
  warning('Too many grid cells. Consider increasing grid size.') ;
end ;

c=cell(gn) ;

% calculate indices for pixels
i= int32(max(min(((double(x)-repmat(minx,n,1)) ./ repmat(v,n,1))+0.5,...
             repmat(gn,n,1)),ones(n,d))) ;
ci=num2cell(i,1) ; 
i=sub2ind(gn,ci{1:d}) ;
% distribute 
for j=1:n,
  c{i(j)}=[c{i(j)} ; x(j,:)] ;
  % disp([ 'Store ' num2str(x(j,:)) ' to ' num2str(i(j)) ]) ;
end ;
  
g.minx=minx ;
g.c=c ;
g.v=v ;
