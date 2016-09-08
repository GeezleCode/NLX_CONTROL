function spk_plot(s)

n = spk_SpikeChanNum(s);
for i=1:n
    s = spk_set(s,'currentchan',i);
    figure
    spk_SpikeRaster(s,[0 1],[],[],'.');
    spk_EventRaster(s,[0 1],[],[],'line','color','r');
end

