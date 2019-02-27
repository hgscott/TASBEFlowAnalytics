function [fcsdat, fcshdr, fcsdatscaled] = fca_read(filename, headername)
% [fcsdat, fcshdr, fcsdatscaled] = fca_readcsv(filename);
%
% Read CSV or FCS of flow cytometry data file and put the list mode  
% parameters to the fcsdat array with size of [NumOfPar TotalEvents]. 
% Some important header data are stored in the fcshdr structure:
% TotalEvents, NumOfPar, name

% If noarg was supplied
if nargin == 0
     [FileName, FilePath] = uigetfile('*.*','Select file');
     filename = [FilePath,FileName];
     if FileName == 0
          fcsdat = []; fcshdr = []; fcsdatscaled = [];
          return;
     end
else
    if isempty(filename)
        TASBESession.warn('Read','NoFile','No file provided! Returning empty dataset.'); 
        fcsdat = []; fcshdr = []; fcsdatscaled = [];
        return;
    end
    filecheck = dir(filename);
    if size(filecheck,1) == 0
        TASBESession.warn('Read','NoFile',[filename,': The file does not exist! Returning empty dataset.']); 
        fcsdat = []; fcshdr = []; fcsdatscaled = [];
        return;
    end
end

% If filename arg. only contain PATH, set the default dir to this
% before issuing the uigetfile command. This is an option for the "fca"
% tool
[~, ~, fext] = fileparts(filename);

if fext == '.csv'
    if ~exist('headername', 'var')
        % kludge: must be removed
        headername = 'C:\Users\coverney\Documents\SynBio\Template\batch2\csv\LacI Transfer Curve.json';
        [fcsdat, fcshdr, fcsdatscaled] = fca_readcsv(filename, headername);
    else
        [fcsdat, fcshdr, fcsdatscaled] = fca_readcsv(filename, headername, TASBEConfig.get('flow.maxEvents'));
    end
elseif fext == '.fcs'
    [fcsdat, fcshdr, fcsdatscaled] = fca_readfcs(filename,TASBEConfig.get('flow.maxEvents'));
else
    TASBESession.error('Read','InvalideExtension','Filename is not of type csv or fcs');

end

