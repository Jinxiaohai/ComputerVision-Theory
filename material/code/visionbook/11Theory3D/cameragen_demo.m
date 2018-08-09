% CAMERAGEN_DEMO demonstration of the camera creation
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007

% History:
% 2007-01-25 Tomas Svoboda (TS) created
% 2007-05-03 TS: new decor
%
% $Id: cameragen_demo_decor.m 1074 2007-08-14 09:45:42Z kybic $

clear all;
close all;

out_dir = './output_images/'; 
if ~(exist(out_dir)==7)
  mkdir(out_dir)
end

% first generate and display the 3D scene
scenegen_demo;
fig = gcf;
print('-depsc2','-cmyk',[out_dir,'3D_scene_without_cams.png']);

% a cycle where the camera parameters may be altered and compared

for i=1:3,
  pars(i).angle = (20+(i*10)) *(pi/180);
  pars(i).look_at = [0,2,1]';
  pars(i).position = [12,i,5*i]';
  pars(i).sky = [0,-1,0]';
  pars(i).foclen = 2;
  
  camera = cameragen(pars(i));
  P{i} = camera.P;
  
  u = camera.P * X;
  u = u./repmat(u(3,:),3,1);

  figure(2)
  clf
  plot(u(1,:),u(2,:),'ko','MarkerFaceColor','white')
  hold on
  for j=1:size(L,1),
	line([u(1,L(j,:))],[u(2,L(j,:))],'LineWidth',5);
  end  
  for j=1:size(u,2),
	text(u(1,j)+10,u(2,j),sprintf('%d',j),'BackgroundColor','white')
  end
  plot(u(1,:),u(2,:),'ko','MarkerFaceColor','white')
  axis ij
  axis equal
  axis([0 camera.width 0 camera.height])
  grid on;
  title('Projection to the camera, units are pixels')

  figure(2)
  set(gca,'Position',[0 0 1 1])
  axis off
  grid off;
  im = getframe(gcf);
  IM{i} = im.cdata;
  IM{i} = imresize(IM{i},[camera.height,camera.width],'bilinear');
  IM{i} = rgb2gray(IM{i});
  % figure(3),
  % imshow(IM{i}), axis on
  imwrite(IM{i},sprintf('%s/projected_image_%02d.png',out_dir,i));
end

figure(1)

showcams(fig,-1,P,IM);
% adjust figure size
scr_size = get(0,'ScreenSize');
scale = 1.9/3;
set(gcf,'Position',[0,scr_size(4)/3,0.7*scale*scr_size(3),scale*scr_size(4)])

print('-dpng','-r96','-cmyk',[out_dir,'3D_scene_with_cams.png'])

