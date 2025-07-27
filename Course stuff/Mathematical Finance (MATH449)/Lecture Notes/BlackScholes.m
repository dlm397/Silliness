function [C, P, Delta_C, Delta_P]=BlackScholes(S,K,r,q,sigma,Time2Expiration)
% Black-Scholes formula
d1 = (log(S/K) + (r-q+sigma^2/2)*Time2Expiration) ./ (sigma*sqrt(Time2Expiration));
d2 = d1 - sigma*sqrt(Time2Expiration);
C = S.*normcdf(d1).*exp(-q*Time2Expiration) - K*normcdf(d2).*exp(-r*Time2Expiration);

% Put-call parity: C-P+K*exp(-r*Time2Expiration) = S*exp(-q*Time2Expiration)
P = C+K*exp(-r*Time2Expiration)-S.*exp(-q*Time2Expiration);

Delta_C = exp(-q*Time2Expiration) .* normcdf(d1);
Delta_P = -exp(-q*Time2Expiration) .* normcdf(-d1);