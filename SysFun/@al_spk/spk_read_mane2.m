function s = read_mane2(s,filepath,channel)

% reads a mane2 file into a @al_spk object
% function s = read_mane2(s,filepath,channel)

[pathname,filename,extension] = fileparts(filepath);
m2 = mane2;
m2 = setread(m2,'SPIKE');
m2.ID.path = pathname;
m2.ID.file = [filename extension];
m2 = read(m2,1);


s.name = '';
s.tag  = '';
s.subject = '';
s.file = [filename extension];
s.channel = num2str(channel);
s.date = m2.ID.date;
s.unittype = '';% e.g. 'MUA' 'SUA'

trialI = find(m2.Trial.BEH(get_def(m2,'BEH','errorcode'),:)==20);
numtrials = length(trialI);

s.spk = m2.Spike.times(channel+1,trialI);
s.timeorder = -3;

s.trialgroupname = strvcat('filenr','trialnr','setnr','condition','errorcode');
s.trialgroup(:,1) = ones(numtrials,1);
[INDEX,VALUE] = get_def(m2,'BEH','total');
s.trialgroup(:,2) = VALUE(trialI)';
[INDEX,VALUE] = get_def(m2,'BEH','set');
s.trialgroup(:,3) = VALUE(trialI)';
[INDEX,VALUE] = get_def(m2,'BEH','condition');
s.trialgroup(:,4) = VALUE(trialI)';
[INDEX,VALUE] = get_def(m2,'BEH','errorcode');
s.trialgroup(:,5) = VALUE(trialI)';

s.events = num2cell(m2.Time.Events(:,trialI));
s.eventnames = m2.Time.EVdef;
s.eventcolors = zeros(size(m2.Time.EVdef,1),3);
