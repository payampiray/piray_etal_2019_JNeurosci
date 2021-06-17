function fig1

data  = getdefaults('getxseqdata');

fs = 16;
W  = 25;
H  = 12;
colmap = [0.9290 0.6940 0.1250; 0.8500 0.3250 0.0980; 0 0.4470 0.7410];

pseq    = data{1}.q2x2data.pseq;
go      = data{1}.q2x2data.go;  
U       = data{1}.q2x2data.win;  
U(go==0)= 1-U(go==0);
pseq    = pseq(:,4)/100;
U       = U(:,4);

hf = figure;
set(hf,'unit','centimeters');
pos = get(hf,'position');
pos([1 2]) = 2;
pos([3 4]) = [W H];
set(hf,'position',pos);

plot(pseq,'k','linewidth',2);
set(gca,'fontname','MyriadPro-Regular','fontsize',12);
% set(gca,'xgrid','on');
ylabel('P(Win|Go)','fontsize',fs,'FontWeight','b');
xlabel('Trial','fontsize',fs,'FontWeight','b');
hold on;
ylim([-.09 1.09]);
set(gca,'ytick',[0 .3 .6 .9]);
set(gca,'xtick',20:20:120);
set(gcf,'colormap',colmap)

hold on;
set(gca,'ticklength', [0 0]);
% set(gca,'fontsize',fs);
set(gca,'box','off');

plot(U,'.','col','k');
end