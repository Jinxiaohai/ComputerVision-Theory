img=double(imread('images/mribrain.png')) ;
%img=imresize(img,0.25) ;
[ny,nx]=size(img) ;
[x,y]=meshgrid(1:nx,1:ny) ;
f=sqrt((x-128).^2+(y-112).^2)-5 ;
g=ones(ny,nx) ;

figure(1) ; clf ;
imagesc(img) ; colormap(gray) ; axis equal ; axis tight ; hold on ; 
contour(f,[0 0],'r') ; hold off ; colorbar ;
print -depsc output_images/levelset_input2.eps
figure(2) ;imagesc(f) ; colorbar ;
hold on ; 
contour(f,[0 0],'k') ; hold off ; 
print -depsc output_images/levelset_lsetinput2.eps

f1=levelset(f,img,500,0,100,30,0.5,0.5,0.05,g,1) ;
%g=ones(size(f)) ;
%f1=levelset(f,img,0,0,10,110,1,1,0.1,g) ;

figure(3) ;imagesc(img) ; colormap(gray) ; axis equal ; axis tight ; hold on ; 
contour(f1,[0 0],'r') ; hold off ; colorbar ;

print -depsc output_images/levelset_output2.eps
figure(4) ;imagesc(f1,[-100 100]) ; colorbar ;
hold on ; 
contour(f1,[0 0],'k') ; hold off ; 
print -depsc output_images/levelset_lsetoutput2.eps
