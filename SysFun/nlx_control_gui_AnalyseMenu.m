function FunMenu = nlx_control_AnalyseMenu

MainDir = nlx_control_getMainDir;
MainWin = nlx_control_getMainWindowHandle;
FunMenu = uimenu('parent',MainWin,'label','Analyse');

addpath(nlx_control_getAnalyseDir);
[FunDir,isUserDir] = CheckDir(nlx_control_getAnalyseDir);

% default functions
for i = find(isUserDir==0);
    uimenu('parent',FunMenu, ...
        'label',nlx_control_RemovePrefix(FunDir(i).name), ...
        'tag',strrep(FunDir(i).name,'.m',''), ...
        'callback','switch get(gcbo,''checked'');case ''on''; set(gcbo,''checked'',''off'');case ''off''; set(gcbo,''checked'',''on'');end');
end

% user functions
for i = find(isUserDir==1);
    UserMenu = uimenu('parent',FunMenu,'label',FunDir(i).name);
    addpath(fullfile(nlx_control_getAnalyseDir,FunDir(i).name));
    [UserFun,isUserFun] = CheckDir(fullfile(nlx_control_getAnalyseDir,FunDir(i).name));
    for j = find(isUserFun==0);
        uimenu('parent',UserMenu, ...
            'label',nlx_control_RemovePrefix(UserFun(j).name), ...
            'tag',strrep(UserFun(j).name,'.m',''), ...
            'callback','switch get(gcbo,''checked'');case ''on''; set(gcbo,''checked'',''off'');case ''off''; set(gcbo,''checked'',''on'');end');
    end
end

function [d,isDir] = CheckDir(p)
d = dir(p);
dNum = length(d);
for i = 1:dNum
    if (d(i).isdir==1) & ~ismember(d(i).name,{'.' '..'})
        isDir(i) = 1;
    elseif (d(i).isdir==1) & ismember(d(i).name,{'.' '..'})
        isDir(i) = 2;
    else
        isDir(i) = 0;
    end
end

