T = 10000;
Sim = Simulate(Par,T,Grid);

figure,
subplot(2,2,1);
histogram(Sim.Y);
title('Y');

subplot(2,2,2);
histogram(Sim.C);
title('C');

subplot(2,2,3);
histogram(Sim.A);
title('A');

subplot(2,2,4);
histogram(Sim.State);
title('State');

saveas(gcf, 'simulate.png')

disp('Mean Values:');
disp(['Mean Y: ' num2str(mean(Sim.Y))]);
disp(['Mean C: ' num2str(mean(Sim.C))]);
disp(['Mean A: ' num2str(mean(Sim.A))]);
disp('Standard Deviations:');
disp(['Standard Deviations Y: ' num2str(std(Sim.Y))]);
disp(['Standard Deviations C: ' num2str(std(Sim.C))]);
disp(['Standard Deviations A: ' num2str(std(Sim.A))]);