function [xang, xhap] = ba_modelfree
data  = getdefaults('getxseqdata');
Q     = getdefaults('Q');
N     = getdefaults('N');

t0vol = 10; % 8,9,10,11,12
t0stab = t0vol;
for i=1:N
    % true prob sequence p(win|go)
    xseq    = data{i}.q2x2data.pseq;
    
    % go
    go      = data{i}.q2x2data.go;
    perf    = go;
    perf(xseq<50) = 1-go(xseq<50);
    perf(xseq==50) = nan;
        
    for q=1:Q
        p = xseq(:,q);
        f = perf(:,q);

        % when there is a change in sequence? If 10th element of dp is 1,
        % there is a change on 10th trial
        dp = [0;diff(p)];
        idp = find(dp~=0);
        
        % how many change? just to ensure that the number of changes is the same for all trial-types
        nidp(i,q) = length(idp); 
        
        % also add the first and last trial
        idp = [1; idp; length(p)];
        
        ttvols =  zeros(size(p));
        ttstabs = zeros(size(p));
        
        for j=1:(length(idp)-1)
            idpj  = idp(j);
            
            % volatile trials: those after change (up tp t0vol or the next change)
            ttend = min(idpj+t0vol , idp(j+1))-1;
            ttvol = idpj:ttend;
            ttvols(ttvol) = 1;
            
            % stable trials: those after change+t0stab until the next
            % change
            ttstab   = (idpj+t0stab):idp(j+1); 
            if ~isempty(ttstab), ttstab(end)=[]; end
            ttstabs(ttstab) = 1;
        end
          madpvol(i,q) = nanmean(f(ttvols==1));  
          madpstab(i,q) = nanmean(f(ttstabs==1));
    end
end

[g] = getdefaults('LSAS');

% only relative performance is interpretable as a learning effect
xvol = .5*madpvol*[0 1 0 1;1 0 1 0]';
xstab = .5*madpstab*[0 1 0 1;1 0 1 0]';
x  = xstab - xvol;

xang = x(:,1);
xhap = x(:,2);


mg(1,:) = mean(x(g==0,:));
mg(2,:) = mean(x(g==1,:));
eg(1,:) = serr(x(g==0,:));
eg(2,:) = serr(x(g==1,:));

return;

my = mg(:,1);
ey = eg(:,1);
figure; h = errorbar1xN(my,ey,{'Low SA','High SA'});
% ylim([.5 1.1*max(my)]);
set(gca,'fontsize',16,'fontname','MyriadPro-Regular');
ylabel('Performance (stable - volatile)');
title(sprintf('Relative performance\n in angry trials'));
h.FaceColor='flat';
h.CData(1,:) = [.6 .2 .2];
h.CData(2,:) = [.6 .2 .2];
ylim([0 .109]);
set(gca,'ytick',[0 0.05 0.1]);

my = mg(:,2);
ey = eg(:,2);
figure; h = errorbar1xN(my,ey,{'Low SA','High SA'});
% ylim([.5 1.1*max(my)]);
set(gca,'fontsize',16,'fontname','MyriadPro-Regular');
ylabel('Performance (stable - volatile)');
title(sprintf('Relative performance\n in happy trials'));
h.FaceColor='flat';
h.CData(1,:) = [.2 .6 .2];
h.CData(2,:) = [.2 .6 .2];
ylim([0 .109]);
set(gca,'ytick',[0 0.05 0.1]);

end