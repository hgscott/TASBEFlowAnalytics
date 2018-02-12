% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function plot_population_IO_characterization(results)

ticks = TASBEConfig.get('OS.PlotTickMarks');
stemName = TASBEConfig.get('OS.StemName');
directory = TASBEConfig.get('OS.Directory');
deviceName = TASBEConfig.get('OS.DeviceName');

AP = getAnalysisParameters(results);
n_components = getNumGaussianComponents(AP);
hues = (1:n_components)./n_components;

[input_mean] = get_channel_population_results(results,'input');
[output_mean output_std] = get_channel_population_results(results,'output');
in_units = getChannelUnits(AP,'input');
out_units = getChannelUnits(AP,'output');

%%% I/O plots:
% Plain I/O plot:
h = figure('PaperPosition',[1 1 5 3.66]);
set(h,'visible','off');
for i=1:n_components
    loglog(10.^input_mean(i,:),10.^output_mean(i,:),'-','Color',hsv2rgb([hues(i) 1 0.9])); hold on;
    if ticks
        loglog(10.^input_mean(i,:),10.^output_mean(i,:),'+','Color',hsv2rgb([hues(i) 1 0.9]));
    end
    loglog(10.^input_mean(i,:),10.^(output_mean(i,:)+output_std(i,:)),':','Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(10.^input_mean(i,:),10.^(output_mean(i,:)-output_std(i,:)),':','Color',hsv2rgb([hues(i) 1 0.9]));
end;
%if(TASBEConfig.get('OS.FixedAxis')), axis([1e2 1e10 1e2 1e10]); end;
xlabel(['IFP ' in_units]); ylabel(['OFP ' out_units]);
set(gca,'XScale','log'); set(gca,'YScale','log');
if(TASBEConfig.isSet('OS.FixedInputAxis')), xlim(TASBEConfig.get('OS.FixedInputAxis')); end;
if(TASBEConfig.isSet('OS.FixedOutputAxis')), ylim(TASBEConfig.get('OS.FixedOutputAxis')); end;
title(['Population ',stemName,' transfer curve, colored by Gaussian component']);
outputfig(h,[stemName,'-',deviceName,'-pop-mean'],directory);

end
