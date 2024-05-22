diffAA = AA;
diffAA(2:end, :) = AA(2:end, :) - AA(1:end-1, :);

diffCe = Grid.MCe;
diffCe(2:end, :) = Grid.MCe(2:end, :) - Grid.MCe(1:end-1, :);

MPCe = diffCe./diffAA;

diffCu = Grid.MCu;
diffCu(2:end, :) = Grid.MCu(2:end, :) - Grid.MCu(1:end-1, :);
MPCu = diffCu./diffAA;

figure;

labels = cell(1,N1+1);

for i = 1:size(YY, numStdY)
    plot(Grid.MA(:,i), MPCe(:,i), 'LineWidth', 2.5,'LineStyle','--');
    hold on;
    labels{i} = ['Employed Line' num2str(i)];
end

plot(Grid.MA(:,1), MPCu(:,1), 'LineWidth', 2.5, 'Color','Red'); 
labels{end} = 'Unemployed';
hold off;

xlabel('Assets');
ylabel('MPC');
legend(labels,'Location','northeast');

saveas(gcf, 'mpc.png')