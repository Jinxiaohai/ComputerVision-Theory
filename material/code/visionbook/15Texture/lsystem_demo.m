% LSYSTEM_DEMO --- Examples for lsystem
% CMP   Vision Algorithms http://visionbook.felk.cvut.cz
%
% Example
% 
% Many different shapes and textures can be generated using L-systems. Here
% we present a few:{Mostly taken from the Fractint tutorial 
% http://spanky.triumf.ca/www/fractint/lsys/tutor.html.}
%
% [Koch snowflake] (Figure ??a):

close all
clear all ; 
addpath('..') ;
cmpviapath('..') ;

if (exist('output_images')~=7)
  mkdir('output_images');
end


if 1,
clear rules
figure(1) ; 
rules(1).left = 'F';
rules(1).right = 'F+F--F+F';
lsystem( 'F--F--F', rules, pi/3, 3 );
axis equal ; axis off ; 
exportfig(gcf,'output_images/lsystem1.eps') ;
end

%
% [Sierpinski triangle/gasket] (Figure ??b):


if 1
figure(2) ; % Sierpinski gasket
clear rules ;
rules(1).left = 'F';
rules(1).right = 'F+F-F-F+F';
lsystem( 'F', rules, 2/3*pi, 5 );
axis equal ; axis off ;
exportfig(gcf,'output_images/lsystem2.eps') ;
end

%
% [Rectangular grid] (Figure ??c):

if 1
figure(3) ; % Rectangular grid
clear rules ;
rules(1).left = 'F';
rules(1).right = 'F[+F][-F]F';
lsystem( 'F', rules, pi/2, 5 );
axis equal ; axis off ;
exportfig(gcf,'output_images/lsystem3.eps') ;
end

%
% [Triangular grid with irregular borders] (Figure ??d):

if 1
figure(4) ; % triangular grid
clear rules ;
rules(1).left = 'X';
rules(1).right = 'FY[+FY][--FY]FY';
rules(2).left = 'Y';
rules(2).right = 'FX[++FX][-FX]FX';
rules(3).left = 'F'; 
rules(3).right = '';
lsystem( 'X', rules, pi/3, 4 );
axis equal ; axis off ;
exportfig(gcf,'output_images/lsystem4.eps') ;
end


%
% [Hexagonal grid] (Figure ??e):

if 1
figure(5) ; % hexagonal grid
clear rules ;
rules(1).left = 'F';
rules(1).right = '-F+F+[+F+F]-';
lsystem( 'F', rules, pi/3, 5 );
axis equal ; axis off ;
exportfig(gcf,'output_images/lsystem5.eps') ;
end

%
% [Hilbert space-filling curve] (Figure ??f):

if 1
figure(6) ; % hexagonal grid
clear rules ;
rules(1).left = 'L';
rules(1).right = '+RF-LFL-FR+';
rules(2).left = 'R';
rules(2).right = '-LF+RFR+FL-';
lsystem( 'L', rules, pi/2, 5 );
axis equal ; axis off
exportfig(gcf,'output_images/lsystem6.eps');
end


% Branches

if 1,  
figure(7) ;  % branch
clear rules ;
rules(1).left = 'F';
rules(1).right = 'FF';
rules(2).left = 'X'; 
rules(2).right = 'F[+X]F[-X]+X';
lsystem( 'X', rules, pi/9, 5 );
axis equal ; axis off
exportfig(gcf,'output_images/lsystem7.eps');
end

% Bush

if 1,
figure(8) ; % bush
clear rules ;
rules(1).left = 'F';
rules(1).right = 'FF-[-F+F+F]+[+F-F-F]';
lsystem( '++++F', rules, pi/8, 4 );
axis off
exportfig(gcf,'output_images/lsystem8.eps');
end

