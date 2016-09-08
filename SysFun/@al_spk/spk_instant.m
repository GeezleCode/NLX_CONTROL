function [mSecF,mSec,h] = spk_instant(s,timeWin,plottype,varargin)

% calculates instantaneaous spike rate for the current trials
% function [mSecF,mSec,h] = spk_instant(s,rateflag,plottype,varargin)
%
% ratescale

NumCurrChan = length(spk_CheckCurrentChannels(s,0));
numCurrTr = length(spk_CheckCurrentTrials(s,0));

mSec = timeWin(1):timeWin(2);
mSecF = zeros(numCurrTr,length(mSec),NumCurrChan);

for cc = 1:NumCurrChan
    NumSpk = cellfun('length',s.spk{j,:});
    TotalNumSpk = sum(NumSpk);
    sTimes = zeros(1,TotalNumSpk);
    IFR = zeros(1,TotalNumSpk);
    for ct = 1:numCurrTr
        i = s.currenttrials(ct);
        j = s.currentchannels(cc);
        
        dt = abs(diff(s.spk{j,i}));
        s.spk{j,i}
        
        
    
    for ct = 1:numCurrTr
        i = s.currenttrials(ct);
        j = s.currentchannels(cc);
        
        % info
        numSpk = length(s.spk{j,i});
        SpkInWin = find(s.spk{j,i}>=timeWin(1) & s.spk{j,i}<=timeWin(2));
       
        % get inst firing rate
        dt = abs(diff(s.spk{j,i}));
        freq = 1./(dt*10^s.timeorder);
        
        %make vec head
        if ~isempty(SpkInWin) & numSpk>1
            if SpkInWin(1)==1
                mSecF(i,1:ceil(s.spk{j,i}(SpkInWin(1)).*(10^s.timeorder)./(10^(-3)))-timeWin(1)+1-1) = 0;%freq(SpkInWin(1));
            elseif SpkInWin(1)>1
                mSecF(i,1:ceil(s.spk{j,i}(SpkInWin(1)).*(10^s.timeorder)./(10^(-3)))-timeWin(1)+1-1) = freq(SpkInWin(1)-1);
            end
            
            if length(SpkInWin)>=3
                for ttl = SpkInWin(2:end-1)'
                    mSecF(i, ...
                        ceil(s.spk{j,i}(ttl).*(10^s.timeorder)./(10^(-3)))-timeWin(1)+1 : ...
                        ceil(s.spk{j,i}(ttl+1).*(10^s.timeorder)./(10^(-3)))-timeWin(1)+1-1) = freq(ttl);
                end
            end
            
            % make vec tail
            if SpkInWin(end)==numSpk
                mSecF(i,ceil(s.spk{j,i}(SpkInWin(end)).*(10^s.timeorder)./(10^(-3)))-timeWin(1)+1:end) = 0;
            elseif SpkInWin(end)<numSpk
                mSecF(i,ceil(s.spk{j,i}(SpkInWin(end)).*(10^s.timeorder)./(10^(-3)))-timeWin(1)+1:end) = freq(SpkInWin(end));
            end  
        end
    end
end

% plot histogram
h = [];
if nargin<3;return;end
mInst = sum(mSecF,1)./numCurrTr;
switch upper(plottype)
     case 'LINE'
          h = line(mSec,mInst,varargin{:});
     case 'PATCH'
          X = [mSec(end) mSec(1)];Y = [0 0];
          for i = 2:numbins
               X = cat(2,X,[mSec(i-1) mSec(i)]);
               Y = cat(2,Y,[mInst(i-1) mInst(i-1)]);
          end
          h = patch('Xdata',X,'ydata',Y,varargin{:});
end
