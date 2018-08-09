%vtxicrp  Krsek: Matching of 3D point clouds
%
% function tran = vtxicrp(xd, xm);
%
%	The function search for euclidean transformation which transforms
% 3D data point cloud into coordinate system of model 3D point cloud.
% The transformation minimize distance between input set of points
% by ICRP algorithm.
% 
% xd ...   3D data point set. Size of matrix is nx3. The matrix consists 
%          of [x y z] points coordinates
% xm ...   3D model point set. Size of matrix is nx3. The matrix consists 
%          of [x y z] points coordinates
%
% tran ... Matrix 4x4, which describes euclidean transformation which 
%          transform data points into model coordinate system.
%
% See also:  Other func.

%	Author       : Pavel Krsek, krsek@cmp.felk.cvut.cz
%                19.6.2007 CMP, Czech Technical University, Prague
%	Language     : Matlab 4.2, (c) MathWorks  			 
% Last change  : 19.6.2007
% Status       : Ready
%
function tran = vtxicrp(xd, xm);

% Name and path of matching program
%
MATCH = '../matlab_code/icrp/icp/match';

% Checking number of input argument
%
if (nargin < 2);
  error('Not enough input arguments.');
end;

% Number of vertices (number of rows)
%
DFsize = num2str(size(xd,1));
MFsize = num2str(size(xm,1));

% Prepare program input files 
% (VTX - files of vertices)
%
TempData  = tempname;
TempModel = tempname; 
p = xd(:,1:3);
save([TempData '.vtx'],'-ASCII','p');
p = xm(:,1:3);
save([TempModel '.vtx'],'-ASCII','p');

% Writing parameter file
% (It must be in actual directory.)
%
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

% 3D point cloud matching
% (Call extenal program)
%
res = system([MATCH ' ' TempData ' ' TempModel]);
if ~(res == 0);
  error('ICRP algorithm was not successed.');
end;

% Delete temporary inpub files
%
system(['rm ' TempData '.vtx']);
system(['rm ' TempModel '.vtx']);

% Open result text file and read parameter
% of found transformation
% 
rtf = fopen('match.res','r');
if (rtf < 0);
  error('The match.res file can not be opened.');
end;
a = fscanf(rtf,'%f',7);
b = fscanf(rtf,'%f',7);
tran = [fscanf(rtf,'%f',4)'; ...
        fscanf(rtf,'%f',4)'; ...
        fscanf(rtf,'%f',4)'; ...
        fscanf(rtf,'%f',4)'];
if ~(fclose(rtf) == 0);
  error('The match.res file can not be closed.');
end;

return;