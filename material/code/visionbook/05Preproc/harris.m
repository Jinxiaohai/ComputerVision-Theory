function [corners]=harris(im,der_sigma,int_sigma,threshold,VERBOSITY);
%HARRIS Harris corner detector.
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Petr Nemecek, Tomas Svoboda, 2006-2007
% 
% The Harris corner detector  detects interest points
% in the image  and has found a place in many computer vision 
% algorithms. It is a core part
% of many tracking and image registration applications.
%
% Usage: corners = harris(im,der_sigma,int_sigma,threshold,VERBOSITY)
% Inputs:
%   im  [m x n]  Input image to be processed.
%   der_sigma  1x1  Derivative scale - standard deviation of the 
%              Gaussian filter used for pre-smoothing.
%   int_sigma  1x1  Integrative scale - standard deviation of the 
%              Gaussian filter used for summing over the 
%              pixel neighborhood.
%   threshold  1x1  Corner response function threshold. Values of the corner 
%              response function below this threshold are neglected.
%   VERBOSITY  (default 0)  Verbosity of the function. If set to 2
%              many intermediate steps are graphically visualized.
% Outputs:
%   corners  [N x 3]  Each row of 3-column matrix represents
%     one corner point. The first two columns describe the position
%     of the corner in im_inp (first column = y
%     coordinate, second column = x coordinate). The third column
%     contains the value of the corner response function.
% See also: conv2.
% 

  

% History
% $Id: harris_decor.m 1074 2007-08-14 09:45:42Z kybic $
%
% 2006-04     Petr Nemecek: created
% 2006-11-01  Tomas Svoboda: extended comments 
%                            VERBOSITY introduced
% 2006-11-02  Tomas Svoboda: essential speedup in non-maxima suppression
% 2006-11-10  Jan Kybic: converting to harris.decor.m
% 2007-02-28  Tomas Svoboda: more comments according to new specs
% 2007-05-24  VZ: typo
% 2007-08-09  TS: refinement for better looking of the m-file


% the higher VERBOSITY to more figures created
% useful for debugging and teaching
if nargin<5,
  VERBOSITY=0; %1,2 possible
end

% create a directory for output images
% if necessary, and does not already exist
out_dir = './output_images/';
if (VERBOSITY>=1 & (exist(out_dir)~=7))
  mkdir(out_dir)
end

if exist('iptcheckinput')
    iptcheckinput(im, {'uint8'}, {'2d'}, mfilename, 'im', 1);
    iptcheckinput(der_sigma, {'numeric'}, {'real','scalar','positive'}, mfilename, 'der_sigma', 2);
    iptcheckinput(int_sigma, {'numeric'}, {'real','scalar','positive'}, mfilename, 'int_sigma', 3);
    iptcheckinput(threshold, {'numeric'}, {'real','scalar','positive'}, mfilename, 'threshold', 4);
end

% Conversion of the limiting variables to double precision (Integers cause
% errors in the computations):
der_sigma = double(der_sigma);
int_sigma = double(int_sigma);

% Convert im to double precision. Computations in integer precision yields 
% inadequate results due to averaging.
im = double(im);

if nargin<4
    threshold = 25000; %[in accord with Burge&Burger]%
end;    
if nargin<3
    int_sigma = 2;     %[in accord with M. Urban's implementation]%[
end;    
if nargin<2
    der_sigma = 1;     %[in accord with M. Urban's implementation]%
end;    

%  Set the parameter kappa of the response function, usually
% kappa = 0.04 ... 0.06, at most 0.25 .
kappa = 0.04;


% Firstly, the image is pre-smoothed. We create a 1D Gaussian filter and 
% smooth by convolving in both x
% and y directions. This is equivalent to convolving with a 2D Gaussian filter 
% but much faster thanks to separability.
der_size_half = floor( 3*der_sigma ); % half of the window size
x = -der_size_half:1:der_size_half; 
Filter_der1D = exp(-(x).^2/(2*der_sigma^2)) / (der_sigma*sqrt(2*pi));
if VERBOSITY>=1
  figure(10),
  plot(x,Filter_der1D,'*-')
  title(sprintf('Kernel for pre-smoothing of the image, sigma=%2.2f',der_sigma));
  exportfig(gcf,[out_dir,'harris_kernel.eps'])
end
im_smoothed = conv2( Filter_der1D, Filter_der1D', im, 'same' );

if VERBOSITY>=1
  figure(11),
  image(im); colormap(gray(256)); axis image;
  title('original image')
  image(im_smoothed); colormap(gray(256)); axis image;
  title('smoothed image')
  exportfig(gcf,[out_dir,'harris_smoothed.eps'])
end

% 
% Compute image derivatives by convolution with kernel
% [1  0  -\!\!1] in both x and y directions. In fact, twice
% the value of the derivative is computed. Note also that
% a different 2-tap filter is used for the border pixels.

Filter_derx = [1 0 -1];
Filter_dery = Filter_derx';

% compute the derivative with respect to x 
im_derx = conv2( im_smoothed, Filter_derx, 'same' );
% compute the derivative with respect to x at the border pixels 
im_derx(:,1)   = 2*(im_smoothed(:,2)  -im_smoothed(:,1));
im_derx(:,end) = 2*(im_smoothed(:,end)-im_smoothed(:,end-1));

% compute the derivative with respect to y 
im_dery = conv2( im_smoothed, Filter_dery, 'same' );
% compute the derivative with respect to y at the border pixels 
im_dery(1,:)   = 2*(im_smoothed(2,:)  -im_smoothed(1,:));
im_dery(end,:) = 2*(im_smoothed(end,:)-im_smoothed(end-1,:));


if VERBOSITY>=2
  figure(20),
  imagesc(im_derx), colormap(jet(256)), axis image, colorbar,
  title('x-derivatives');
  exportfig(gcf,[out_dir,'harris_derx.eps'])
  figure(21)
  imagesc(im_dery), colormap(jet(256)), axis image, colorbar,
  title('y-derivatives');
  exportfig(gcf,[out_dir,'harris_dery.eps'])
end

%
% Precompute quadratic terms of the derivatives.
der_x2 = im_derx.^2;  der_y2 = im_dery.^2;
der_xy = im_derx.*im_dery;

if VERBOSITY>=2
  figure(22),
  imagesc(der_x2), colormap(jet(256)), axis image, colorbar,
  title('(x-derivatives)^2');
  figure(23)
  imagesc(der_y2), colormap(jet(256)), axis image, colorbar,
  title('(y-derivatives)^2');
  figure(24)
  imagesc(der_xy), colormap(jet(256)), axis image, colorbar,
  title('(x-derivatives).*(y-derivatives)');
end


%
% The derivative terms must be smoothed to suppress noise. As above, we create a 1D
% Gaussian filter and perform the smoothing in a separable way.


int_size_half = floor(3*int_sigma);
x = -int_size_half:1:int_size_half;
Filter_int1D = exp(-(x).^2/(2*int_sigma^2)) / (int_sigma*sqrt(2*pi));
der_x2 = conv2( Filter_int1D, Filter_int1D', der_x2, 'same' );
der_y2 = conv2( Filter_int1D, Filter_int1D', der_y2, 'same' );
der_xy = conv2( Filter_int1D, Filter_int1D', der_xy, 'same' );

if VERBOSITY>=2
  figure(25),
  imagesc(der_x2), colormap(jet(256)), axis image, colorbar,
  title('smoothed (x-derivatives)^2');
  exportfig(gcf,[out_dir,'harris_smoothedderx.eps'])
  figure(26)
  imagesc(der_y2), colormap(jet(256)), axis image, colorbar,
  title('smoothed (y-derivatives)^2');
  exportfig(gcf,[out_dir,'harris_smootheddery.eps'])
  figure(27)
  imagesc(der_xy), colormap(jet(256)), axis image, colorbar,
  title('smoothed (x-derivatives).*(y-derivatives)');
  exportfig(gcf,[out_dir,'harris_derivproduct.eps'])
end

% We are now ready to compute the corner response function and
% hard-threshold it - values smaller than threshold are set to zero.
r = (der_x2.*der_y2 - der_xy.^2) - kappa*(der_x2 + der_y2).^2;

if VERBOSITY>=2
  figure(28)
  imagesc(r), colormap(jet(256)), axis image, colorbar,
  title('corner response function')
  exportfig(gcf,[out_dir,'harris_cornerrespf.eps'])
end
  
%
r_thresholded = r .* (r>threshold);

if VERBOSITY>=2
  figure(29)
  imagesc(r_thresholded.^(1/2)), colormap(hot(256)), axis image, colorbar,
  title('thresholded corner response function');
  exportfig(gcf,[out_dir,'harris_cornerrespf_thresh.eps'])
end

%
%  The final phase of the Harris detector is non-maximal
%  suppression - we will loop over all points detected so far and
%  only keep those where the corner response function is a local
%  maximum in a 3 x 3 neighborhood. All other output pixels
%  are set to zero. To avoid having to consider boundary effects,
%  we pad the working matrix with zeros.  

r_out = r_thresholded;

tmp_pad = zeros( size(r_thresholded)+[2 2] );
tmp_pad(2:end-1,2:end-1) = r_thresholded;
r_thresholded = tmp_pad;
% loop over non-zero elements
[idx,idy] = find(r_thresholded>0);
for k = 1:length(idx)
  i = idx(k);  j = idy(k);
  % compare to maximum of the 8-pixel neighborhood
  if r_thresholded(i,j) ~= max(max(r_thresholded(i-1:i+1, j-1:j+1))) 
  r_out(i-1,j-1) = 0;   % -1 because of the padding
  end
end

%  The output corners is a list of triples: 
% coordinate values x and y and the 
%  value of the corner response function.
[cornersx,cornersy,response] = find(r_out);
corners = [cornersx cornersy response];

if VERBOSITY>=2
  figure(30), clf
  image(im); colormap(gray(256)); axis image;
  hold on
  plot(corners(:,2),corners(:,1),'+')
  title('detected corners overlay over the input image')
end

return; % end of harris

% Implementation notes
% 
% The detector in this implementation sometimes also `detects' as corners 
% intersections of edges with image borders and corners of the image.
% This is because Matlab pads the image with zeros in convolution conv2.
% To overcome this, other implementation of convolution would be necessary.
% Make sure that the input variables are double, integers cause a loss of
% precision. 


