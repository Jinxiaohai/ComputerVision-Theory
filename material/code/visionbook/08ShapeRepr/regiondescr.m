function phi=regiondescr(im) ;
% REGIONDESCR Calculate region descriptors
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% 
% Calculate moment based region descriptors varphi_1,...,varphi_7
%  which are invariant to 
% translation, rotation, and scale
% changes. They are usually applied on binary images with all background pixels
% set to zero and pixels of our object of interest (foreground) set
% to one. This makes the descriptors sensitive to the
% shape of the object only. It is also possible to keep the intensity
% information in the foreground pixels (the grayscale case), which
% also makes the descriptors sensitive to the object appearance. 
% 
% The main application of  region descriptors is to recognize the same 
% object in another image by its shape (and possibly appearance), even
% though its position, orientation and scale might be different.
%
% Usage: phi = regiondescr(im)
% Inputs:
%   img  [m x n]  Input image with background pixels set to zero.
% Outputs:
%   phi  [1 x 7]  The descriptors
%    varphi_1,...,varphi_7.

  
% Start by creating the coordinate grid xi, yi which
% enables us to calculate the moments in a vectorized way in the function
% regionmoment (below). However, creating the grid with
% meshgrid takes a lot of time, which is why we share
% xi,yi for all calls to regionmoment.

[ny,nx] = size(im);
[xi,yi] = meshgrid( 1:nx, 1:ny );


% To ensure translation invariance, we use central moments
% mu_ . This is easily
% achieved by calculating the center of gravity xc,
% yc and centering the grid xi, yi there. The
% moment mu_ is just a sum of all pixels.

m00 = sum( im(:) );
xc = regionmoment(im,1,0,xi,yi) / m00;
yc = regionmoment(im,0,1,xi,yi) / m00;
xi = xi-xc;  yi = yi-yc;

% We proceed by calculating the un-scaled (scale independent) central moments
% _  that we will need.

theta20 = regionmoment(im,2,0,xi,yi) / (m00^2);
theta02 = regionmoment(im,0,2,xi,yi) / (m00^2);
theta11 = regionmoment(im,1,1,xi,yi) / (m00^2);
theta30 = regionmoment(im,3,0,xi,yi) / (m00^2.5);
theta03 = regionmoment(im,0,3,xi,yi) / (m00^2.5);
theta21 = regionmoment(im,2,1,xi,yi) / (m00^2.5);
theta12 = regionmoment(im,1,2,xi,yi) / (m00^2.5);

% Finally, we evaluate the descriptors varphi_1,...,varphi_7
% [Equation :--].

phi = zeros(1,7);
phi(1) = theta20 + theta02;
phi(2) = (theta20-theta02)^2 + 4*theta11^2;
phi(3) = (theta30-3*theta12)^2 + (3*theta21-theta03)^2;
phi(4) = (theta30+theta12)^2 + (theta21+theta03)^2;
phi(5) = (theta30-3*theta12)*(theta30+theta12)* ...
           ((theta30+theta12)^2-3*(theta21+theta03)^2) + ...
         (3*theta21-theta03)*(theta21+theta03)* ...
           (3*(theta30+theta12)^2-(theta21+theta03)^2);
phi(6) = (theta20-theta02)*((theta30+theta12)^2-(theta21+theta03)^2) + ...
           4*theta11*(theta30+theta12)*(theta21+theta03);
phi(7) = (3*theta21-theta03)*(theta30+theta12)* ...
	   ((theta30+theta12)^2-3*(theta21+theta03)^2) - ...
	 (theta30-3*theta12)*(theta21+theta03)* ...
	   (3*(theta30+theta12)^2-(theta21+theta03)^2);


% Usage: mu = regionmoment(im,p,q,xi,yi)
%
% regionmoment calculates the moments mu_ for 
% image im, where xi, yi is the grid obtained by 
% meshgrid, shifted to the center of gravity.

function mu = regionmoment(im,p,q,xi,yi) ;

mu = xi.^p .* yi.^q .* im;
mu = sum( mu(:) );

