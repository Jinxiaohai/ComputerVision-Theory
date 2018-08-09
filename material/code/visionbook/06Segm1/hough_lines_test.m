% HOUGH_LINES_TEST
% Test file verifiing the function of hough_lines.m


% History
% $Id: $
%
% 2006-06 Petr Nemecek create


ImageDir='images/';%directory containing the images
file2='figures2.jpg';
file1='chess.jpg';

% Proof the function on a black image with white boundaries (boundary pixels 
% are edges)-this should proof, the algorithm works well for the border
% pixels (that the border i.e. the limit values don't cause unexpected events):
im_edge=ones(100);
im_edge(2:99,2:99)=zeros(98);
hough_lines(im_edge, pi/360, 1, 0.5,'p');

% Proof the function on a normal image; find lines correctly:
im_inp=imread([ImageDir file2]);
if exist('canny')
	[im_edge]=canny(im_inp, 3);
else 
        error('To use this demo canny.m needs to be installed in the working directory or in a directory on the MATLAB path.');  
end 
hough_lines(im_edge, pi/360, 1, 0.5,'p');




% VERIFY, THAT THE EXAMPLES DESCRIBED IN THE COMMENT LINES OF hough_lines.m 
% WORK WELL:
im_inp=imread([ImageDir file1]);
[im_edge, grad_mag]=canny(im_inp, 3);
[r,theta,X_points,Y_points,acc]=hough_lines(im_edge, pi/180, 2, 0.3);

m=size(im_inp,1);
figure;imshow(im_inp);
hold on;
plot(X_points,m-Y_points, 'r-', 'LineWidth',3);
hold off;

[im_edge, grad_mag]=canny(im_inp, 3);
[r,theta,X_points,Y_points,acc]=hough_lines(grad_mag, pi/180, 2, 0.4);

figure;imshow(im_inp);
hold on;
plot(X_points,m-Y_points, 'r-', 'LineWidth',3);
hold off;

figure;
imagesc(acc); 
axis equal; 
colorbar;
xlabel('theta');
ylabel('r');




