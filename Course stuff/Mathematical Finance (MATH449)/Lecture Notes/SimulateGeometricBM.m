function [t,S] = SimulateGeometricBM( S0, nu, sigma, dT )
% try: >> SimulateGeometricBM(100, .1, .2, 1/1000);

t = 0:dT:1;
N = length(t)-1;
S = [S0, zeros(1,N)];

p = 1/2 + 1/2*(nu/sigma)*sqrt(dT);

method = 'binomial';

for i=1:N
    if strcmp(method,'binomial')
        if rand(1)<p
            S(i+1)=S(i)*exp(sigma*sqrt(dT));
        else
            S(i+1)=S(i)*exp(-sigma*sqrt(dT));
        end
    elseif strcmp(method,'exact')
        % if we define S(0),S(1),... this way, then each log(S(i)/S(0))
        % is exactly normal with mean nu*t and variance sigma^2*t, t=i*dT
        S(i+1) = S(i)*exp(randn(1)*sigma*sqrt(dT)+nu*dT);
    end
end
plot(t,S), hold on

% hold on, plot(t, S0*exp((nu+sigma^2/2)*t), 'r'),