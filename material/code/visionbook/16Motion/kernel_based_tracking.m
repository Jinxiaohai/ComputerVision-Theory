function S = kernel_based_tracking(S,y0,conf,VERBOSITY)
% KERNEL_BASED_TRACKING Object tracking based on spatially masking the
% target with isotropic kernel
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Petr Lhotsky, Tomas Svoboda, 2007
%
% Kernel based tracking is based on spatially masking the target with
% an isotropic kernel and evaluating the selected area with a smooth similarity
% function . The maximum of the similarity
% function is searched using the
% mean-shift algorithm .
% 
% Usage: S = kernel_based_tracking(S,y0,conf,VERBOSITY)
% Inputs:
%   S  struct  Structure with image and position, describing the state
%     at time t-1.
%   .img  [m x n] Input image with object.
%   y0  [1 x dim]  Initial state of the model - start position
%     for the mean-shift.
%   conf  struct   Structure with the configuration parameters.
%   .h  [1]  Size of the Epanechnikov kernel - the radius of the area which
%     has non-zero weights of the kernel (in pixels).
%   .img_x  1x1  Size of the input image S.img, x coordinate.
%   .img_y  1x1  Size of the input image S.img, y coordinate.
%   .table  [1 x 256]  Lookup table for fast histogram computation.
%   .bins  1x1  Number of histogram bins.
%   .q  [1 x bins] Probability model of the target model p(q).
%   .iters  1x1  Maximal number of iterations in one cycle.
%   .treshold  1x1  Threshold for the end-condition of the mean-shift cycle,
%     it should be less than 0.5 - if the shift is within one pixel
%     stop the mean-shift cycle.
% VERBOSITY  (default 0)
%            Verbosity of the function. If >0 it displays
%             the iterations.
%   S  struct  Updated structure at time t.
%   .y  [1 x dim]  State of the object.
%   .iter  1x1  Number of iterations.
%   .p  [1 x bins]  Probability density p(y).
% 

if nargin<4
  VERBOSITY=0;
end


iter = 0;
% The idea of kernel-based tracking is to use only a small neighborhood
% around the position under test. This neighborhood
% is evaluated with a similarity measure that rates the probability that the
% target object is in this position. The pixels are weighted with the
% kernel - we use an Epanechnikov kernel. This probability is maximal in the
% position of the target object; thus we need the maximum of the similarity 
% measure. To find the maximum, the mean-shift algorithm is used. We
% start in the last known occurrence of the target object. 
if VERBOSITY>0
  figure(10), clf, imshow(S.img), axis on; hold on;
  figure(15), clf
end
while true
  iter = iter + 1;
  % extract the neighborhood
  xl = max( y0(1)-conf.h, 1 );
  xh = min( y0(1)+conf.h, conf.img_y );
  yl = max( y0(2)-conf.h, 1 );
  yh = min( y0(2)+conf.h, conf.img_x );
  candidate = S.img( yl:yh, xl:xh );
% The area covered by the Epanechnikov kernel is circular (in 2D). 
% In order to speed up processing we pre-cut a
% square area (candidate) which is further processed. 
% The coordinates are rearranged to a
% matrix Coord for fast computation of the distance to the center. 
% Note how the x and y coordinates are generated using
% integer division and the modulo function. The same operation could be
% accomplished using ndgrid or
% meshgrid which would be more elegant but
% unfortunately also much slower. It is important to note that despite its
% matrix nature the data is organized in 1D arrays for efficiency.
% The re-mapping back to matrix
% coordinates is done in the auxiliary function remap. In order to better
% understand this, set VERBOSITY to 1 and look at the code
% that displays the images. The displaying code is omitted here for clarity.
  % number of pixels in the neighborhood and helper vector
  nxw = xh-xl+1;  nyw = yh-yl+1;
  nw=nxw*nyw;     iw=(0:(nw-1))'; 
  % matrix with coordinates of the pixels
  Coord = [floor(iw/nxw+xl) mod(iw,nyw)+yl]; 
  coord_orig = Coord;
  % distance of pixels to the center (y0)
  Dist = sum( (((Coord-repmat(y0,nw,1))/conf.h).^2), 2 );
  % where the distance is less than 1 - kernel is greater than 0
  idx = find(Dist<1);
  % take only idx pixels
  Dist = Dist(idx);
  Coord = Coord(idx,:);
  % compute the kernel weights based on Dist vector
  Kern = epanech_kernel(Dist);
  % take only idx pixels
  h = candidate(idx);
  % compute the histogram using lookup table
  h = conf.table(h+1);
% Computation of the probability p(y) uses
% the computed histogram. For each bin
% it finds all pixel candidates that belong in it. These
% pixels contribute according to weights from the Kern vector. 
  S.p = zeros( 1, conf.bins );
  for u = 1:conf.bins
    S.p(u) = sum( Kern(h==u) );
  end
  S.p = S.p/sum(Kern); % normalize
% To minimize computation time the Taylor expansion is used around the
% values p(y) . Thus it is not necessary to
% compute the similarity measure for the neighborhood. The new
% position is defined by . Since the
% derivative of the profile g is constant (for the Epanechnikov kernel) the 
% equation reduces to
%   y_1 = (Sum over i=1...n x_i w_i)/(Sum over i=1...n w_i),
% where n is the number of pixels in the kernel and w_i are
% weights
  w = sqrt( conf.q(h)./S.p(h) )'; % compute the weights w_i for y
  % find the next location of the target candidate
  y1(1) = round( sum(Coord(:,1).*w)/sum(w) );
  y1(2) = round( sum(Coord(:,2).*w)/sum(w) );
  last = y0;
  y0 = y1;
  % displaying images for pedagogical and debugging purposes
  if VERBOSITY>0
    figure(10), title(sprintf('Iteration: %d',iter));
    line([min(Coord(:,1)),max(Coord(:,1)),max(Coord(:,1)),min(Coord(:,1)),min(Coord(:,1))], ...
       [max(Coord(:,2)),max(Coord(:,2)),min(Coord(:,2)),min(Coord(:,2)),max(Coord(:,2))], ...
       'Color','g','LineWidth',2);
    plot(last(1),last(2),'+g')
    plot(y0(1),y0(2),'r+')
    line([last(1) y0(1)], [last(2) y0(2)], 'Color','b','LineWidth',2)
    title('Mean-shift iterations' )
    figure(11), title('Candidate')
    imshow(candidate)
    distMat = remap(Dist,idx,coord_orig,[xl,yl]);
    figure(12), 
    mesh(distMat); title('Distance function')
    KernMat = remap(Kern,idx,coord_orig,[xl,yl]);
    figure(13), 
    mesh(KernMat); title('Kernel function')
    figure(14)
    bar([S.p(:),conf.q(:)],'group')
    legend('candidate hist','target hist','Location','NorthWest')
    title(sprintf('Iteration %d',iter))
    figure(15), hold on
    plot(conf.q,'r-','LineWidth',5)
    plot(conf.q,'r*','LineWidth',3,'MarkerSize',7)
    color = 0.9^iter*[1,1,1];
    plot(S.p,'-','LineWidth',3,'Color',color)
    plot(S.p,'k-','LineWidth',1);
    plot(S.p,'*','Color',color)
    text(length(S.p)+0.5,S.p(end), sprintf('%d',iter),'Color','b','BackgroundColor',color)
    title('histograms during mean-shift iterations')
    xlabel('histogram bin indexes')
    ylabel('probabilities')
      drawnow
    pause(0.1) % to allow on-line following of the iterations
  end

% The similarity check steps 5 and 6 from  are omitted.
% The mean-shift cycle stops when the shift is less than one pixel or
% the maximal number of iterations is reached.
  % testing the shift
  if (max(abs(y1-last))<conf.treshold) || (iter==conf.iters)
    S.y = y1;
    S.iter = iter;
    break
  end
end % while loop for mean-shift iterations

if VERBOSITY>0    
figure(10)
xl = max(S.y(1)-conf.h,1);
xh = min(S.y(1)+conf.h,conf.img_y);
yl = max(S.y(2)-conf.h,1);
yh = min(S.y(2)+conf.h,conf.img_x);
line([xl,xh,xh,xl,xl],[yh,yh,yl,yl,yh],'Color','r','LineWidth',2)
end

return; % end of kernel_based_tracking

% auxiliary remapping for displaying iterations
function mat = remap(vec,idx,coord,nw)
% mat = remap(vec,idx,coord,nw)}
% The auxiliary function serves for visualization
% purposes. It remaps the vector into a matrix.
% The mapping is twofold. First it takes true linear index
% from the idx vector. Second, it uses the retrieved index
% to select the image coordinates from coord. The image 
% coordinates are shifted by using the northwest (nw)
% coordinate.

r = max(coord(:,2))-min(coord(:,2))+1;
c = max(coord(:,1))-min(coord(:,1))+1;

mat = zeros(r,c);
for i=1:length(vec),
  backidx = idx(i);
  ridx = coord(backidx,2)-nw(2);
  cidx = coord(backidx,1)-nw(1);
  mat(ridx,cidx) = vec(i);
end

return; % end of remap 

