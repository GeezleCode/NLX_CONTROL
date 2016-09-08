function s = spk_AnalogCart2Pol(s,XChanName,YChanName,NewXName,NewYName)

% Applies cart2pol.m to analog data.
% s = spk_AnalogCart2Pol(s,XChanName,YChanName,NewXName,NewYName)
% Input:
% XChanName,YChanName ...... Name of an analog channel as in s.analog

%% get the channel index
iChanX = spk_findAnalog(s,XChanName);
iChanY = spk_findAnalog(s,YChanName);

%% copy channel
if nargin>3
    [s,iChanX] = spk_AnalogCopyChan(s,XChanName,NewXName);
    [s,iChanY] = spk_AnalogCopyChan(s,YChanName,NewYName);
end

%% compute
[s.analog{iChanX},s.analog{iChanY}] = cart2pol(s.analog{iChanX},s.analog{iChanY});
s.analogunits{iChanX} = 'rad';

