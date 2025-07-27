% The payoff of a bear call spread on BABA (trading at $84.50 on March 6, 2015)
% Expiry date: March 27, 2015. Note: the Alibaba 6 month post-IPO lockup
% period expires on March 18, 2015 (Alibaba IPO date: 9/19/14)
S = linspace(75,90,10001);
R1 = PlotOptionsReturn(S, 88, 'Call', +1, 1.28); hold on
R2 = PlotOptionsReturn(S, 80, 'Call', -1, 5.42); hold on
plot(S, R1+R2), axis equal
% axis([75,95,-7,7])
maxloss = min(R1+R2) % the difference of the two strikes (-$8) + initial creit 
maxprofit = max(R1+R2) % $4.14 = the intial credit 