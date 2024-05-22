function Ve  = BellmanE(Par, Ap, Grid)

C = Grid.YY + Grid.AA - Ap/(1+Par.r);
u = C.^(1-Par.gamma) / (1-Par.gamma);

Ap1 = reshape(Ap,Grid.nA,Grid.nY);

EVe = reshape(Grid.EVe,Grid.nA,Grid.nY);
EVe = interp2(Grid.MY,Grid.MA,EVe,Grid.MY,Ap1,'spline');

EVu = reshape(Grid.EVu,Grid.nA,Grid.nY);
EVu = interp2(Grid.MY,Grid.MA,EVu,Grid.MY,Ap1,'spline');

EVe = EVe(:);
EVu = EVu(:);

Ve = u + Par.beta * (Par.p * EVu + (1-Par.p)* EVe);

end