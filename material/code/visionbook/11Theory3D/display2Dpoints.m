function fig = display2Dpoints(fig,u,varargin)

try axis_range = varargin{1}; catch axis_range = [1 640 1 480]; end;
try marker_color = varargin{2}; catch marker_color = 'k'; end
try marker_face = varargin{3}; catch marker_face = '+'; end
try marker_size = varargin{4}; catch marker_size = 5; end
try L = varargin{5}; catch L = []; end;
try title_string = ['Scene: ',varargin{6},';']; catch title_string = ''; end
try line_width = varargin{7}; catch line_width=1; end

figure(fig)
plot(u(1,:),u(2,:),sprintf('%s%s',marker_color,marker_face),'LineWidth',2,'MarkerSize',marker_size)
hold on
for j=1:size(L,1),
  line([u(1,L(j,:))],[u(2,L(j,:))],'LineWidth',line_width,'Color',marker_color);
end  
% for j=1:size(u,2),
%   text(u(1,j)+10,u(2,j),sprintf('%d',j),'BackgroundColor','white')
% end
% plot(u(1,:),u(2,:),'ko','MarkerFaceColor','white')
axis ij
axis equal
axis(axis_range)
grid on;
title(sprintf('%s Projection to the camera, units are pixels',title_string));
