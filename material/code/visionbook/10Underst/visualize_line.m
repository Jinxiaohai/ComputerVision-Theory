function fid = visualize_line(fid,x,ind,inl,inliers,model,best_model,iter,maxiter,next_maxiter,updated)

outliers = not(inl);
t1 = [-5, 105];

fid=figure(fid);
clf;
plot(x(1,outliers),x(2,outliers),'c.')
hold on;
% just a dirty trick in order to prevent window disturbing changes in the graph box size
% corners=[0,t1,0,t1;0,0,t1,t1];
% plot(corners(1,:),corners(2,:),'w+','MarkerSize',25,'LineWidth',2)
if ~updated
  plot(x(1,ind),x(2,ind),'r+','MarkerSize',25,'LineWidth',2)
  plot(x(1,inl),x(2,inl),'r.')
  plot(t1,model(1)+model(2)*t1,'r-','LineWidth',2);
end
if ~isempty(inliers)
  plot(x(1,inliers),x(2,inliers),'b.')
end
axis([t1, t1])

if ~isempty(best_model)
  plot(t1,best_model(1)+best_model(2)*t1,'b-','LineWidth',2);
end

if ~updated & iter>0 
    legend('outliers','drawn sample','current inliers','fitted model','the best so far inliers','best model so far')
end

basename = sprintf('output_images/ransac_demo_iter%03d',iter);

if ~updated
  currsupp=sum(inl);
  bestsupp=sum(inliers);
  if currsupp>bestsupp
    color='red';
  else
    color='black';
  end
  title([sprintf('iter=%d, maxiter=%d',iter,maxiter),'{\color{',color,'}->\bf',sprintf('%d}',next_maxiter),' support=','\color{',color,'}\bf',sprintf('%d|%d',currsupp,bestsupp)])
  exportfig(gcf,[basename,'_before.eps']);
else
  title(sprintf('iter=%d, Best model updated: maxiter=%d, best support=%d',iter,maxiter,sum(inliers)))
  exportfig(gcf,[basename,'_updated.eps']);
end


return;
