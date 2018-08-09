% POINTDISTRMODEL_DEMO demo for pointdistr
% CMP Vision Algorithms http://visionbook.felk.cvut.cz

clear all ; close all ;
dataDir='./data/' ;

addpath('..') ;
cmpviapath('..') ;

if (exist('output_images')~=7)
  mkdir('output_images');
end


% Example
% 
%
% We use the hand point data made available by T. Cootes
%  (http://www.isbe.man.ac.uk/ bim/data/hand_data.html).
% Figure ??a shows an example of one shape, drawn
% as follows:

xy = readpointfile( [dataDir 'hand.0.pts'] );
drawcontour(xy,1) ;
axis auto ; axis equal ; axis ij ; 


exportfig(gcf,'output_images/pdm1.eps') ;

% Functions readpointfile and drawcontour are given below.
% 
% We read all 18 datasets and store them into a matrix pts, each
% dataset to  one column. 
m = 18;
n = 2*size(xy,2);
pts = zeros(n,m);
for i = 1:m
  xy = readpointfile( [dataDir 'hand.' num2str(i-1) '.pts'] );
  pts(:,i) = xy(:);
end

figure(2) ;
clf ; hold on ;
for i=[1 8],
  drawcontour(reshape(pts(:,i),2,[]),0) ;
end ;
hold off ;
axis ij ; axis equal ; axis off ;
exportfig(gcf,'output_images/pdm2.eps') ;

% Unaligned shapes 1 and 8 are shown in Figure ??b.
% Figure ??b shows the same shape after alignment using
figure(3) ;
clf ; hold on ;
ptransf = pointalign( pts(:,1), pts(:,8) );
drawcontour(reshape(pts(:,1),2,[]),0) ;
drawcontour(reshape(ptransf,2,[]),0) ;
hold off ;
axis auto ; axis equal ; axis ij ; axis off ;
exportfig(gcf,'output_images/pdm3.eps') ;

% 
% Create the point distribution model. Setting alpha=0.95 (accounting
% for 95% of the variations) needs 5 eigenvectors.


figure(4) ;
clf ; hold on ;
alpha=0.95 ;
[P,pmean,lambda]=pointdistrmodel(pts,alpha,1) ;
drawcontour(reshape(pmean,2,[]),2) ;
hold off ;
axis auto ; axis equal ; axis ij ;  axis off ;
exportfig(gcf,'output_images/pdm4.eps') ;

% The mean shape and all aligned shapes are shown in
% Figure ??a. We can now show the principal
% modes of variation of the shape. Commands

for i=1:5,
figure(4+i) ;
clf ; hold on ;
drawcontour(reshape(pmean,2,[]),2) ;
p1 = pmean - 3*sqrt(lambda(i))*P(:,i);
p2 = pmean + 3*sqrt(lambda(i))*P(:,i);
drawcontour(reshape(p1,2,[]),3) ;
drawcontour(reshape(p2,2,[]),4) ;
hold off ;
axis auto ; axis equal ; axis ij ; axis off ;
exportfig(gcf,['output_images/pdm' num2str(4+i) '.eps' ]) ;

end ;


% calculate the extremal variations corresponding to +- 3sigma for mode
% i. Figures ??bc illustrate
% these variations for the first principal modes corresponding to the two
% largest eigenvalues. Note that the first mode makes the fingers spread
% out, while the second mode makes them move right and left.

% Finally, we save the learned model for later analysis .
save handpdm pmean P lambda

