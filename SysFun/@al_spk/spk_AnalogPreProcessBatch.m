function [s,P] = spk_AnalogPreProcessBatch(s,varargin)

% preprocessing of spk objects
% 
%% Settings
P.SpikeChannels = {};%{'Sc1' 'Sc2' 'Sc3' 'Sc4'};
P.SpikePoolUnitTypes = {};% {{'MUA','TUA','SUA'},{'HASH'}};
P.SpikePoolSuffix = {};%{'MUA' 'HASH'};

P.AnalogChannels = {'CSC1' 'CSC2' 'CSC3' 'CSC4'};

% saturation check, see spk_AnalogIsSaturated.m
P.AnalogSatBoundary = [];
P.AnalogSatAllowPeaks = 3;% number of samples in saturation
P.AnalogSatEventWin = {'NLX_SUBJECT_START' 'NLX_STIM_ON'};
P.AnalogSatEventWinOffset = {[0 700] [0 1000]};

P.AnalogArtefactWin1 = '';
P.AnalogArtefactWin2 = '';
P.AnalogArtefactCrit = {};

% pass band 
P.AnalogBand = [];%[8 100];%[1 150]
P.AnalogFilterOrder = 6;

P.AnalogRemoveLine = false;
P.AnalogRemoveLineF = [];
P.AnalogRemoveLineWin = {'NLX_SUBJECT_START','NLX_STIM_ON','NLX_STIM_OFF'};

P.CriticalTrials = [];

P = StructUpdate(P,varargin{:});

ChNr = s.currentanalog(~isnan(s.currentanalog));
ChNum = length(ChNr);
disp(['pre-process analog data ...']);
for iCh = 1:ChNum
    P.AnalogChannels(iCh) = s.analogname(ChNr(iCh));
    s = spk_set(s,'currentanalog',ChNr(iCh),'currenttrials',[]);
    
    %% ANALOG: delete trials that reached saturation
    if ~isempty(P.AnalogSatEventWin)
        isSatTrial = spk_AnalogIsSaturated(s,P.AnalogSatBoundary,P.AnalogSatAllowPeaks,P.AnalogSatEventWin,P.AnalogSatEventWinOffset,false);
        %             s = spk_TrialCut(s,SatTrials);
        P.CriticalTrials = union(P.CriticalTrials,find(isSatTrial));
    end
    
    %% detect Artefacts
    if ~isempty(P.AnalogArtefactCrit)
        ArtTrials = spk_AnalogArtefactDetect(s,P.AnalogArtefactWin1,P.AnalogArtefactWin2,true,P.AnalogArtefactCrit{:});
        %             s = spk_TrialCut(s,ArtTrials);
        P.CriticalTrials = union(P.CriticalTrials,ArtTrials);
    end
    
    %% ANALOG: bandpass
    if ~isempty(P.AnalogBand)
        s = spk_AnalogFiltFiltButter(s,P.AnalogFilterOrder,P.AnalogBand,'bandpass');
    end
    
    %% ANALOG: remove line noise
    if P.AnalogRemoveLine
        for iF = 1:length(P.AnalogRemoveLineF)
            %                 s = spk_AnalogRemoveSine(s,50);
            %                 s = spk_AnalogChronuxRemoveLine(s,[],50);
            %                 s = spk_AnalogChronuxRemoveLine(s,[],50,'rmlinesmovingwinc',[0.4,0.2],10);
            %                 s = spk_AnalogRemoveLineAlex(s,3,[49 51]);
            %                 s = spk_AnalogFiltFiltButter(s,3,[49 51],'stop');
            %                 s = spk_AnalogRemoveLine(s,50,'NLX_SUBJECT_START','NLX_STIM_ON');
            s = spk_AnalogRemoveLineWin(s,P.AnalogRemoveLineF(iF),P.AnalogRemoveLineWin,false);
        end
    end
end
settings = spk_get(s,'settings');
settings.AnalogPreProcess = P;
s = spk_set(s,'settings',settings);







