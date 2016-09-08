function dofun = nlx_control_callAnalyse(dofun,OnlineFlag,TrialNr)

for f = 1:size(dofun,1)
    feval(dofun{f,:},TrialNr);
end
