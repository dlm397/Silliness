% a five month call and a five month put

r=0.025; % annualized interest rate
q=0.000; % annualized dividend rate
S=62; % asset price
K=64; % strike price
T=5/12; % expiration date (in unit year)
t=0;
sigma=0.2; % annualized volatility

n=5; % number of times to divide up the time period [0,T]
dT = T/n; 

% the binprice() function in the financial toolbox uses the [u,d]
% factors determined by the following:
% u=exp(sigma*sqrt(dT)); d=1/u; R = exp(r*dT)
%
% we will explain what `sigma' means, why u, d are set in this way, and
% how the binomial lattice pricing method (discrete time, discrete asset prices)
% is connected to the Black-Scholes-Merton approach (based on
% continuous time & continuous asset prices).
%

[P,O] = binprice(S, K, r, T, dT, sigma, 1) % pricing an American call
[P,O] = binprice(S, K, r, T, dT, sigma, 0) % pricing an American put

%
% lets discretize the 5-month time finer and finer
% 
ns=1:500;
for n=ns, 
    dT = T/n;  
    [P,O] = binprice(S, K, r, T, dT, sigma, 1); 
    CallPrice(n)=O(1,1); 
    [P,O] = binprice(S, K, r, T, dT, sigma, 0); 
    PutPrice(n)=O(1,1); 
end
subplot(2,1,1), plot(ns, CallPrice(ns)), 
subplot(2,1,2), plot(ns, PutPrice(ns), 'r')

% [C,P] = blsprice(S,K,r,T,sigma); % using blsprice() from the financial toolbox
% or:
[C,P]=BlackScholes(S,K,r,q,sigma,T) % using BlackScholes() implemented by me
% The Black-Scholes price C is very close to the American call price 
% determined by the binomial lattice method with a large n, whereas the 
% Black-Scholes price P is not as close as the corresponding American 
% put price. Do you know why?