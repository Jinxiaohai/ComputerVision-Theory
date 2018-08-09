function T = vtxicrp(xd, xm);
% VTXICRP  Iterative closest point
% CMP   Vision Algorithms http://visionbook.felk.cvut.cz
%   
% Iterative closest reciprocal point matching
%  takes two unstructured 3D point clouds 
% (data and model) corresponding to two partially
% overlapping parts of the same object and finds a Euclidean transformation
% (rotation and translation) that brings the two clouds into
% correspondence. 
%
% {The ICRP algorithm implementation in C and its
%   Matlab wrapper was written at the CMP
%   laboratory (http://cmp.felk.cvut.cz)
%   and can be found on the .}
% 
% Usage: T = vtxicrp(xd, xm)
% Inputs:
%   xd  [N x 3|4]  3D data point set. Each row contains the x, y, z
%     coordinates, or the x, y, z, w=1 homogeneous
%     coordinates of one point.
%   xm  [M x 3|4]  3D model point set in the same format as xd.
% Outputs:
%   T  [4 x 4]  Transformation matrix to be applied to the data point set
%     so that it matches the model point set, such that
%     x_m = x_d  T, where
%     x_m=  [ x_m, y_m, z_m, 1] and 
%     x_d=  [ x_d, y_d, z_d, 1]
%     are point coordinates in the model and data coordinate
%     system, respectively.
%
% The code of the function vtxicrp is not given here because it
% is relatively uninteresting; you can look at it in electronic form.
% The function writes matrices xd and xm into files, invokes 
% an external program match and reads in the results from the file
% match produces. 
%  
% The program match needs to be compiled beforehand. 
% The auxiliary files are created in the current
% directory; you need to have sufficient permission to do so.
%
% 
% The path to the executable should be set as follows:
MATCH = '../matlab_code/icrp/icp/match';

if (nargin < 2);
  error('Not enough input arguments.');
end;

DFsize = num2str(size(xd,1));
MFsize = num2str(size(xm,1));

TempData  = tempname;
TempModel = tempname; 
p = xd(:,1:3);
save([TempData '.vtx'],'-ASCII','p');
p = xm(:,1:3);
save([TempModel '.vtx'],'-ASCII','p');

prm = fopen('match.prm','w');
if (prm < 0);
  error('The match.prm file can not be opened.');
end;

fprintf(prm,'datafilename  %s\n', TempData);
fprintf(prm,'modelfilename %s\n', TempModel);
fprintf(prm,'datarepr   PSET\n');
fprintf(prm,'modelrepr  PSET\n');

fprintf(prm,'dataelements  0 %s\n',DFsize);
fprintf(prm,'modelelements 0 %s\n',MFsize);
fprintf(prm,'\n');

fprintf(prm,'threshold    %15.10f\n', 0.00001);
fprintf(prm,'global       %d\n', 0);
fprintf(prm,'iidepth      %d\n', 0);
fprintf(prm,'fastercp     %d\n', 0);
fprintf(prm,'searchedpart %f\n', 0.03);
fprintf(prm,'centering    %d\n', 0);
fprintf(prm,'eliminate    %d\n', 1);
fprintf(prm,'elimit       %d\n', 1);
fprintf(prm,'correspinfo  %d\n', 0);
fprintf(prm,'rangesearch  %d\n', 2);

if ~(fclose(prm) == 0);
  error('The match.prm file can not be closed.');
end;

res = system([MATCH ' ' TempData ' ' TempModel]);
if ~(res == 0);
  error('ICRP algorithm was not successed.');
end;

delete([TempData '.vtx']);
delete([TempModel '.vtx']);

rtf = fopen('match.res','r');
if (rtf < 0);
  error('The match.res file can not be opened.');
end;
a = fscanf(rtf,'%f',7);
b = fscanf(rtf,'%f',7);
T = [   fscanf(rtf,'%f',4)'; ...
        fscanf(rtf,'%f',4)'; ...
        fscanf(rtf,'%f',4)'; ...
        fscanf(rtf,'%f',4)'];
if ~(fclose(rtf) == 0);
  error('The match.res file cannot be closed.');
end;


