function s = spk_AnalogPol2Cart(s,ThetaChanName,RChanName,NewThetaName,NewRName)

% Applies cart2pol.m to analog data.
% s = spk_AnalogCart2Pol(s,XChanName,YChanName,NewXName,NewYName)
% Input:
% XChanName,YChanName ...... Name of an analog channel as in s.analog

%% get the channel index
iChanX = spk_FindAnalog(s,ThetaChanName);
iChanY = spk_FindAnalog(s,RChanName);

%% copy channel
if nargin>3
    [s,iChanX] = spk_AnalogCopyChan(s,ThetaChanName,NewThetaName);
    [s,iChanY] = spk_AnalogCopyChan(s,RChanName,NewRName);
end

%% compute
[s.analog{iChanX},s.analog{iChanY}] = pol2cart(s.analog{iChanX},s.analog{iChanY});
s.analogunits{iChanX} = s.analogunits{iChanY};% take the units of R channel
