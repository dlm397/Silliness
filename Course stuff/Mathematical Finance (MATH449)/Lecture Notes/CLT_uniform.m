% Central limiting effect
% This script aims to demonstrate the important Central Limit Theorem

% Recall that the average of n i.i.d. *normal* r.v.'s
% is, again, a normal r.v., with the same mean, but the standard deviation
% is the original standard deviation divided by sqrt(n).

% What if I take the average of n i.i.d. *uniform* r.v.'s ?
% 
% Hmmm.... the average of n normal r.v.'s is normal, is the average of
% n uniform r.v.'s again a r.v. with a uniform distribution ?
%
% NO! See the demo below:

% Warmup: n=1 (there is nothing to average :)
% Generate N=10000 uniform [0,1] r.v.'s, use a histogram technique to
% estimate the pdf (well, we know the pdf already in this case, that's why 
% I said it's just a warmup)
N = 100000;
data = rand(1,N);
NumBins = 100;
[Counts,BinCenters] = hist(data,NumBins);
BinSize = BinCenters(2)-BinCenters(1);
subplot(3,3,1);
Probability_Denisty = (Counts/N)/BinSize; % probability density = probability / binSize
bar(BinCenters, Probability_Denisty)
title('n=1')

pause;

t = linspace(-0.2, 1.2, 1001); % for plotting pdf later on

% average n=2,3,4,...,9 uniform r.v.
for n=2:9; 
    data = sum(rand(n,N))/n;
    subplot(3,3,n)
    [Counts,BinCenters] = hist(data,NumBins);
    BinSize = BinCenters(2)-BinCenters(1);
    Probability_Denisty = (Counts/N)/BinSize; % probability density = probability / binSize
    bar(BinCenters, Probability_Denisty)
    % overlay the pdf of N(1/2, s/sqrt(n)), where s = std. of the
    % uniform-[0,1] variable (what is it ?)
    % variance of uniform-[0,1] = integrate[(t-1/2)^2 x 1, t=0,...,1]=1/12
    mean = 1/2; 
    std = sqrt(1/12)/ sqrt(n);

    hold on
    plot(t, 1/(sqrt(2*pi)*std) * exp( -(t-mean).^2 / (2*std^2) ), 'r', 'LineWidth', 2 );
    axis([-.2,1.2,0,4])
    pause
end