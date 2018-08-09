function table = histtable(histconfig);
% HISTTABLE computes lookup table for histogram computation
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Petr Lhotsky, Tomas Svoboda, 2007
%
% Table has offset 1, (0,255) maps to (1,256)
%
% table = histtable(histconfig)
% histconfig
%   .bins number of bins in histogram
%   .grid [1 x 2] range of the histogram [start, end]
% 

% History:
% $Id: histtable.m 1086 2007-08-14 13:41:41Z svoboda $

table = int8(zeros(1,256));

step = (histconfig.grid(2)-histconfig.grid(1))/histconfig.bins(1);
edges = histconfig.grid(1):step:histconfig.grid(2);
edges(1) = 0;
edges(end) = 255;

% Construct lookup table
bin = 1;
for j=0:255
    if j > edges(bin+1)
        bin = bin + 1;
    end
    table(j + 1) = bin;
end

return; % end of histtable