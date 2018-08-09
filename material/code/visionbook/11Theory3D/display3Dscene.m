function fig = display3Dscene(fig,X,L,linecolor)

if nargin<4
  linecolor = 'b';
end

if isempty(fig)
  fig=1;
end

fig = figure(fig);
hold on;
%[
% Plot the points and connect the relevant points by lines 
% to create the true visual illusion. See the demonstration of
% \FcePgLink{cameragen} for its use. 
%]
%(
for i=1:size(L,1),
  line([X(1,L(i,:))],[X(2,L(i,:))],[X(3,L(i,:))],'Color',linecolor);
end  
axis equal
for i=1:size(X,2),
  text(X(1,i),X(2,i),X(3,i),sprintf('  %d',i), ...
	   'FontWeight','bold','BackgroundColor','yellow')
end
plot3(X(1,:),X(2,:),X(3,:),'o','MarkerFaceColor','white');
% campos([5,5,5])	% set a cemera pose that observe the scene
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')
title('View of a 3D scene')
return;
%)
