Grid.Ce = Grid.YY + Grid.AA - Ape / (1 + Par.r);
Grid.Cu = Par.b + Grid.AA - Apu / (1 + Par.r);
Grid.MCe = reshape(Grid.Ce,Grid.nA,Grid.nY);
Grid.MCu = reshape(Grid.Cu,Grid.nA,Grid.nY);

figure;

N1 = size(YY, numStdY);

labels = cell(1,N1+1);

for i = 1:N1
    plot(Grid.MA(:,i), Grid.MCe(:,i), 'LineWidth', 2.5,'LineStyle','--');
    hold on;
    labels{i} = ['Employed Line' num2str(i)];
end

plot(Grid.MA(:,1), Grid.MCu(:,4), 'LineWidth', 2.5, 'Color','Red'); %
labels{end} = 'Unemployed';
hold off;

xlabel('Assets');
ylabel('Consumption');
legend(labels,'Location','northwest');

saveas(gcf, 'consumption.png')