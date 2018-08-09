function [XX,fh]=dispImgs(X,cols,gap,ihw,fh)
% DISPIMGS  Display images arranged in a matrix-like form. 
% CMP Vision Algorithms cmpvia@cmp.felk.cvut.cz

% XX = dispImgs(X,cols,gap,ihw,fh
%
% Inputs:
% X  [M x N]  An input compound image. 
% 
% cols  (default N^1/2)  Number of columns of matrix. Elements are the images shown. 
% gaps  (default 0)  Size of white gaps between images.  
% ihw   (default [M^1/2, M^1/2])  Vector containing image dimensions.
% fh    [1]  Figure handle. If not specified a new figure window is opened.
% 
% Outputs:
% XX  Matrix with resulting image data.
% fh  Figure handle.


% History:
% $Id: dispImgs_decor.m 1041 2007-08-10 10:34:31Z svoboda $
%
% 2007-07-05 V. Hlavac
% 2007-07-10 T. Svoboda: better decor, optional par fh
% 2007-08-09 T. Svoboda: refinement for better looking of m-files
%
% Courtesy A. Leonardis, D. Skocaj
% see http://vicos.fri.uni-lj.si/danijels/downloads

[M,N]=size(X);
if nargin<2 cols=floor(sqrt(N)); end;
if nargin<3 gap=0; end;
if nargin<4 ihw=[sqrt(M),sqrt(M)]; end;
if nargin<5 fh = figure; end; % new figure

ih=ihw(1);iw=ihw(2);
maxv=max(X(:));
rows=floor(N/cols);
XX=zeros((rows*ih)+(rows-1)*gap,(cols*iw)+(cols-1)*gap)+maxv;

for i=1:N
   a=(iw+gap)*mod(i-1,cols)+1;
   b=(iw+gap)*mod(i-1,cols)+iw;
   c=(ih+gap)*(floor((i-1)/cols))+1;
   d=(ih+gap)*(floor((i-1)/cols))+ih;
   XX(c:d,a:b)=reshape(X(:,i)',ih,iw);
end;

xxmax=max(XX(:));
xxmin=min(XX(:));

fh = figure(fh);
imshow((XX-xxmin)/(xxmax-xxmin));
axis off;
