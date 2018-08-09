function write_confusion_matrix(c,fn) ;
  
fd=fopen(fn,'w') ;

[n m]=size(c) ;
for j=1:m,
  fprintf(fd,'& %d ',j) ;
end ;
fprintf(fd,'\\\\ \\hline \n') ;

for i=1:n,
  fprintf(fd,'%d ',i) ;
  for j=1:m,
    fprintf(fd,'& %0.0f ',c(i,j)) ;
  end ;
  fprintf(fd,'\\\\ \n') ;
end ;

fclose(fd) ;
