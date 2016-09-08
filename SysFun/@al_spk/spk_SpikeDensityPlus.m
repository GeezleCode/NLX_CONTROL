function R = spk_SpikeDensityPlus(SPK,varargin)

% application of the spk_SpikeDensity.m
%
% R = spk_SpikeDensityPlus(SPK,'prop1','val1', ...)

%% settings
R.Name = '';
R.trialindex = [];
R.density = [];
R.time = [];
R.Width = 10;
R.HalfGaussianFlag = false;
R.AlignedTo = '';
R.EventWin = {'NLX_STIM_ON' [-250 750]};

R = StructUpdate(R,varargin{:});
    
%% get channel&trials
if isempty(R.Name)
    iCh = 1;
    R.Name = SPK.channel{iCh};
else
    iCh = spk_findSpikeChan(SPK,R.Name);
end

SPK = spk_set(SPK,'currenttrials',[],'currentchan',iCh);
if spk_TrialNum(SPK)==0
    R.density = {};
    R.time = NaN;
    return;
end
[i,R.AlignedTo] = spk_getAlignEvent(SPK);

%% time windows
win = spk_getEventWindow(SPK,R.EventWin{:});
win = round([min(win(:,1)) max(win(:,2))]);
SPK = spk_set(SPK,'currenttrials',R.trialindex);

%% compute
fprintf('%s calculating spike density ... ',char(R.Name));
SpikeD = spk_SpikeDensity(SPK,R.Width,win,R.HalfGaussianFlag);
fprintf('done!\n');

%% prepare output
R.density = cell(size(SpikeD));
[R.density{:}] = deal(SpikeD(:).trial);
R.time = SpikeD(1).time;

