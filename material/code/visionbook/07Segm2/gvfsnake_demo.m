img=dicomread('images/ctslice.dcm') ;

f=double(img) ; imagesc(f)
%img=imread('images/flower.jpg') ;
imagesc(f) ; 
%img=imresize(img,0.25) ;
%[x,y]=snakeinit() ;
%save ctplic x y
load ctplic
%x=0.25*x ; y=0.25*y ;

f=f-min(f(:)) ;
f=f/max(f(:)) ;
h=fspecial('gaussian',20,3) ;
f=imfilter(double(f),h,'symmetric') ;
% external force
[px,py]=gradient(f) ;
f=sqrt(px.^2+py.^2) ;
f=f.*(f>0.02) ;
%[ux,uy]= mgvf(f) ;
[ux,uy]= gvf(f) ;
kappa=1/(max(max(px(:)),max(py(:)))) ;
imagesc(f) ;

figure(3) ;
[x,y]=snake(x,y,0.1,0.01,0.3*kappa,0,ux,uy,0.4,1,img);

figure(3) ;
clf ; imagesc(img) ;  hold on ;
plot([x;x(1)],[y;y(1)],'r','LineWidth',2) ; hold off ;
