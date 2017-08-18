function [s,TrialNr] = spk_AddTrialData(s,TrialNr,varargin)

% Add trial data for svereal datatypes
% TrialNr ... if [] pads trial data to end of arrays
% varargin ... property value pairs 
%              'spk','analog','events','align','trialcode','stimulus'

% check input
if rem(length(varargin),2)~= 0
     error('Arguments must be Property/Value pairs !');
end
numProp = length(varargin)./2;

if isempty(TrialNr)
    TrialNr = spk_numtrials(s);
    TrialNr = TrialNr+1;
end

for i = 1:numProp
     
     cprop = lower(varargin{i*2-1});
     cval = varargin{i*2};
     
     switch cprop
         case 'spk'
             s.spk(:,TrialNr) = cval;
         case 'analog'
             s.analog(:,TrialNr) = cval;
         case 'events'
             s.events(:,TrialNr) = cval;
         case 'align'
             s.align(:,TrialNr) = cval;
         case 'trialcode'
             s.trialcode(:,TrialNr) = cval;
         case 'stimulus'
             s.stimulus(:,TrialNr) = cval;
     end
end

TrialNr = spk_TrialNum(s);