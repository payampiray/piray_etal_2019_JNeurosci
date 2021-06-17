function fig2
addpath('gramm-master');

yg = ba_raw;

qnames = {'HR','AR','HP','AP'};
glabel = {'no-go','go'};
Q = 4;

cmap = [0.1059    0.6196    0.4667;.6 .5 .2; ];    
pos0 = [0.2286    0.2491    0.45    0.65];
for q=1:4
    [i,j]=ind2sub([2 2],q);
    N = size(yg{1},1);
    y = cell2mat(yg(:,q));
    y = mat2cell(y,ones(size(y,1),1),size(y,2));
    x = 1:size(y{1},2);
    c = [repmat(glabel(1),N,1);repmat(glabel(2),N,1)]';    
    
    gr(i,j) = gramm('x',x,'y',y,'color',c);
    gr(i,j).stat_summary('type','sem');    
    gr(i,j).set_names('x','Trial after reversal','y','Performance','color','');
    gr(i,j).set_color_options('chroma',70,'lightness',40);
    gr(i,j).set_title(qnames{q});
    gr(i,j).set_text_options('font','Calibri','base_size',14,'title_scaling',1.25); 
    gr(i,j).set_color_options('map',cmap);
    gr(i,j).axe_property('xlim',[0 10],'ylim',[.3 .9],'xtick',0:10);
end
figure;
gr.draw();

set(gcf,'units','normalized');
set(gcf,'position',pos0);
set(gcf,'units','normalized');

end
