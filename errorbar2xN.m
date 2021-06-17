function h = errorbar2xN(mx,ex,facnames,legendnames)
% example
% mx = [8.4728    9.6651    6.7174    9.0960]
% ex = [2.9171    3.0136    2.7011    3.8238]
% facnames = {'Reward','Reward','Punishment','Punishment';'Happy','Angry','Happy','Angry'};
% figure;errorbar2x2(mx,ex,facnames);


% colmap = [.7 .2 .2;0 .45 .85];
colmap = [.5 .5 .5;.8 .8 .8];

% if ~isrow(mx), mx = mx'; end
% if ~isrow(mx), error('mx should be a vector'); end

[m,N] = size(mx);
if(m~=2), error('Number of rows must be 2'); end

el    = mx-ex;
eh    = mx+ex;

if size(ex,2)~=size(mx,2), ex=ex'; end
if size(ex,2)~=size(mx,2), error('ex is not matched with mx'); end

a = [.25 .35];
dx = .4;

% figure;
bar(a(1),0*mx(1),'FaceColor',colmap(1,:)); hold on;
bar(a(2),0*mx(2),'FaceColor',colmap(2,:));
xlim([0 sum(a)+(N-1)*dx]);
if ~isempty(legendnames)
    legend(legendnames); % ,'location','southoutside'
end

% c = length(mx);
for i=1:N
%     f1 = factors(2,i);
    for j=1:2
        ax = a(j)+dx*(i-1);
        bar(ax,mx(j,i),.09,'FaceColor',colmap(j,:),'EdgeColor','k');
        hold on;        
        plot([ax;ax],[el(j,i);eh(j,i)],'-','color','k','linewidth',1);
    end
end

a0 = mean(a(1:2))+ (0:1:(N-1))*dx;
set(gca,'xtick',a0);
set(gca,'xticklabel',facnames);

% set y-axis
yrng = get(gca,'ytick');
ystp = diff(yrng); ystp = ystp(1);
ymax = yrng(end)+.95*ystp;
ymin = yrng(2)-0.95*ystp;
set(gca,'ylim',[ymin;ymax]);

% set axes propertis
set(gca,'box','off');
set(gca,'ticklength', [0 0]);

% return axes handle
h = gca;

end