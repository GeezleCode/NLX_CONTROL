function t = spk_AnalogTimematrix(s)

% calculates  time vector for analog data
numAna = length(s.currentanalog);

for iA = s.currentanalog
    iANr = find(s.currentanalog==iA);
    
    [NumTrials,NumSamples] = size(s.analog{iA});
    t{iANr} = zeros(1,NumSamples);
    t{iANr}(s.analogalignbin:-1:1) = [0 : ((-1)*(1000/s.analogfreq(iA))) : ((s.analogalignbin-1)*(-1)*(1000/s.analogfreq(iA)))];
    t{iANr}(s.analogalignbin:1:NumSamples) = [0 : (1000/s.analogfreq(iA)) : ((NumSamples-s.analogalignbin)*(1000/s.analogfreq(iA)))];
end

if numAna==1
    t = t{1};
end