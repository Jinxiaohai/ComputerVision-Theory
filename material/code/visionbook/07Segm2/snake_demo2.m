

img=imread('images/bird.png') ;
imagesc(img) ; 
f=double(img) ; f=f(:,:,1)*0.5+f(:,:,2)*0.5-f(:,:,3)*1 ;
%[x,y]=snakeinit() ;
%save birdxy x y
load birdxy

f=f-min(f(:)) ;
f=f/max(f(:)) ;
f=(f>0.25).*f ;
h=fspecial('gaussian',20,3) ;
f=imfilter(double(f),h,'symmetric') ;
imagesc(f) ;
% external force
[px,py] = gradient(-f);
kappa=1/(max(max(px(:)),max(py(:)))) ;

[x,y]=snake(x,y,0.1,0.1,0.3*kappa,-0.05,px,py,0.4,1,f);

figure(2) ;
clf ; imagesc(img) ;  hold on ;
plot([x;x(1)],[y;y(1)],'r','LineWidth',2) ; hold off ;

