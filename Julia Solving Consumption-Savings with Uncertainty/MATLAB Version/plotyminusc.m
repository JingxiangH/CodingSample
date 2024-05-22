Grid.YmCe = YY - Grid.MCe;
Grid.YmCu= Par.b - Grid.MCu;
figure;

labels = cell(1,N1+1);

for i = 1:N1
    plot(Grid.MA(:,i), Grid.YmCe(:,i), 'LineWidth', 2.5,'LineStyle','--');
    hold on;
    labels{i} = ['Employed Line' num2str(i)];
end


plot(Grid.MA(:,1), Grid.YmCu(:,1), 'LineWidth', 2.5, 'Color','Red'); 
labels{end} = 'Unemployed';
hold off;

xlabel('Assets');
ylabel('Y-C');
legend(labels,'Location','northeast');

saveas(gcf, 'yminusc.png')