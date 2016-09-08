function s = spk_renameTrialcodelabel(s,old,new);

if iscell(old)
    for iTC = 1:length(old)
        ci = strcmp(old{iTC},s.trialcodelabel);
        if any(ci)
            s.trialcodelabel{ci} = new{ci};
        end
    end
else
    ci = strcmp(old,s.trialcodelabel);
    if any(ci)
        s.trialcodelabel{ci} = new;
    end
end