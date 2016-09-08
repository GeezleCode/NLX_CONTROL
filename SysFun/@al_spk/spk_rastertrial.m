function spk_rastertrial(s)

% plots a raster plot for trials given s.currenttrials

[NumChan,ChanLabel,EmptyChan,NumSpk] = spk_numchan(s);
[NumTrials,cndtrials,cndCodes] = spk_numtrials(s);

if isempty(s.chancolor)
    s.chancolor = [ ...
            1 0 0; ...      red
            0 1 0; ...      green
            0 0 1; ...      blue
            1 1 0; ...       yellow
            .5 0 1; ...     purple
            1 .5 0; ...     orange
            0 1 .5; ...     cyan
            0 1 1 ...      light blue
        ];
end     

currTrialNum = length(s.currenttrials);

% for debugging only for *.SPK files before 24/06/05
warning('for debugging only for *.SPK files before 24/06/05');
for i = s.currenttrials
    s.events{spk_findeventlabel(s,'NLX_TRIAL_END'),i} = s.events{spk_findeventlabel(s,'NLX_TRIAL_END'),i}.*0.001;
end

for i = s.currenttrials
    currTrialNum = find(s.currenttrials==i);
    
    
    currEvTrain = cat(2,s.events{:,i});
    currEvTrainNum = length(currEvTrain); 
    
    line(repmat(currEvTrain,[2 1]),[ones(1,currEvTrainNum).*0;ones(1,currEvTrainNum).*NumChan] + ((currTrialNum-1)*(NumChan+1)), ...
        'linestyle','-','color','c','linewidth',1,'clipping','off');
    
    for j=1:NumChan
        currSpkTrain = cat(2,s.spk{j,i});
        currSpkTrainNum = length(currSpkTrain);
        if currSpkTrainNum>0;
            line(repmat(currSpkTrain,[2 1]), ...
                [ones(1,currSpkTrainNum).*0.1;ones(1,currSpkTrainNum).*0.9]+(j-1) + ((currTrialNum-1)*(NumChan+1)), ...
                'linestyle','-','color',s.chancolor(j,:),'linewidth',1,'clipping','off');
        end
    end
end
        
set(gca,'color',[.5 .5 .5], ...
    'box','on', ...
    'ytick',[], ...
    'layer','bottom', ...
    'xgrid','on');