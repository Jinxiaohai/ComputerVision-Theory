imsize = [50,50];

metrics = {'euclidean','cityblock','chessboard'};

for i = 1:length(metrics)
  D = rc2d(imsize,metrics{i});
  figure(i),clf
  mesh(D)
  title(metrics{i})
end
