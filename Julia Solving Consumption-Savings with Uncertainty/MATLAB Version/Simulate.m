function Sim = Simulate(Par,T,Grid)

Sim.A = zeros(T,1);
Sim.Y = zeros(T,1);
Sim.logY = zeros(T,1);
Sim.C = zeros(T,1);
Sim.State = zeros(T,1);
Sim.A(1) = 0.5 * Grid.upperA;
Sim.State(1) = 1;

Sim.logY(1) = 0;

rng('default');

Eps = normrnd(0,Par.sigma,[T,1]);


Grid.MApe = reshape(Grid.Ape,Grid.nA,Grid.nY);
Grid.MApu = reshape(Grid.Apu,Grid.nA,Grid.nY);



for t = 2:T
    randNUM = rand();
    if Sim.State(t-1) == 1
        % State 1 is employed, state 0 is unemployed.
        if randNUM < Par.p
            Sim.State(t) = 0;
        else
            Sim.State(t) = 1;
        end
    else
        if randNUM < Par.q
            Sim.State(t) = 1;
        else
            Sim.State(t) = 0;
        end
    end

end


for t = 2:T
    if Sim.State(t) == 1
    Sim.logY(t) = Par.rho * Sim.logY(t-1) + Eps(t);
    Sim.Y(t) = exp(Sim.logY(t));
    Amax = min((1+Par.r).*(Sim.Y(t)+Sim.A(t-1)) - (1e-6), 100);
    Sim.A(t) = max(min(interp2(Grid.MY,Grid.MA,Grid.MApe,Sim.Y(t),Sim.A(t-1),'spline'), Amax),0);
    Sim.C(t) = Sim.Y(t) + Sim.A(t-1) - (Sim.A(t)/(1+Par.r));

    else
       
    Sim.Y(t) = Par.b;
    Amax = min((1+Par.r).*(Sim.Y(t)+Sim.A(t-1)) - (1e-6), 100);
    Sim.A(t) = max(min(interp2(Grid.MY,Grid.MA,Grid.MApu,Sim.Y(t),Sim.A(t-1),'spline'), Amax),0);
    Sim.C(t) = Sim.Y(t) + Sim.A(t-1) - (Sim.A(t)/(1+Par.r));

    end

end

% Compute quantities from state variables
Ti = 2:T-1;
Sim.State = Sim.State(Ti);
Sim.A = Sim.A(Ti);
Sim.Y = Sim.Y(Ti);
Sim.C = Sim.C(Ti);

end