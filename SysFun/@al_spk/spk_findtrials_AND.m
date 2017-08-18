function [INDEX,s] = spk_findtrials_AND(s,varargin)

% find trials with trialcodes given in varargin
%
% INDEX = spk_findtrials_AND(s,trialcodelabel,val,...)
%
% INPUT
% trialcodelabel
% val ... vector of trial code values to get
%
% OUTPUT 
% INDEX ... trialnumbers  
% s ....... al_spk object with currenttrials field set to INDEX

if rem(length(varargin),2)~=0
    error('spk_findtrials_AND: input must be trialcodelabel/trialcode PAIRS !');
end

INDEX = [];
codenumber=0;
for i=1:2:length(varargin)-1
    codenumber=codenumber+1;
    trcd_i = spk_findtrialcodelabel(s,varargin{i});

    if isempty(trcd_i);
        continue;
    end
    
    if codenumber==1
        INDEX = find(ismember(s.trialcode(trcd_i,:),varargin{i+1}));
    elseif codenumber>1
        INDEX = intersect(INDEX,find(ismember(s.trialcode(trcd_i,:),varargin{i+1})));
    end
end

s.currenttrials = INDEX;



