%% Initial guess of value function -> all zeros

EVe0 = zeros(size(Grid.AA));
EVu0 = zeros(size(Grid.AA));

%% Bellman iteration

MAXIT = 2000;

for it = 1:MAXIT

    Grid.EVe = EVe0;
    Grid.EVu = EVu0;

    [Ve, Ape] = MaxBellmanE(Par,Grid);
    [Vu, Apu] = MaxBellmanU(Par,Grid);

    % take the expectation of the value function from the perspective of the previous Z
    EVe = reshape(Ve,Grid.nA,Grid.nY) * Grid.PY; 
    EVu = reshape(Vu,Grid.nA,Grid.nY) * Grid.PY; 
    
    EVe = EVe(:);
    EVu = EVu(:);

    Grid.Ape = Ape;
    Grid.Apu = Apu;

    % see how much our policy rule has changed
    test1 = max(abs(EVe - EVe0));
    test2 = max(abs(EVu - EVu0));
    test = max(test1,test2);

    EVe0 = EVe;
    EVu0 = EVu;

    disp(['iteration ' num2str(it) ', test1 = ' num2str(test1) ', test2 = ' num2str(test2)])
    if test < 1e-6
        break
    end
end