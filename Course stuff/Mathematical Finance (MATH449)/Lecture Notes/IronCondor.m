% The return of a March 19 RUT iron condor (RUT index ~1200 on Feb 9, 2015)
S = linspace(1050,1320,10001);
R1 = PlotOptionsReturn(S, 1090, 'Put', +1, 6.93); hold on
R2 = PlotOptionsReturn(S, 1100, 'Put', -1, 7.91); hold on
R3 = PlotOptionsReturn(S, 1270, 'Call', -1, 4.84); hold on
R4 = PlotOptionsReturn(S, 1280, 'Call', 1, 3.37); hold on
plot(S, R1+R2+R3+R4), axis normal, axis tight

maxloss = min(R1+R2+R3+R4)
maxprofit = max(R1+R2+R3+R4)

% figure, plot(S, R2+R3, 'r') % short a strangle
% hold on, plot(S, R1+R4, 'g') % long a strange