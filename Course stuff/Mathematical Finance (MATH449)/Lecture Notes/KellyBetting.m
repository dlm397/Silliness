
R = 0.2; % bet (100R)% of the current capital in each game
p = 0.65;

N=10000;

for trial = 1:10
    Capital = 100;
    C = zeros(1,N);
    C(1)=Capital;
    
    for i=2:N,
        if rand(1)<p, % win
            Capital = Capital*(1+R);
        else % loss
            Capital = Capital*(1-R);
        end
        C(i) = Capital;
    end
    
    % subplot(3,3,trial); hold on
    semilogy(1:N, C,'g-.'), hold on
end