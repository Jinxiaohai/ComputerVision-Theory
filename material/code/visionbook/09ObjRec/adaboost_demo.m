% CMP Vision Algorithms http://visionbook.felk.cvut.cz

addpath('..') ; cmpviapath('..') ;
out_dir = './output_images/' ;
if (exist(out_dir)~=7)
  mkdir(out_dir);
end

rand('state',4) ;
adaboost_demof() ;
