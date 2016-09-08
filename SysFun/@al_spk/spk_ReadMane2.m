function s = spk_ReadMane2(s,FilePath,Chan)

% reads a mane2 file into a @al_spk object
% function s = spk_read_mane2(s,FilePath,Chan)


%% open file
[fid,fid_mess] = fopen(FilePath,'r');
if fid == -1;disp(fid_mess);disp(FilePath);end

s.file = FilePath;
[fDir,fName,fExt] = fileparts(FilePath);

%% size of file
fseek(fid,0,'eof');
FileBytes = ftell(fid);
fseek(fid,0,'bof');

%% waitbar 
h_wait = waitbar(0,['reading ' num2str(FileBytes) ' bytes (' sprintf('%1.3f',FileBytes/1048576) 'MB, ' sprintf('%1.0f',FileBytes/1024) 'KB)']);
 
%% do reading 
fseek(fid,0,'bof');
read_flag = true;
trial_count = 0;
while read_flag

    %% read block
    block_pos = ftell(fid);
    waitbar(ftell(fid)/FileBytes);
    [block_size,WORD_count] = fread(fid,1,'uint16');

    %% check if block is terminated properly
    if block_pos+(2*block_size)>FileBytes;
        disp('No proper termination of file ! => last set is not complete.');
        break;
    end

    %% read block data
    [DATA,WORD_count] = fread(fid,block_size,'uint16');
    block_name = upper(rkradix(DATA(1)));

    switch block_name
        case 'ID '
            filename = deblank([rkradix(DATA(2)) rkradix(DATA(3)) rkradix(DATA(4)) rkradix(DATA(5))]);
            if ~strcmp(upper(deblank(filename)),upper([fName,fExt]));
                disp(['File name conflict !!! ' upper(s.ID.file) ' was saved as ' upper(filename)]);
                s.name = upper(filename);
            end
            s.tag = deblank([rkradix(DATA(4)) rkradix(DATA(5))]);

            if DATA(8)>=100 & DATA(8)<200
                current_year = DATA(8)-100+2000;
            elseif DATA(8)<100 & DATA(8)<200
                current_year = 2000-(100-DATA(8));
            end

            s.date = datestr(datenum(current_year,DATA(7),DATA(6),DATA(9),DATA(10),DATA(11)),'dd-mmm-yyyy HH:MM:SS');
            s.version 	= strcat(num2str(DATA(13)),'.',num2str(DATA(14)));

        case 'GLB'
            s.settings.GLB = DATA;
        case 'PRM'
            s.settings.PRM(trial_count + 1) = DATA;
        case 'BEH'
            trial_count = trial_count + 1;
            s.trialcode(1:10,trial_count) = DATA(1:10,1);
            s.events{1,trial_count} = DATA(11:end);
        case 'ANA'
            % this counts the different ANAlog blocks
            % reset for a new trial
            if last_ANA_trial < trial_count;ANACHAN_count=0;end
            ANACHAN_count  = ANACHAN_count+1;
            last_ANA_trial = trial_count;
            s.Analog.channel    = union(s.Analog.channel,DATA(6));
            s.Analog.SampleFreq = union(s.Analog.SampleFreq,DATA(10));
            s.Analog.data{ANACHAN_count,trial_count} = DATA(11:end);
        case 'SP1'
            s.Spike.SampleFreq 	= DATA(10);
            s.Spike.times{1,trial_count} 	= DATA(11:end);
        case 'SP2'
            s.Spike.SampleFreq 	= DATA(10);
            s.Spike.times{2,trial_count} 	= DATA(11:end);
        case 'END'
            if DATA(4)>=100 & DATA(4)<200
                current_year = DATA(4)-100+2000;
            elseif DATA(4)<100 & DATA(4)<200
                current_year = 2000-(100-DATA(4));
            end
            % date year can be corrupted -> just take the end time
            s.End.time = datestr(datenum(current_year,DATA(3),DATA(2),DATA(5),DATA(6),DATA(7)),'HH:MM:SS');
            read_flag = false;

        
        case 'PST'
             s.Video.SampleFreq = DATA(10);
             s.Video.time{trial_count}	= DATA(11:end);
         case {'PAX' 'RCX'}
             s.Pattern.SampleFreq 	= DATA(10);
             s.Pattern.pos{trial_count}(:,1) 	= DATA(11:end);
         case {'PAY' 'RCY'}
             s.Pattern.SampleFreq 	= DATA(10);
             s.Pattern.pos{trial_count}(:,2) 	= DATA(11:end);
         case 'TAX'
             s.Target.SampleFreq 	= DATA(10);
             s.Target.pos{trial_count}(:,1) 	= DATA(11:end);
         case 'TAY'
             s.Target.SampleFreq 	= DATA(10);
             s.Target.pos{trial_count}(:,2) 	= DATA(11:end);
         case 'PSX'
             s.Hand.SampleFreq 	= DATA(10);
             s.Hand.pos{trial_count}(:,1) 	= DATA(11:end);
         case 'PSY'
             s.Hand.SampleFreq 	= DATA(10);
             s.Hand.pos{trial_count}(:,2) 	= DATA(11:end);
         case 'EYX'
             s.Eye.videopos{trial_count}(:,1) 	= DATA(11:end);
         case 'EYY'
             s.Eye.videopos{trial_count}(:,2) 	= DATA(11:end);
         case 'EDX'
             s.Eye.SampleFreq 	= DATA(10);
             s.Eye.pos{trial_count}(:,1) 	= DATA(11:end);
         case 'EDY'
             s.Eye.SampleFreq 	= DATA(10);
             s.Eye.pos{trial_count}(:,2) 	= DATA(11:end);
        otherwise
            iAna = spk_FindAnalog(s,block_name);
            if isnan(iAna)
                [s,iAna] = spk_AddAnalogChan(s,Name,Data,SF,Time,Units,AlignBin)
            end            
            warning(['Unknown block name ''' upper(block_name) ''' !']);
     end

end
close(h_wait);
fclose(fid);

%% trialcodelabel
s.trialcodelabel{1,1} = 'BEH1';
s.trialcodelabel{2,1} = 'set';
s.trialcodelabel{3,1} = 'trialnr';
s.trialcodelabel{4,1} = 'condition';
s.trialcodelabel{5,1} = 'BEH5';
s.trialcodelabel{6,1} = 'BEH6';
s.trialcodelabel{7,1} = 'BEH7';
s.trialcodelabel{8,1} = 'BEH8';
s.trialcodelabel{9,1} = 'BEH9';
s.trialcodelabel{10,1} = 'BEH10';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

%_____________________________________________________
% recorded trials and conditions
%_____________________________________________________
s.Condition.name 		= sort(unique(s.Trial.Condition));
s.ID.conditions 		= sort(unique(s.Trial.Condition));
s.Trial.recordedNr 		= length(s.Trial.TrialTotal);
s.Trial.currentNr 		= length(s.Trial.TrialTotal);
s.Trial.totalNr 		= max(s.Trial.TrialTotal);
s.Trial.selection 		= 1:s.Trial.recordedNr;
s.ID.trials 			= strcat(num2str(s.Trial.recordedNr),'/',num2str(s.Trial.totalNr));	

%_____________________________________________________
% Trials of PRM adjustments
%_____________________________________________________
for ii = 1:length(s.Setup.PRMTrial)
     if s.Setup.PRMTrial(ii)>s.Trial.recordedNr
          PRMTotal(ii) = NaN;
     else
          PRMTotal(ii) = s.Trial.TrialTotal(s.Setup.PRMTrial(ii));
     end
end
s.Setup.PRMTrial = PRMTotal;

%__________________
% check read fields
%__________________
if isempty(s.Hand.pos);s.read.Hand = 0;end
if isempty(s.Eye.pos)&isempty(s.Eye.videopos);s.read.Eye = 0;end
if isempty(s.Spike.times);s.read.Spike = 0;end
if isempty(s.Target.pos);s.read.Target = 0;end
if isempty(s.Pattern.pos);s.read.Pattern = 0;end
if isempty(s.Analog.data);s.read.Analog = 0;end

%___________________________________________
% SCREEN DISTANCE and PIXEL WIDTH 
%___________________________________________
if datenum(s.ID.date) < datenum('23-Dec-1999')
     s.Setup.ScreenDistance = 115; % cm
     s.Setup.PixelRatio 	 = 114/800;% cm/pixel
     
elseif datenum(s.ID.date) >= datenum('23-Dec-1999') ...
     & datenum(s.ID.date) < datenum('01-Jul-2002')
     s.Setup.ScreenDistance 	= 62; % cm
     s.Setup.PixelRatio 		= 142/800;% cm/pixel
     % visible screen width 1-725 Pixel horizontal
     
elseif datenum(s.ID.date) >= datenum('01-Jul-2002')
     % Umbau des Bildschirmes am 1.7.2002
     % Kopfhaltermitte bei 115 cm (Augen bei 113 ?!)
     s.Setup.ScreenDistance 	= 113; % cm
     % X: 700 pixel = 106 cm Y: 500 pixel = 76 cm
     s.Setup.PixelRatio 		= 106/700;% cm/pixel
end
s.Setup.ScreenRatio = s.Setup.ScreenDistance * (1/57.3);% cm/deg
s.Setup.VisualRatio = s.Setup.PixelRatio / s.Setup.ScreenRatio;% deg/pixel

%_____________________________________________________
% Time data
%_____________________________________________________
h_wait = waitbar(0,[s.ID.file ' - construct time data']);
for i = 1:s.Trial.currentNr
     %_____________________________________________________
     % delete events with values of 65535 
     %_____________________________________________________
     s.Time.Events(find(s.Time.Events(:,i)==65535),i) = NaN;
     %_____________________________________________________
     % Hand time
     %_____________________________________________________
     if s.read.Hand & (strcmp(s.Hand.format,'draco18') | strcmp(s.Hand.format,'manip2'));
          s.Hand.time{i} = s.Video.time{i};
     end
     %_____________________________________________________
     % write TimeVector for EyeData 500Hz                             %
     % fitted to 75Hz monitor refresh by addition of first Frame Time %
     %_____________________________________________________
     if s.read.Eye & strcmp(s.Eye.format,'analog') & ~isempty(s.Video.time{i});
          BinNum = size(s.Eye.pos{i}(:,1),1);
          s.Eye.time{i} = round(([0:1:BinNum-1]).*((1/s.Eye.SampleFreq)*1000)) + s.Video.time{i}(1);
     else
          s.Eye.time{i} = [];
     end
     %_____________________________________________________
     % data of analog channels
     %_____________________________________________________
     if s.read.Analog & ~isempty(s.Analog.channel)
          BinNum = size(s.Analog.data{s.Analog.channel(1),i},1);
          s.Analog.time{i} = round(([1:1:BinNum]).*((1/s.Analog.SampleFreq)*1000)) + s.Video.time{i}(1);
     end
end
close(h_wait);

%___________________________________________
% read definitions for the current extension
%___________________________________________
def_fun = deblank(['definition_' strrep(s.ID.ext,'.','')]);
% if exist([def_fun '.m'],'file')
     s = feval(def_fun,s);
     % clear events called 'NaN'
     NaNevents = strmatch('NAN',upper(s.Time.EVdef));
     s.Time.EVdef(NaNevents,:) = '';
     s.Time.Events(NaNevents,:) = [];
% else
%      warning(['No definitions available for *' s.ID.ext ' - files']);
%      return;
% end
     
%_____________________________________________________
% conversion
%_____________________________________________________
h_wait = waitbar(0,[s.ID.file ' - data conversion']);
for i = 1:s.Trial.currentNr
     if s.read.Target & doConversion
          if ~iscell(s.Target.pos) | isempty(s.Target.pos{i})
               s.Target.pos(i) ={[NaN NaN]};
          end
     end
     if s.read.Eye & doConversion
          if isempty(s.Eye.pos{i});
               s.Eye.pos{i} = [NaN NaN];
          else
               switch upper(s.Eye.format)
               case 'ANALOG'
                    ScreenCenter(1)     = s.Setup.GLB(strmatch('elmax_x',s.Setup.GLBdef))/2;
                    ScreenCenter(2)     = s.Setup.GLB(strmatch('elmax_y',s.Setup.GLBdef))/2;
                    Offset(1)           = s.Setup.PRM(strmatch('offset_x',s.Setup.PRMdef));
                    Offset(2)           = s.Setup.PRM(strmatch('offset_y',s.Setup.PRMdef));
                    Gain(1)             = s.Setup.PRM(strmatch('gain_x',s.Setup.PRMdef));
                    Gain(2)             = s.Setup.PRM(strmatch('gain_y',s.Setup.PRMdef));
                    [s.Eye.pos{i}(:,1),s.Eye.pos{i}(:,2)] = conv_ana_eye( ...
                         s.Eye.pos{i}(:,1), ...
				     s.Eye.pos{i}(:,2), ...
				     s.Setup.ScreenDistance, ...
				     1/s.Setup.PixelRatio, ...
				     ScreenCenter, ...
				     Offset, ...
                         Gain);
               end
          end
	end
     if s.read.Hand  & doConversion
          if isempty(s.Hand.pos{i});s.Hand.pos{i} = [NaN NaN];else
               switch upper(s.Hand.format)
               case 'MANIP2'
                    [s.Hand.pos{i}(:,1),s.Hand.pos{i}(:,2)] = conv_manip2(s.Hand.pos{i}(:,1),s.Hand.pos{i}(:,2),s.Setup.MotorRatio);
               case 'DRACO18'
                 s.Setup.MotorRatio = 6;
			  [s.Hand.pos{i}(:,1),s.Hand.pos{i}(:,2)] = conv_draco18(s.Hand.pos{i}(:,1),s.Hand.pos{i}(:,2),s.Setup.MotorRatio);
               end
          end
     end
     waitbar(i/s.Trial.currentNr);
end
close(h_wait);
if s.read.Spike & doConversion
     [s] = convertspike(s,0,0);
end

% % check bad eye data
% if s.read.Eye & doConversion
%      OUT = getbadeye(s);
%      s.Trial.BEH(get_def(s,'BEH','errorcode'),logical(OUT)) = 0;
% end

