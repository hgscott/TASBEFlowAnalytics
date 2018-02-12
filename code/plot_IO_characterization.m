% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function plot_IO_characterization(results,in_channel,out_channel)
if nargin<2, in_channel = 'input'; end;
if nargin<3, out_channel = 'output'; end;

step = TASBEConfig.get('OS.PlotEveryN');
ticks = TASBEConfig.get('OS.PlotTickMarks');
stemName = TASBEConfig.get('OS.StemName');
deviceName = TASBEConfig.get('OS.DeviceName');
directory = TASBEConfig.get('plots.plotPath');

AP = getAnalysisParameters(results);
n_bins = get_n_bins(getBins(AP));
hues = (1:n_bins)./n_bins;
fa = getFractionActive(results);

[input_mean] = get_channel_results(results,in_channel);
[output_mean output_std] = get_channel_results(results,out_channel);
in_units = getChannelUnits(AP,in_channel);
out_units = getChannelUnits(AP,out_channel);

%%% I/O plots:
% Plain I/O plot:
h = figure('PaperPosition',[1 1 5 3.66]);
set(h,'visible','off');
for i=1:step:n_bins
    which = fa(i,:)>getMinFractionActive(AP);
    loglog(input_mean(i,which),output_mean(i,which),'-','Color',hsv2rgb([hues(i) 1 0.9])); hold on;
    if ticks
        loglog(input_mean(i,which),output_mean(i,which),'+','Color',hsv2rgb([hues(i) 1 0.9]));
    end
    loglog(input_mean(i,which),output_mean(i,which).*output_std(i,which),':','Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(input_mean(i,which),output_mean(i,which)./output_std(i,which),':','Color',hsv2rgb([hues(i) 1 0.9]));
end;
%if(TASBEConfig.get('OS.FixedAxis')), axis([1e2 1e10 1e2 1e10]); end;
xlabel(['IFP ' in_units]); ylabel(['OFP ' out_units]);
set(gca,'XScale','log'); set(gca,'YScale','log');
if(TASBEConfig.isSet('OS.FixedInputAxis')), xlim(TASBEConfig.get('OS.FixedInputAxis')); end;
if(TASBEConfig.isSet('OS.FixedOutputAxis')), ylim(TASBEConfig.get('OS.FixedOutputAxis')); end;
title(['Raw ',stemName,' transfer curve, colored by constitutive bin']);
outputfig(h,[stemName,'-',deviceName,'-mean'],directory);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plasmid system is disabled, due to uncertainty about correctness
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Normalized plot color by plasmid count:
% h = figure('PaperPosition',[1 1 5 3.66]);
% set(h,'visible','off');
% for i=1:step:n_bins
%     pe=getPlasmidEstimates(results);
%     which = fa(i,:)>0.9;
%     loglog(input_mean(i,which),output_mean(i,which)./pe(i,which),'-','Color',hsv2rgb([hues(i) 1 0.9])); hold on;
%     if ticks
%         loglog(input_mean(i,which),output_mean(i,which)./pe(i,which),'+','Color',hsv2rgb([hues(i) 1 0.9]));
%     end
%     loglog(input_mean(i,which),output_mean(i,which)./pe(i,which).*output_std(i,which),':','Color',hsv2rgb([hues(i) 1 0.9]));
%     loglog(input_mean(i,which),output_mean(i,which)./pe(i,which)./output_std(i,which),':','Color',hsv2rgb([hues(i) 1 0.9]));
% end;
% %if(TASBEConfig.get('OS.FixedAxis')), axis([1e2 1e10 1e2 1e10]); end;
% set(gca,'XScale','log'); set(gca,'YScale','log');
% xlabel(['IFP ' in_units]); ylabel(['OFP ' out_units '/plasmid']);
% if(TASBEConfig.get('OS.FixedNormalizedInputAxis')), xlim(TASBEConfig.get('OS.FixedNormalizedInputAxis')); end;
% if(TASBEConfig.get('OS.FixedNormalizedOutputAxis')), ylim(TASBEConfig.get('OS.FixedNormalizedOutputAxis')); end;
% title(['Normalized ',TASBEConfig.get('OS.DeviceName'),' transfer curve, colored by plasmid count']);
% outputfig(h,[TASBEConfig.get('OS.StemName'),'-',TASBEConfig.get('OS.DeviceName'),'-mean-norm'],TASBEConfig.get('OS.Directory'));

end
