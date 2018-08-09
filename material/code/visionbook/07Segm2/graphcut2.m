% Graphcut example, using a Matlab wrapper of Shai Bagon 
%  http://www.wisdom.weizmann.ac.il/~bagon/matlab.html
% for the code of Olga Veksler
% http://www.csd.uwo.ca/faculty/olga/code.html,
% Vladimir Kolmogorov, Yuri Boykov and Ramih Zabih.
%
% 		[1] Efficient Approximate Energy Minimization via Graph Cuts 
%		    Yuri Boykov, Olga Veksler, Ramin Zabih, 
%		    IEEE transactions on PAMI, vol. 20, no. 12, p. 1222-1239, November 2001. 
%
%
% 	[2] What Energy Functions can be Minimized via Graph Cuts?
% 	    Vladimir Kolmogorov and Ramin Zabih. 
% 	    To appear in IEEE Transactions on Pattern Analysis and Machine Intelligence (PAMI). 
% 	    Earlier version appeared in European Conference on Computer Vision (ECCV), May 2002. 

%             		[3] An Experimental Comparison of Min-Cut/Max-Flow Algorithms
% 		    for Energy Minimization in Vision.
% 		    Yuri Boykov and Vladimir Kolmogorov.
% 		    In IEEE Transactions on Pattern Analysis and Machine Intelligence (PAMI), 
% 		    September 2004

ImageDir='images/';%directory containing the images
addpath('..') ;
cmpviapath('..') ;
img=im2double(imresize(imread([ImageDir 'rhino2.jpg']),0.125)) ;
figure(1) ; imagesc(img) ; axis image
[ny,nx,nc]=size(img) ;
imgc=applycform(img,makecform('srgb2lab')) ; 
d=reshape(imgc(:,:,2:3),ny*nx,2) ;
d(:,1)=d(:,1)/max(d(:,1)) ; d(:,2)=d(:,2)/max(d(:,2)) ;
%d=d ./ (repmat(sqrt(sum(d.^2,2)),1,3)+eps()) ;
k=4 ; % number of clusters
%[l0 c] = kmeans(d, k,'Display','iter','Maxiter',100);
[l0 c] = kmeans(d, k,'Maxiter',100);
l0=reshape(l0,ny,nx) ;
figure(2) ; imagesc(l0) ; axis image ;

%c=[ 0.37 0.37 0.37 ; 0.77 0.73 0.66 ; 0.64 0.77 0.41 ; 0.81 0.76 0.58 ; ...
%    0.85 0.81 0.73 ] ;

%c=[0.99 0.76 0.15 ; 0.55 0.56 0.15 ] ;

%c=[ 0.64 0.64 0.67 ; 0.27 0.45 0.14 ] ;
%c=c ./ (repmat(sqrt(sum(c.^2,2)),1,3)+eps()) ;

% Data term
Dc=zeros(ny,nx,k) ;
for i=1:k,
  dif=d-repmat(c(i,:),ny*nx,1) ;
  Dc(:,:,i)= reshape(sum(dif.^2,2),ny,nx) ;
end ;

% Smoothness term
Sc=(ones(k)-eye(k)) ;

% Edge terms
g = fspecial('gauss', [13 13], 2);
dy = fspecial('sobel');
vf = conv2(g, dy, 'valid');

Vc = zeros(ny,nx);
Hc = Vc;

for b=1:nc,
    Vc = max(Vc, abs(imfilter(img(:,:,b), vf, 'symmetric')));
    Hc = max(Hc, abs(imfilter(img(:,:,b), vf', 'symmetric')));
end



gch = GraphCut('open', 1*Dc, Sc) ; % ,exp(-5*Vc),exp(-5*Hc));
[gch l] = GraphCut('expand',gch);
gch = GraphCut('close', gch);

label=l(100,200) ;
lb=(l==label) ;
lb=imdilate(lb,strel('disk',1))-lb ; 

figure(3) ; image(img) ; axis image ; hold on ;
contour(lb,[1 1],'r') ; hold off ; title('no edges') ;

figure(4) ; imagesc(l) ; axis image ; title('no edges') ;

gch = GraphCut('open', Dc, 5*Sc,exp(-10*Vc),exp(-10*Hc));
[gch l] = GraphCut('expand',gch);
gch = GraphCut('close', gch);

lb=(l==label) ;
lb=imdilate(lb,strel('disk',1))-lb ; 

figure(5) ; image(img) ; axis image ; hold on ;
contour(lb,[1 1],'r') ; hold off ; title('edges') ;

figure(6) ; imagesc(l) ; axis image ; title('edges') ;

