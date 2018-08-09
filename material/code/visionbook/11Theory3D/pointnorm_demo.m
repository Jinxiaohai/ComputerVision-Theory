% POINTNORM_DEMO demo for pointnorm
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2006-2007

% $Id: pointnorm_demo_decor.m 1074 2007-08-14 09:45:42Z kybic $

set(0,'DefaultAxesFontSize',16)
set(0,'DefaultLineLineWidth',1)

outdir = './output_images/'; 
if ~(exist(outdir)==7)
  mkdir(outdir)
end


u = 100*rand(2,100);
u(3,:) = 1; % make the data homogeneous
figure(1);  clf
plot( u(1,:), u(2,:), '+' ); hold on
title('original points')

[u2,T] = pointnorm(u);
display(sprintf('the centroid of normalized coordinates is [%1.2f,%1.2f]', ...
                mean(u2(1:2,:)') ))
display(sprintf('average radius of the normalized coordinates is %2.2f', ...
                mean(sqrt(sum((u2(1:2,:)'.^2)'))) ))
figure(2);  clf
plot( u2(1,:), u2(2,:), 'k+', 'MarkerSize',10 )
title('normalized points');
print('-depsc2','-cmyk',[outdir,'pointnorm_normalized_points.eps'])


% Control computation:
u3 = inv(T)*u2;
figure(1)
plot( u3(1,:), u3(2,:), 'ko', 'MarkerSize',10 )
print('-depsc','-cmyk',[outdir,'pointnorm_original_points.eps']);



