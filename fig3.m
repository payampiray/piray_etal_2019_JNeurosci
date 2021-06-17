function fig3
addpath('gramm-master');

close all;

modelname = 'model_m4';

fname   = fullfile('data','cm1',sprintf('%s.mat',modelname));
cbm     = load(fname); cbm = cbm.cbm;
fx      = cbm.output.parameters;
tx      = ba_fx(modelname,fx,0);
g       = getdefaults('LSAS');

glabel = cell(size(g));
glabel(g==0) = {'Low SA'};
glabel(g==1) = {'High SA'};

cmap = [0.7384    0.0515    0.1973;
        0.1    0.4    0.8];
fpos0 = [.3 .4 .4  0.8];

xsA  = -.15;
ysA  = 1.1;
fsA  = 24;
xsC  = -.3;

gr(1,1) = gramm('x',glabel,'y',tx(:,4));
gr(1,1).set_order_options('x',0);
% % gr(1,1).stat_summary('type','sem','geom',{'bar','black_errorbar'},'width',.1);
gr(1,1).stat_violin('fill','transparent','width',1,'dodge',0);
gr(1,1).stat_boxplot('width',0.2);
gr(1,1).set_color_options('chroma',70,'lightness',40);
gr(1,1).set_title(sprintf('Weight parameter\non angry trials'));
gr(1,1).set_names('x','','y','\it w','color','');
gr(1,1).set_text_options('font','Arial','base_size',14,'title_scaling',1.25,'interpreter','tex');

gr(1,2) = gramm('x',glabel,'y',tx(:,3));
gr(1,2).set_order_options('x',0);
% % gr(1,2).stat_summary('type','quartile','geom',{'bar','black_errorbar'},'width',.1);
gr(1,2).stat_violin('fill','transparent','width',1,'dodge',0);
gr(1,2).stat_boxplot('width',0.2);
gr(1,2).set_color_options('map',cmap(2,:));
gr(1,2).set_title(sprintf('Weight parameter\non happy trials'));
gr(1,2).set_names('x','','y','\it w','color','');
gr(1,2).set_text_options('font','Arial','base_size',14,'title_scaling',1.25,'interpreter','tex');


[xang, xhap] = ba_modelfree;
gr(2,1) = gramm('x',glabel,'y',xang);
gr(2,1).set_order_options('x',0);
gr(2,1).stat_violin('fill','transparent','width',1,'dodge',0);
gr(2,1).stat_boxplot('width',0.2);
gr(2,1).set_color_options('chroma',70,'lightness',40);
gr(2,1).set_title(sprintf('Relative performance\non angry trials'));
gr(2,1).set_names('x','','y','Performance (stable - volatile)','color','');
gr(2,1).set_text_options('font','Arial','base_size',14,'title_scaling',1.25,'interpreter','tex');
gr(2,1).axe_property('YLim',[-.18 .28]);
gr(2,1).axe_property('Ytick',-.1:.1:.2);

gr(2,2) = gramm('x',glabel,'y',xhap);
gr(2,2).set_order_options('x',0);
gr(2,2).stat_violin('fill','transparent','width',1,'dodge',0);
gr(2,2).stat_boxplot('width',0.2);
gr(2,2).set_color_options('map',cmap(2,:),'chroma',70,'lightness',40);
gr(2,2).set_title(sprintf('Relative performance\non happy trials'));
gr(2,2).set_names('x','','y','Performance (stable - volatile)','color','');
gr(2,2).set_text_options('font','Arial','base_size',14,'title_scaling',1.25,'interpreter','tex');
gr(2,2).axe_property('Ytick',-.1:.1:.2);
gr(2,2).axe_property('YLim',[-.18 .28]);


figure;
gr.draw();

set(gcf,'units','normalized');
set(gcf,'position',fpos0);

text(xsA,ysA,'A','fontsize',fsA,'Unit','normalized','fontname','Arial','parent',gr(1,1).facet_axes_handles(1));
text(xsA,ysA,'B','fontsize',fsA,'Unit','normalized','fontname','Arial','parent',gr(1,2).facet_axes_handles(1));
text(xsC,ysA,'C','fontsize',fsA,'Unit','normalized','fontname','Arial','parent',gr(2,1).facet_axes_handles(1));
text(xsC,ysA,'D','fontsize',fsA,'Unit','normalized','fontname','Arial','parent',gr(2,2).facet_axes_handles(1));
end