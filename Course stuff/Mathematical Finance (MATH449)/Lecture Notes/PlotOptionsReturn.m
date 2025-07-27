function R = PlotOptionsReturn( S, K, CallorPut, NumContracts, Premium )
% Plot the return of an option at expiration versus the stock price
% Note: by setting Premium=0 the function plots the value the option at
%       expiration
if strcmp(CallorPut, 'Call')
    R=(max(S-K,0)-Premium)*NumContracts;
elseif strcmp(CallorPut, 'Put')
    R=(max(K-S,0)-Premium)*NumContracts;
end
plot(S,R,'r--'), axis equal
grid