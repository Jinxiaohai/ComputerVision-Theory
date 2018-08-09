%Test of corner detector(HCD) (harris.m): 
% CMP Vision Algorithms cmpvia@cmp.felk.cvut.cz
%
% See also: harris

% History
% 2006-11-01 Tomas Svoboda
% 2006-11-03 Vaclav Hlavac, added standard headder

%Comparison with the MEX implementation of M. Pejcoch (harris_mex.mexglx)
%The aim is to verify, that both implementations find SIMILAR corner
%points. (Not EQUAL because the algorithms differ a bit.)
%harris_test computes the  corner positions with both implementations of HCD 
%for three images and displays the corner positions in the plotted images.
%harris_test displays also in the command line the time needed to process 
%the images for  both implementations.
%CAUTION: harris_mex.mexglx and this file has to be run on 32bit machine!!!!
%Running on 64 bit machines cause erroneous results!

disp('CAUTION: harris_mex.mexglx and this file has to be run on 32bit machine!!!!') 
disp('Running on 64 bit machines cause erroneous results! ');
ImageDir='images/';%directory containing the images


img=zeros(600);img(10:100,10:100)=255;img(30:60,30:60)=0;img=uint8(img);
disp('IMAGE #1 **********************************************************')
tic 
P1=harris_mex(img,1,2,40,0);
disp(['Time elapsed harris_mex.mexglx: ' num2str(toc) ' sec'])
tic 
N1=harris(img,1,2,25000);
disp(['Time elapsed harris.m: ' num2str(toc) ' sec' ])


figure;imshow(img);hold on;
plot(P1(:,2),P1(:,1),'ro');
plot(N1(:,2),N1(:,1),'b+');
hold off;
legend('harris\_mex.mexglx  - (M. Pejcoch)','harris.m - (P. Nemecek)');



disp('IMAGE #2 **********************************************************')
img=imread([ImageDir 'figures.jpg']);
tic 
P2=harris_mex(img,1,2,40,0);
disp(['Time elapsed harris_mex.mexglx: ' num2str(toc) ' sec'])
tic 
N2=harris(img,1,2,25000);
disp(['Time elapsed harris.m: ' num2str(toc) ' sec' ])


figure;imshow(img);hold on;
plot(P2(:,2),P2(:,1),'ro');
plot(N2(:,2),N2(:,1),'b+');
hold off;
legend('harris\_mex.mexglx  - (M. Pejcoch)','harris.m - (P. Nemecek)');



disp('IMAGE #3 **********************************************************')
img=imread([ImageDir 'figures2.jpg']);
tic 
P3=harris_mex(img,1,2,40,0);
disp(['Time elapsed harris_mex.mexglx: ' num2str(toc) ' sec'])
tic 
N3=harris(img,1,2,25000);
disp(['Time elapsed harris.m: ' num2str(toc) ' sec' ])

figure;imshow(img);hold on;
plot(P3(:,2),P3(:,1),'ro');
plot(N3(:,2),N3(:,1),'b+');
legend('harris\_mex.mexglx  - (M. Pejcoch)','harris.m - (P. Nemecek)');
hold off;


