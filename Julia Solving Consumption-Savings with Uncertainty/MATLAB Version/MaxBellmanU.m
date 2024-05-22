function [V, Ap] = MaxBellmanU(Par,Grid)

% Take Y as given and optimization through A

p = (sqrt(5)-1)/2;

A = 0 * ones(size(Grid.AA));
D = min((1+Par.r).*(Par.b+Grid.AA) - (1e-6), Grid.upperA);
B = p*A+(1-p)*D;
C = (1-p)*A + p * D;

fB = BellmanU(Par,B,Grid);
fC = BellmanU(Par,C,Grid);

MAXIT = 1000;
for it_inner = 1:MAXIT

    if all(D-A < 1e-6)
        break
    end

    I = fB > fC;
   
    D(I) = C(I);
    C(I) = B(I);
    fC(I) = fB(I);
    B(I) = p*C(I) + (1-p)*A(I);
    fB_temp = BellmanU(Par,B,Grid);
    fB(I) = fB_temp(I);

    A(~I) = B(~I);
    B(~I) = C(~I);
    fB(~I) = fC(~I);
    C(~I) = p*B(~I) + (1-p)*D(~I);
    fC_temp = BellmanU(Par,C,Grid);
    fC(~I) = fC_temp(~I);
end

% At this stage, A, B, C, and D are all within a small epsilon of one another. 
% We will use the average of B and C as the optimal level of savings.
Ap = (B+C)/2;

V = BellmanU(Par,Ap,Grid);

end