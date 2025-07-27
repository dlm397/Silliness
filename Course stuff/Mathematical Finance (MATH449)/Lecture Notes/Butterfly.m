% The return of a AAPL March 6 butterfly entered on Feb 27, 2015 (Apple trading at $128)
S = linspace(100,150,10001);
R1 = PlotOptionsReturn(S, 123, 'Call', +1, 5.85); hold on
R2 = PlotOptionsReturn(S, 128, 'Call', -2, 2.15); hold on
R3 = PlotOptionsReturn(S, 133, 'Call', 1, .41); hold on
plot(S, R1+R2+R3), axis equal
axis([115.4811  140.2125  -11.0214 8.4845])

% used to speculate that the stock does not move much at expiration
% the premium is pretty high in this case though: max loss = -$1.96, max
% profit = $3.04

maxloss = min(R1+R2+R3)
maxprofit = max(R1+R2+R3)