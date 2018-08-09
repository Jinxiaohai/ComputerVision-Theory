% demonstration of BUTTFILT, Butterworth filter
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007

addpath ../.
cmpviapath('../.');
% create a directory for output images
% if necessary, if it does not already exist
out_dir = './output_images/';
if exist(out_dir)~=7
  mkdir(out_dir)
end

im = imread('images/pattern2.png');
im = rgb2gray(im);

types = {'lp'};
ns = 500;
Do = 50;
for n=ns
  for type = 1:length(types)
    [im_filt,figs] = buttfilt(im,types{type},Do,n,'none',1);

    if isempty(figs)
      fh = 1;
    else
      fh = figs(end).h+1; 
    end

    figs(fh).h = figure(fh); clf
    imshow(im)
    title('original image')
    figs(fh).fname = 'origimage.eps';

    fh = fh+1;
    figs(fh).h = figure(fh); clf
    imshow(im_filt)
    title('filtered image')
    figs(fh).fname = 'filteredimage.eps';

    fh = fh+1;
    figs(fh).h = figure(fh); clf
    imshow(hist_equal(im_filt))
    title('equalized filtered image')
    figs(fh).fname = 'filteredimage_equalized.eps';


    for i=1:length(figs)
      exportfig(figs(i).h,[out_dir,sprintf('freqfilt_%s_n%03d_Do%03d_',types{type},n,Do),figs(i).fname]);
    end
  end
end

