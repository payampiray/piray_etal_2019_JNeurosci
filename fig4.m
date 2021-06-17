function fig4
close all;
platedir  = fullfile(getdefaults('pipedir'),'cm1','VOI','01-OUTCxLR4xF@[8 26 42]r0');
Yb = load_VOI(platedir);
platedir  = fullfile(getdefaults('pipedir'),'cm1','VOI','01-OUTCxLR4xF@[-8 24 40]r0');
Y = load_VOI(platedir);
[g] = getdefaults('LSAS');

% encodes more angry
yb   = Yb*[0 1 0 1;1 0 1 0;]';
y    = Y*[0 1 0 1]';


glabel = cell(size(g));
glabel(g==0) = {'Low SA'};
glabel(g==1) = {'High SA'};

N  = size(yb,1);
yy = [yb(:,1); yb(:,2)];
cc = [2*ones(N,1); 3*ones(N,1)];

clabel = cell(size(g));
clabel(cc==2) = {'Angry'};
clabel(cc~=2) = {'Happy'};

cmap = [0.7384    0.0515    0.1973;
        0.1    0.4    0.8];
fpos0 = [.1 .4 .6  0.5];

xsA  = -.1;
ysA  = 1.1;
fsA  = 24;

gr(1,2) = gramm('x',clabel,'y',yy,'color',cc);
gr(1,2).set_order_options('x',0);
gr(1,2).stat_summary('type','sem','geom',{'bar','black_errorbar'},'width',.8);
gr(1,2).stat_violin('fill','transparent','width',.75,'dodge',0);
gr(1,2).set_title(sprintf('LR-related activity in 1\nthe dACC'));
gr(1,2).set_names('x','','y','effect size (a.u.)','color','');
gr(1,2).set_text_options('font','Calibri','base_size',14,'title_scaling',1.25);
gr(1,2).axe_property('YLim',[-45 85]);
gr(1,2).axe_property('Yticklabel',[]);
gr(1,2).axe_property('Ygrid','on');
gr(1,2).set_color_options('map',cmap,'chroma',70,'lightness',40,'legend','none');

gr(1,3) = gramm('x',glabel,'y',y);
gr(1,3).set_order_options('x',0);
gr(1,3).stat_summary('type','sem','geom',{'bar','black_errorbar'},'width',.4);
gr(1,3).stat_violin('fill','transparent','width',1,'dodge',0);
gr(1,3).set_title(sprintf('LR-related activity in \nthe dACC on angry trials a'));
gr(1,3).set_names('x','','y','effect size (a.u.)','color','');
gr(1,3).set_text_options('font','Calibri','base_size',14,'title_scaling',1.25);
gr(1,3).axe_property('YLim',[-45 85]);
gr(1,3).axe_property('Ygrid','on');
gr(1,3).axe_property('Yticklabel',[]);
gr(1,3).set_color_options('chroma',70,'lightness',40);


figure;
gr.draw();

set(gcf,'units','normalized');
set(gcf,'position',fpos0);

% text(xsA-.45,ysA,'A','fontsize',fsA,'Unit','normalized','fontname','Calibri','parent',gr(1,1).facet_axes_handles(1));
text(xsA,ysA,'B','fontsize',fsA,'Unit','normalized','fontname','Arial','parent',gr(1,2).facet_axes_handles(1));
text(xsA,ysA,'C','fontsize',fsA,'Unit','normalized','fontname','Arial','parent',gr(1,3).facet_axes_handles(1));

end

function y = load_VOI(platedir)
fname     = fullfile(platedir,'VOI_VOI.mat');
Y = load(fname,'Y'); Y=Y.Y;

Q = getdefaults('Q');
N = getdefaults('N');
if length(Y)==(N*Q)
    y = nan(N,Q);
    for q=1:Q
        ii = (q-1)*N+(1:N);
        y(:,q) = Y(ii);
    end
elseif length(Y)==N
    y = Y;
end

end