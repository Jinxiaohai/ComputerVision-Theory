% COOC_DEMO demo for cooc
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, Petr Nemecek 2006-2007

% $Id: cooc_demo_decor.m 1074 2007-08-14 09:45:42Z kybic $
clear all;

addpath ../.
cmpviapath('../.');
% create a directory for output images
% if needed and does not already exist
out_dir = 'output_images/'
if (exist(out_dir)~=7)
  mkdir(out_dir);
end


imdir='images/';

% Co-occurrence matrix for an asymmetrical relationship defined by southern or
% eastern 4-neighbor or identity. Compare the length of the boundary of two 
% image regions of different brightness with elements off the diagonal of the 
% co-occurrence matrix.

a=zeros(6,6);
a(3:5,3:4)=5;
a(2,5:6)=3;
maxint = max(max(a));
minint = min(min(a));
fig=figure(1); clf; 
fig = showim_values(a,[],fig);
title('synthetic image')
xlabel('column coordinates')
ylabel('row coordinates')

exportfig(gcf,[out_dir,'cooc_synth_image.eps']);

relations = [0 1; 0 0];
fig=figure(3), clf
maxrel = max(max(relations));
minrel = min(min(relations));
im_rel = zeros(maxrel-minrel+1);
idxmat = minrel:maxrel;
for i=1:size(relations,1),
  im_rel(find(idxmat==relations(i,1)),find(idxmat==relations(i,2)))=1;
end
fig=showim_values(im_rel,[],fig);
lbls = [];
for i=idxmat,
  lbls = [lbls;sprintf('%1d',i)];
end
set(gca,'XTick',1:size(im_rel,2),'XTickLabel',lbls,'YTick',1:size(im_rel,1),'YTickLabel',lbls)
title('matrix of spatial relations')
xlabel('column shift')
ylabel('row shift')
exportfig(gcf,[out_dir,'cooc_synth_relations.eps']);

c_matrix=cooc(uint8(a), relations);
[i,j,v]=find(c_matrix);

disp('Nonzero elements of the co-occurrence matrix (Identity + 4-neighbour S,E):');
disp('1st column= row index, 2nd column= column index 3rd column= value');
[i j v]

fig=figure(2); clf 
c = c_matrix(1:maxint+1,1:maxint+1);
cfg.colormapping = 'direct';
fig = showim_values(c,cfg,fig);
lbls = [];
for i=0:maxint,
  lbls = [lbls;sprintf('%3d',i)];
end
set(gca,'XTick',[1:maxint+1],'XTickLabel',lbls,'YTick',[1:maxint+1],'YTickLabel',lbls)
ylabel('intensity')
xlabel('intensity in relation(s)')
title('relevant part of the co-occurrence matrix')
exportfig(gcf,[out_dir,'cooc_synth_coocmat.eps']);



% Sum of the non-diagonal elements on positions (i,j) and (j,i) gives the
% the length of the border between area of intensity i-1 and intensity j-1.

return

% Compare the above result with elements of a co-occurrence matrix for a 
% relationship defined by southern or eastern or western or 
% northern 4-neighbor or identity:

c_matrix=cooc(uint8(a), [1 0;-1 0;0 1;0 -1;0 0]);
[i,j,v]=find(c_matrix);
disp('Nonzero elements of the co-occurence matrix (Identity + 4-neighbour S,E,N,W):');
disp('1st column= row index, 2nd column= column index 3rd column= value');
[i j v]

% Non-diagonal element on position (i,j) is equal to the length of the border 
% between area of intensity i-1 and intensity j-1.

% Take a natural image and create its co-occurrence matrix 
% for asymmetrical relationship defined by southern or eastern 4-neighbor 
% or identity. Compare the elements on the diagonal of the co-occurrence 
% matrix with the image histogram (identical). 
imname='10.png';
img= imread([imdir imname]);
c_matrix=cooc(img, [1 0;0 1;0 0]);
D=diag(c_matrix);
[counts,x]=imhist(img);
figure;stem(counts);
hold on;
plot(D, 'r-','linewidth',2); 
legend('image histogram','co-oc. matrix diagonal')
title('Comp. of the image histogram and diagonal elem. of the co-occurrence matrix ')

imname='10_contrast.png';
img2= imread([imdir imname]);
c_matrix2=cooc(img2, [1 0;0 1;0 0]);

% Compare co-occurrence matrices of a sharp and smooth image.
figure; subplot(1,2,1);imshow(img);subplot(1,2,2);imshow(img2);
figure; 
subplot(1,2,1);imagesc(c_matrix,[1 1680]);grid;axis equal;
title('smooth image co-oc. m.');ylim([0.5 256.5]);
subplot(1,2,2);imagesc(c_matrix2,[1 1680]);grid;axis equal;
title('sharp image co-oc. m.');ylim([0.5 256.5]);
