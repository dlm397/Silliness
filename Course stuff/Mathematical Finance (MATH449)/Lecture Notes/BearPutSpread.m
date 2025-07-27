% The payoff of a bear put spread on SPY (expiry date April 17, 2015) 
% (SPY trading at $207 on March 6, 2015)
S = linspace(200,215,10001);
R1 = PlotOptionsReturn(S, 212, 'Put', +1, 6.46); hold on
R2 = PlotOptionsReturn(S, 202, 'Put', -1, 2.34); hold on
plot(S, R1+R2), axis equal
axis([200,215,-7,7])
maxloss = min(R1+R2) % the initial debit
maxprofit = max(R1+R2) % the difference of the two strikes ($10) - initial debit

