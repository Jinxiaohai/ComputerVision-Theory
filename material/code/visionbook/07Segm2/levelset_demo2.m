img=double(imread('images/xhand3.png')) ;


img=imresize(img,0.25) ;
[ny,nx]=size(img) ;
[x,y]=meshgrid(1:nx,1:ny) ;
f=sqrt((x-100).^2+(y-175).^2)-50 ;
g=ones(ny,nx) ;

close all ;
figure(1) ;  imagesc(img) ; colormap(gray) ; axis equal ; axis tight ; hold on ; 
contour(f,[0 0],'r') ; hold off ; colorbar ;
print -depsc output_images/levelset_input.eps
figure(2) ;imagesc(f) ; colorbar ;
hold on ; 
contour(f,[0 0],'k') ; hold off ; 
print -depsc output_images/levelset_lsetinput.eps

f1=levelset(f,img,1,0,30,60,0.2,0.1,0.1,g,2) ;
%g=ones(size(f)) ;
%f1=levelset(f,img,0,0,10,110,1,1,0.1,g) ;

figure(3) ;imagesc(img) ; colormap(gray) ; axis equal ; axis tight ; axis ...
    off ; hold on ; 
contour(f1,[0 0],'r') ; hold off ; colorbar ;

print -depsc output_images/levelset_output.eps
figure(4) ;imagesc(f1,[-100 100]) ; colorbar ;
hold on ; 
contour(f1,[0 0],'k') ; hold off ; 
print -depsc output_images/levelset_lsetoutput.eps
