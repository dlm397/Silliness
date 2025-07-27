% Central limiting effect
% This script aims to demonstrate the Central Limit Theorem when the
% underlying distribution is Bernoulli(p)
%
% Note: Bernoulli is the most discrete distribution

p = 0.3;

N = 100000;

for n=1:81,
    subplot(9,9,n);
    
    Xbar_Bernoulli = binornd(n,p, [1,N])/n;
    
    BinCenters = (0:n)/n;
    [Counts] = hist(Xbar_Bernoulli,BinCenters);
    BinSize = 1/n;
    Probability_Denisty = (Counts/N)/BinSize; % probability density = probability / binSize
    bar(BinCenters, Probability_Denisty)
    
    % overlay the pdf of N(p, s/sqrt(n)), where s = std. of the
    % Bernoulli(p) variable (what is it ?)
    mean = p;
    std = sqrt(p*(1-p))/ sqrt(n);
    
    hold on
    t = linspace(0,1, 1001); % for plotting pdf
    plot(t, 1/(sqrt(2*pi)*std) * exp( -(t-mean).^2 / (2*std^2) ), 'r', 'LineWidth', 2 );
    axis([0,1,0,10]), drawnow
end