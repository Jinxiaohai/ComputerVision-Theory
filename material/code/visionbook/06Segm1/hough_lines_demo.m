% HOUGH_LINES_DEMO_2 showing the usage of hough_lines.m
% CMP Vision Algorithms http://visionbook.felk.cvut.cz

addpath('..') ; cmpviapath('..') ;

ImageDir='images/';%directory containing the images

if (exist('output_images')~=7)
  mkdir('output_images');
end

% Example
% The function hough_lines is applied to the output of an
% edge detector (function edge).
im = imread( [ImageDir 'chess.jpg'] );
im_edge = edge( im, 'canny', 0.02, 2.5 );
[s,theta,acc] = hough_lines( im_edge, pi/180, 2, 0.45 );

figure(1) ; 
imagesc(im); % title('input image');
axis image ; axis off ; colormap(gray) ;
exportfig(gcf,'output_images/hough_input.eps') ;

figure(2) ; 
imagesc(-im_edge); % title('output image');
axis image ; axis off ; colormap(gray) ;
exportfig(gcf,'output_images/hough_edges.eps')

figure(3) ; clf ;
imagesc(-acc); % title('output image');
axis off ; colormap(gray) ;
exportfig(gcf,'output_images/hough_acc.eps')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

    %                       |/
    %               (1)     o<--int_2y
    %          |           /|  
    %          |  int_1x  / |
    %          |       \ /  |
    %       ___|________o___|___
    %          |       /    |
    %          |      /     | 
    %     (4)  | I M / A G E|  (2)
    %          |    /       |
    %          |   /        |
    %       ___|__o_________|___
    %          | / \        |
    %          |/   int_3x  |
    %  int_4y->o  
    %         /|    (3)
             
    
cos_theta=cos(theta) ;
sin_theta=sin(theta) ; 
[m,n]=size(im_edge);
center_x=n/2;
center_y=m/2;
    
    
warning('off','MATLAB:divideByZero');
int_1x=((s-sin_theta*(center_y))./cos_theta)+center_x;
int_3x=((s-sin_theta*(-center_y))./cos_theta)+center_x;
int_4y=((s-cos_theta*(-center_x))./sin_theta)+center_y;
int_2y=((s-cos_theta*(center_x))./sin_theta)+center_y;
warning('on','MATLAB:divideByZero');

quadrant_1=(int_1x>=0) & (int_1x<=n);
quadrant_3=(int_3x>=0)&(int_3x<=n);
quadrant_2=(int_2y>0)&(int_2y<m);
quadrant_4=(int_4y>0) & (int_4y<m);

X_points=zeros(length(int_1x),2);
Y_points=zeros(length(int_1x),2);
X_points(quadrant_4,1)=0;
Y_points(quadrant_4,1)=int_4y(quadrant_4);
X_points((~quadrant_4)&quadrant_1,1)=int_1x((~quadrant_4)&quadrant_1);
Y_points((~quadrant_4)&quadrant_1,1)=m;
X_points((~quadrant_4)&(~quadrant_1)&quadrant_3,1)=...
int_3x((~quadrant_4)&(~quadrant_1)&quadrant_3);
Y_points((~quadrant_4)&(~quadrant_1)&quadrant_3,1)=0;

X_points(quadrant_2,2)=n;
Y_points(quadrant_2,2)=int_2y(quadrant_2);
X_points((~quadrant_2)&quadrant_3,2)=int_3x((~quadrant_2)&quadrant_3);
Y_points((~quadrant_2)&quadrant_3,2)=0;
X_points((~quadrant_2)&(~quadrant_3)&quadrant_1,2)=int_1x((~quadrant_2)&...
                                                  (~quadrant_3)&quadrant_1);
Y_points((~quadrant_2)&(~quadrant_3)&quadrant_1,2)=m;

X_points=X_points';
Y_points=Y_points';

figure(4) ; 
imagesc(im); % title('output image');
axis image ; axis off ; colormap(gray) ;
hold on
plot(X_points,m-Y_points, 'r-', 'LineWidth',3);
hold off;
exportfig(gcf,'output_images/hough_lines.eps')





