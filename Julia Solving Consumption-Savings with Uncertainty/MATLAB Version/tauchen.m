function [Y,Yprob] = tauchen(N,mu,rho,sigma,m)

logY   = zeros(N,1);
Yprob = zeros(N,N);
a     = (1-rho)*log(mu);

logY(N)  = m * sqrt(sigma^2 / (1 - rho^2));
logY(1)  = -logY(N);
Ystep = (logY(N) - logY(1)) / (N - 1);

for i=2:(N-1)
    logY(i) = logY(1) + Ystep * (i - 1);
end 

logY = logY + a / (1-rho);

for j = 1:N
    for k = 1:N
        if k == 1
            Yprob(j,k) = normcdf((logY(1) - a - rho * logY(j) + Ystep / 2) / sigma);
        elseif k == N
            Yprob(j,k) = 1 - normcdf((logY(N) - a - rho * logY(j) - Ystep / 2) / sigma);
        else
            Yprob(j,k) = normcdf((logY(k) - a - rho * logY(j) + Ystep / 2) / sigma) - ...
                         normcdf((logY(k) - a - rho * logY(j) - Ystep / 2) / sigma);
        end
    end
end

Y = exp(logY);
