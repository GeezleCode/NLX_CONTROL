function [fDir,fName,fExt] = spk_getFilename(s,FileNameDelimiter)

% extracts file path, name and extension from the s.file field
% [fDir,fName,fExt] = spk_getFilename(s,FileNameDelimiter)
%
% FileNameDelimiter ... delimiter for extracting filename components
% 
% fDir .... char file directory
% fName ... 2D cell, filename components in columns
% fExt

if ischar(s.file)
    [fDir,fName,fExt] = getfilename(s.file,FileNameDelimiter);
elseif iscell(s.file)
    for i=1:length(s.file)
        [fDir{i},fName(i,:),fExt{i}] = getfilename(s.file{i},FileNameDelimiter);
    end
end

function [fDir,fName,fExt] = getfilename(FilePath,FileNameDelimiter)
[fDir,fn,fExt] = fileparts(FilePath);
if isempty(FileNameDelimiter)
    fName = fn;
else
    cnt = 1;
    [fName{1,cnt},r] = strtok(fn,FileNameDelimiter);
    while ~isempty(r)
        cnt = cnt+1;
        [fName{1,cnt},r] = strtok(r,FileNameDelimiter);
    end
end

