function s = spk_loadstruct(s,LoadPath)

% loads a file in mat format to a @al_spk object
% fields have to saved as variables in this file
% see spk_savestruct
%
% s = spk_loadstruct(s,LoadPath)

LoadDir = '';
LoadFile = '';
LoadExt = '';

if nargin == 2
    [LoadDir,LoadFile,LoadExt] = fileparts(LoadPath);
end

if nargin<2 | isempty(LoadPath) | isempty(LoadExt)
    [LoadFile,LoadDir] = uigetfile('*.*','load spk object as structure',[LoadDir '\']);
    if LoadFile==0;s = [];return;end
    LoadPath = fullfile(LoadDir,LoadFile);
    [LoadDir,LoadFile,LoadExt] = fileparts(LoadPath);
end

X = load(LoadPath,'-mat');
s = al_spk(X);
s.file = LoadPath;
