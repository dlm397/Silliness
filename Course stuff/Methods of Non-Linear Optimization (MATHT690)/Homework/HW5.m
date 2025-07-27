g = 9.8; % (meter/sec^2), gravitational acceleration
v0 = 2; % (meter/sec) an experimetal physicist throws an object up with the 
        % speed 2 m/sec at the top of the tower with 
s0 = 56.7; % (meter), height of the Leaning Tower of Pisa

t = linspace(0, 3, 101)';
% We create the distance data assuming that the Newton's law is already
% known.
% In reality, the data is measured by experimentalists, typically using 
% sophisicated, yet imperfect, instrumentations.
% Scientists, in turn, exploit such hard-earned data to discover hidden 
% patterns (such as the F=ma law) in our universe.
d_clean = -1/2*g*t.^2 + v0*t + s0; 
plot(t, d_clean), hold on

sigma=1;
% "white noise" = i.i.d. zero mean normals with standard deviation sigma:
measurement_error = randn(size(t))*sigma; 
d_noisy = d_clean + measurement_error;
plot(t, d_noisy)

s=5;
impulsive_error = randn(size(t))./randn(size(t))/s; % i.i.d. Cauchy
d_impulsive = d_clean + impulsive_error;
plot(t, d_impulsive)

% use A=[t d_noisy] for part (2) and A = [t d_impulsive] for part (3).