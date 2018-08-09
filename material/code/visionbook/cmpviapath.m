function p = cmpviapath(rootpath,stprtoolbox)
% CMPVIAPATH Sets all necessary paths for cmpvia toolbox
% 
% p = cmpviapath(rootpath);
% 
% Input parameters:
% rootpath ... (optinoal) root path of the toolbox, defaults
%              to current working directory
% stprtoolbox... (optional) if set to 1, path to stprtoolbox is 
%                added and the toolbox is initialized
% 
% Output:
% p ... added path
%  
% History:
% 2006-01-26 Tomas Svoboda: created based on a similar function
%            from Vojta Franc and Vaclav Hlavac patern recognition
%            toolbox
% 
% $Id: cmpviapath.m 1181 2014-04-02 15:47:26Z svoboda $

if nargin<2
  stprtoolbox=0 ;
end ;
  
if nargin<1
  rootpath=pwd;
end

disp('Setting path for the CMPvia codes')
disp('cmpvia@cmp.felk.cvut.cz ---------')

% set path for UNIX
p = ['$:', ...
	 '$02Image:', ...
     '$03ImageMath:', ...
	 '$04DataStr:',...
	 '$05Preproc:',...
	 '$06Segm1:',...
	 '$07Segm2:',...
	 '$08ShapeRepr:',...
	 '$09ObjRec:',...
	 '$11Theory3D:',...
     '$14Compr:', ...
     '$15Texture:', ...
     '$16Motion:', ...
	 '$matlab_code/graphcut:',...
	 '$matlab_code/bsplines:',...
     '$matlab_code/misc:'
	 ];

if stprtoolbox,
  p = [ p, '$matlab_code/stprtool:' ] ;
end ;




p=translate(p,rootpath);

% adds path at the start
addpath(p);

% setup 
if stprtoolbox,
  stprpath(translate('$/matlab_code/stprtool',rootpath)) ;
end ;

%--translate ---------------------------------------------------------
function p = translate(p,rootpath);
%TRANSLATE Translate unix path to platform specific path
%   TRANSLATE fixes up the path so that it's valid on non-UNIX platforms
%
% This function was derived from MathWork M-file "pathdef.m"

cname = computer;

% Look for PC
if strncmp(cname,'PC',2)
  p = strrep(p,'/','\');
  p = strrep(p,':',';');
  p = strrep(p,'$',[rootpath '\']);

% Look for MAC 
% not needed for MAC OSX - seems it works like a standard unix
% elseif strncmp(cname,'MAC',3)
%   p = strrep(p,':',':;');
%   p = strrep(p,'/',':');
%   p = strrep(p,'/','/');
%   m = rootpath;
%   if m(end) ~= ':'
%     p = strrep(p,'$',[rootpath ':']);
%   else
%     p = strrep(p,'$',rootpath);
%   end
else
  p = strrep(p,'$',[rootpath '/']);
end
