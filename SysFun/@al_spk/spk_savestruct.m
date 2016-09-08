function s = spk_savestruct(s,SavePath)

% saves a @al_spk object as a mat file
% extension is *.SPK, fields of object are saved as
% variables in mat file. load with spk_loadstruct
%
% s = spk_savestruct(s,SavePath)
%

SaveFileDir = '';
SaveFileName = '';
SaveFileExt = '';

MatlabVersionNr = version;

if nargin == 2
    [SaveFileDir,SaveFileName,SaveFileExt] = fileparts(SavePath);
end

if nargin<2 | isempty(SaveFileName) | isempty(SaveFileExt)
    [SaveFileName,SaveFileDir] = uiputfile('*.SPK','save spk object as structure',[SaveFileDir '\' datestr(now,30) '.SPK']);
    if SaveFileName==0;return;end
    SavePath = fullfile(SaveFileDir,SaveFileName);
    [SaveFileDir,SaveFileName,SaveFileExt] = fileparts(SavePath);
end

s = struct(s);
f = fieldnames(s);
s.file = SavePath;

% save all the fields separately
if strcmp(MatlabVersionNr(1),'7')
%     s = struct(s);
    save(SavePath,'-struct','s','-mat','-V6');
    
%     eval([f{1} '=s.' f{1} ';']);
%     
% %     save SavePath -struct s  -mat -V6
%     
%     save(SavePath,f{1},'-mat','-V6');
%     for i = 2:length(f)
%         eval([f{i} '=s.' f{i} ';']);
%         save(SavePath,f{i},'-append','-mat','-V6');
%     end
else
    eval([f{1} '=s.' f{1} ';']);
    save(SavePath,f{1},'-mat');
    for i = 2:length(f)
        eval([f{i} '=s.' f{i} ';']);
        save(SavePath,f{i},'-append','-mat');
    end
end
    
    