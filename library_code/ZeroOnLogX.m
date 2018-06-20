% zero: position on log scale to place the zero value (i.e min_non_zero/10)
% start: position of smallest non zero data point
function h=ZeroOnLogX(zero,start)

% Create by Jacob Beal in 2014
% based on BreakXAxis by Julie Haas (BSD license, copyright 2004), after Michael Robbins
% Assumes an already existing plot and axes, just waiting for relabeling and marking

yrange = ylim;

% remap tick marks, and 'erase' them in the gap
xrange = xlim;

% Can't control minor range, so turn off and replace
set(gca,'XMinorTick','off')

% Calculate log10 values from start, zero, and maximum x-value
mintick = floor(log10(start));
maxtick = floor(log10(xrange(2)));
zerotick = floor(log10(zero));

% Uncomment to further separate '0' value from mintick
% if zerotick >= mintick
%     zerotick = mintick - 1;
% end

% Create array of xticks
xtick = zeros((maxtick-zerotick+1)*9,1);

for i=zerotick:maxtick
    xtick((i-zerotick)*9+(1:9)) = (1:9)*10^i;
end

% Create array of labels from xticks
labels = cell(numel(xtick),1);

% Go through xticks and label accordingly
offset = 0.02;
for i=1:numel(xtick)
    if log10(xtick(i))==floor(log10(xtick(i)))
        if log10(xtick(i)) == zerotick
            labels{i} ='0';
        
        else
            label = sprintf('10^%i',log10(xtick(i)));
            labels{i} = label;
        end
    else
        labels{i} = '';
    end
end

% Label the axis break
t1=text((xtick(1)+start)/2,yrange(1),'//','fontsize',15);
% For y-axis breaks, use set(t1,'rotation',270);

% Make sure x-axis not cutoff and set xticks and labels
xlim([xtick(1) xtick(numel(xtick))]);
set(gca,'XTick',xtick);
set(gca,'XTickLabel',labels);


