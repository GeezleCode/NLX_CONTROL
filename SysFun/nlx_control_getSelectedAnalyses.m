function dofun = nlx_control_getSelectedAnalyses
dofun = cell(0,0);
AnalysesItems = get(findobj('parent',nlx_control_getMainWindowHandle,'type','uimenu','label','Analyse'),'children');
for i=1:length(AnalysesItems)
    if isempty(get(AnalysesItems(i),'children')) & strmatch('on',get(AnalysesItems(i),'checked'))
        dofun =[dofun;{get(AnalysesItems(i),'tag')}];
    else
        UserItems = get(AnalysesItems(i),'children');
        for k=1:length(UserItems)
            if strmatch('on',get(UserItems(k),'checked'))
                dofun =[dofun;{get(UserItems(k),'tag')}];
            end
        end
    end
end


