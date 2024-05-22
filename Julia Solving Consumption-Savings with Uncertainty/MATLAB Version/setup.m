%% set up Parameters;
Par.gamma = 2;
Par.beta = 0.98;
Par.mu = 1;
Par.b = 0.4;
Par.rho = 0.9;
Par.sigma = sqrt(0.05);
Par.p = 0.05;
Par.q = 0.25;
Par.r = 0.01;

%% Create a grid for A
Grid.nA = 1000;
Grid.upperA = 300;
Grid.A = linspace(0,Grid.upperA,Grid.nA)';  % this is a 100 x 1 array

%% Create a grid for Y
meanY = 1;
Grid.nY = 7;
numStdY = 2;
[Grid.Y, Grid.PY]  = tauchen(Grid.nY, meanY, Par.rho, Par.sigma, numStdY);  
    
Grid.PY = Grid.PY'; % this is a 7 x 7 transition matrix for which the columns sum to 1
% the (i,j) element is the probability of moving from j to i.

%% Create a product of the two grids
[YY,AA] =meshgrid(Grid.Y,Grid.A);
Grid.AA = AA(:);
Grid.YY = YY(:);
Grid.MA = AA;
Grid.MY = YY;
