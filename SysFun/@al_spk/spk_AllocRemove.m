function s = spk_AllocRemove(s)

% check for residuals of spk_Alloc and remove
% s = spk_AllocRemove(s)

xTr = find(all(isnan(s.trialcode),1));

%% trialcode
s.trialcode(:,xTr) = [];
xTrCode = find(all(isnan(s.trialcode),2));
s.trialcode(xTrCode,:) = [];
s.trialcodelabel(xTrCode) = [];
s.currenttrials = [];

%% spike data
s.spk(:,xTr) = [];
s.spkwave(:,xTr) = [];

% remove NaN timestamps
for i = 1:numel(s.spk)
    xTS = isnan(s.spk{i});
    s.spk{i}(xTS) = [];
    s.spkwave{i,:}(xTS) = [];
end
xCh = all(cellfun('isempty',s.spk),2);
s.spk(xCh,:) = [];
s.spkwave(xCh,:) = [];
s.unittype(xCh) = [];
s.channel(xCh) = '';
s.currentchan = [];
if ~isempty(s.eventcolors)
    s.chancolor(xCh,:) = [];
end

%% analog data
xCh = false(size(s.analog));
for i = 1:numel(s.analog)
    s.analog{i}(xTr,:) = [];
    xSample = all(isnan(s.analog{i}),1);
    s.analog{i}(:,xSample) = [];
    iSample = find(xSample,1,'first');
    s.analogalignbin(i) = s.analogalignbin(i) - iSample +1;
    if ~isempty(s.analogtime{i})
        s.analogtime{i}(xSample) = [];
    end
    if all(isnan(s.analog{i}(:))) 
        xCh(i) = true;
    end
end    
s.analog(xCh) = [];
s.analogname(xCh) = [];
s.analogunits(xCh) = [];
s.analogtime(xCh) = [];
s.analogfreq(xCh) = [];
s.analogalignbin(xCh) = [];
s.currentanalog = [];
    
%% event data
s.events(:,xTr) = [];
for i = 1:numel(s.events)
    s.events{i}(isnan(s.events{i})) = [];
end
xEvents = all(cellfun('isempty',s.events),2);
s.events(xEvents,:) = [];
s.eventlabel(xEvents) = [];
if ~isempty(s.eventcolors)
    s.eventcolors(xEvents,:) = [];
end

%% align
s.align(xTr) = [];


