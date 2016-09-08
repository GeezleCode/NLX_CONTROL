function r = spk_ObjCat(s,ss,FileCode,FileCodeLabel)

% Merge trials into one object (Concatenates @al_spk objects).
% r = spk_cat(s,ss,FileCode,FileCodeLabel)
%
% Adds a trialcode 'cat_index' with trials of s being 1, counting up for
% trials of ss.
%
% s .... first obj
% ss ............... cell array of al_spk obj to concatenate
% FileCode ......... trialcode value (1 value for all trials of this file) [FileCodeN x FileN]
% FileCodeLabel .... {FileCodeN}

r = al_spk;
% ss = [{s} ss];
n = length(ss);

if nargin<3
    FileCodeLabel = {'cat_index'};
    nObj = 1+length(ss);
    FileCode = 1:nObj;
end

%% check objects
TrNum(1,1) = spk_TrialNum(s);
for i=1:n
    TrNum(1,i+1) = spk_TrialNum(ss{i});
end

%% header
r.version = s.version;
r.name = s.name;
r.tag = '';
r.comment = '';
r.subject = '';
r.file = cell(n+1,1);

r.file{1} = s.file;
r.date{1} = s.date;
for i=1:n
    r.file{i+1} = ss{i}.file;
    r.date{i+1} = ss{i}.date;
end

%% Trialcode
% Trialcode of first file
r.trialcode = s.trialcode;
r.trialcodelabel = s.trialcodelabel;

% Add file related trialcodes
for i=1:size(FileCode,1)
    TrCodeNr = size(r.trialcode,1)+1;
    r.trialcode(TrCodeNr,:) = FileCode(i,1);
    r.trialcodelabel{TrCodeNr} = FileCodeLabel{i};
end

% concatenate trialcodes
for i=1:n
    nTrCode = size(ss{i}.trialcode,1);
    nTr_r = size(r.trialcode,2);
    nTr_ss = size(ss{i}.trialcode,2);
    for iTrCode = 1:nTrCode
        cTrCode = strmatch(ss{i}.trialcodelabel{iTrCode},r.trialcodelabel,'exact');
        if isempty(cTrCode)
            cTrCode = size(r.trialcode,1)+1;
            r.trialcode(cTrCode,1:nTr_r) = NaN;
        end
        r.trialcode(cTrCode,nTr_r+1:nTr_r+nTr_ss) = ss{i}.trialcode(iTrCode,:);
    end
    
    % file related filecodes
    for j=1:size(FileCode,1)
        TrCodeNr = strmatch(FileCodeLabel,r.trialcodelabel);
        r.trialcode(TrCodeNr,nTr_r+1:nTr_r+nTr_ss) = FileCode(j,i+1);
    end
end

%% align
r.align = s.align;
r.alignevent = '';
for i=1:n
    r.align = cat(2,r.align,ss{i}.align);
end

%% Events
r.events = s.events;
r.eventlabel = s.eventlabel;
r.eventcolors = s.eventcolors;
r.eventmode = s.eventmode;
for i=1:n
    nEv = size(ss{i}.events,1);
    nTr_r = size(r.events,2);
    nTr_ss = size(ss{i}.events,2);
    for iEv = 1:nEv
        cEv = strmatch(ss{i}.eventlabel{iEv},r.eventlabel,'exact');
        if isempty(cEv)
            cEv = size(r.events,1)+1;
            r.eventlabel(cEv) = ss{i}.eventlabel(iEv);
        end
        r.events(cEv,nTr_r+1:nTr_r+nTr_ss) = ss{i}.events(iEv,:);
    end
end

%% spike channels
r.unittype = s.unittype;
r.channel = s.channel;
r.spk = s.spk;
r.spkwave = s.spkwave;
r.spkwavealign = s.spkwavealign;
r.currentchan = [];
r.chancolor = s.chancolor;
for i=1:n
    
    [nCh_ss,nTr_ss] = size(ss{i}.spk);
    [nCh_r,nTr_r] = size(r.spk);
    cTrNr = (sum(TrNum(1:i))+1) : sum(TrNum(1:i+1));
    
    if nTr_r==0
        r.channel = cell(0,0);
        r.unittype = cell(0,0);
        r.spk = cell(0,0);
        r.spkwave = cell(0,0);
    end
    
    if nCh_ss==0
        r.spk(:,cTrNr) = {[]};
        if ~isempty(r.spkwave)
            r.spkwave(:,cTrNr) = {[]};
        end
    else    
        for iCh = 1:nCh_ss % loop channels
            
            % check for existing channel
            cChNr = strmatch(ss{i}.channel{iCh},r.channel);
            if isempty(cChNr);cChNr = size(r.spk,1)+1;end
            
            r.channel(cChNr) = ss{i}.channel(iCh);
            r.unittype(cChNr) = ss{i}.unittype(iCh);
            r.spk(cChNr,cTrNr) = ss{i}.spk(iCh,:);
            if ~isempty(ss{i}.spkwave)
                r.spkwave(cChNr,cTrNr) = ss{i}.spkwave(iCh,:);
                r.spkwavefreq(1,cChNr) = ss{i}.spkwavefreq(iCh);
                r.spkwavealign(1,cChNr) = ss{i}.spkwavealign(iCh);
            end
        end
    end
end

%% analog data
r.analog = s.analog;
r.analogunits = s.analogunits;
r.analogname = s.analogname;
r.analogtime = s.analogtime;
r.analogfreq = s.analogfreq;
r.analogalignbin = s.analogalignbin;
r.currentanalog = [];
if ~isempty(r.analog)
    for i=1:n
        nAna = length(ss{i}.analog);
        nTr_r = cellfun('size',r.analog,1);
        nTr_ss = cellfun('size',ss{i}.analog,1);
        for iAna = 1:nAna
            cAna = strmatch(ss{i}.analogname{iAna},r.analogname);
            if isempty(cAna)
                error('Concatenating of non existing analog channels is not implemented yet!');
            end
            [r.analog{cAna},analogalignbin]  = mergearrays([r.analog(cAna) ss{i}.analog{iAna}],1,[1 r.analogalignbin(cAna) 1;1 ss{i}.analogalignbin(iAna) 1]);
            r.analogalignbin(cAna) = analogalignbin(2);
        end
    end
end

%% settings
% put settings into NEW 'spk_cat' field
if ~isempty(s.settings)
    r.settings.spk_cat{1} = s.settings;
end
for i=1:n
    r.settings.spk_cat{i+1} = ss{i}.settings;
end

%% user data
% put settings into NEW 'spk_cat' field
if ~isempty(s.settings)
    r.userdata.spk_cat{1} = s.userdata;
end
for i=1:n
    r.userdata.spk_cat{i+1} = ss{i}.userdata;
end

%% misc
r.timeorder = s.timeorder;
if ~isempty(s.stimulus);r.stimulus = s.stimulus;end
for i=1:n
    if r.timeorder ~= ss{i}.timeorder;
        error('Timeorder does not match between files!')
    end
    if ~isempty(r.stimulus);r.stimulus = cat(2,r.stimulus,ss{i}.stimulus);end
end
