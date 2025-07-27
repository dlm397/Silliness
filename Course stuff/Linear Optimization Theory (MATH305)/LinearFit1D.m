% Linear fit with least square and least absolute error

slope=3; intercept=-2;
abscissa = (-5:5)'; m = length(abscissa);

WhiteNoise = 2*randn(m,1);
ordinates = slope*abscissa + intercept + WhiteNoise;

% outliers
GrossError=80;
ordinates(6)=ordinates(6)+GrossError;
ordinates(10)=ordinates(10)-GrossError;

% visualize the data
plot(abscissa, ordinates, 'o', 'MarkerSize', 5, 'LineWidth', 5), hold on

%
% Linear fit with least absolute error, solved by setting up a linear
% program in a form taken by the linprog() solver.
% you should read the documentation of linprog(), 
% try: >> help linprog

e = ones(m,1);
f = [0;0;e];
A = [ [abscissa e -eye(m)]; [-abscissa -e -eye(m)] ];
b = [ordinates; -ordinates];
LB = [-inf; -inf; zeros(m,1)];
X = linprog(f,A,b,[],[],LB); 
% 
a=linspace(-8,8,1001);
l1=plot(a, a*X(1)+X(2), 'LineWidth', 2);

% Linear fit with least square error, solved by setting up a linear system:
Xls = [abscissa, e]\ordinates; 
l2=plot(a, a*Xls(1)+Xls(2), 'r-.', 'LineWidth', 2);

% The "ground truth"
l3=plot(a, a*slope+intercept, 'k', 'LineWidth', 2);

legend([l1,l2,l3],'Least Absolute','Least Square','Ground Truth')
title('Linear Fitting of data contaminated by outliners')