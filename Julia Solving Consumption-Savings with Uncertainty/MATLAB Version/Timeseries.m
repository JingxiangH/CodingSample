startT = 1000;
totalT = 100;

figure,
subplot(3,1,1);
plot(startT:startT+totalT-1, Sim.Y(startT:startT+totalT-1));
title('Y');

subplot(3,1,2);
plot(startT:startT+totalT-1, Sim.C(startT:startT+totalT-1));
title('C');

subplot(3,1,3);
plot(startT:startT+totalT-1, Sim.A(startT:startT+totalT-1));
title('A');

saveas(gcf, 'timeseries.png')