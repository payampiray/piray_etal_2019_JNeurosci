function hb = errorbar1xN(mx,ex,labels,asterisk)
if nargin<4, asterisk = []; end
% colmap = .75*[0 .6 1];
colmap = .5*[1 1 1];
% colmap(1,:) = [.4 .2 .2];
% colmap(2,:) = [.8 .2 .2];

% N = length(mx);
barwidth = 0.75;

if ~isrow(mx), mx = mx'; end
if ~isrow(mx), error('mx should be a vector'); end


if size(ex,2)~=size(mx,2), ex=ex'; end
if size(ex,2)~=size(mx,2), error('ex is not matched with mx'); end

if size(ex,1)==1
    e    = [mx-ex; mx+ex];    
elseif size(ex,1)>1
    e = [mx-ex(1,:); mx+ex(2,:)];
end


hb = bar(mx',barwidth,'FaceColor',colmap,'EdgeColor','k');
set(gca,'xticklabel',labels,'xcolor','k');


hold on;
a = get(gca,'xtick');
for i=1:length(mx)    
    plot([a(i);a(i)],e(:,i),'-','color','k','linewidth',1);
end
yrng = get(gca,'ytick');
ystp = diff(yrng); ystp = ystp(1);

sm = max(e(2,:))+0.5*ystp;
if ~isempty(asterisk)    
    for i=1:length(mx)    
        if asterisk(i)
            plot(a(i),sm,'*','color','k');
        end
    end    
end

ymax = yrng(end)+.95*ystp;
ymin = yrng(2)-0.95*ystp;
set(gca,'ylim',[ymin;ymax]);

set(gca,'box','off');
set(gca,'ticklength', [0 0]);
end