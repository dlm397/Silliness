% Plot of BS prices of calls and puts vs time to expiration,
% assuming that the underlying price does not move in time.

r=0.01; % interest rate
q=0.0; % dividend rate
S=62; % asset price
K=60; % strike price
T=5/12; % expiration date
t=linspace(0,T,10001);

figure(1)
sigma=0.2; % volatility
[C,P]=BlackScholes(S,K,r,q,sigma,T-t);
plot(t,C), grid, hold on, plot(t,P,'--')
title('Time Decay of options (assuming stock price doesn''t change)')
xlabel('time')
ylabel('price of Call/Put')
%
sigma = 0.3;
[C,P]=BlackScholes(S,K,r,q,sigma,T-t);
hold on, plot(t,C, 'r'), plot(t,P,'r--')

figure(2)
Ss = linspace(40,80,1001);
R = PlotOptionsReturn( Ss, K, 'Call', 1, 0 );
plot(Ss,R)
hold on,

for i=1:4,
    Cs = BlackScholes(Ss,K,r,q,sigma,T-(i/12));
    plot(Ss,Cs,'--');
end
xlabel('Asset price')
ylabel('Price of Call')
title('Price of 5-month call versus asset price at the i-th month, i=1,2,3,4')