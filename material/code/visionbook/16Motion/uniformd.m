function d = uniformd(low,high,m,n)
% UNIFORMD uniform density generator
% CMP Vision Algorithms, http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2007
%
% d = uniformd(low,high,m,n)   
% generates data of dimension [m,n] uniformly
% distributed between low and high margins    
%     
% See also: rand

% History:
% $Id: uniformd.m 1086 2007-08-14 13:41:41Z svoboda $
% 2007-05-01: Tomas Svoboda created as an replacement
%             for the unitfrnd function from the
%             statistics toolbox

d = low+(high-low)*rand(m,n);
return;


    
    
    
    