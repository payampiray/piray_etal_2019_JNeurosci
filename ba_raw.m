function yg = ba_raw

data  = getdefaults('getxseqdata');
L     = getdefaults('L');
Q     = getdefaults('Q');

for i=1:length(data)
    xseq    = data{i}.q2x2data.pseq;
    go      = data{i}.q2x2data.go;    
        
    x = nan(L,1);
    for q=1:Q
        i50 = xseq(:,q) ~= 1000;
        
        lgo     = logical((xseq(i50,q) <  50));
        x(lgo)= 1-go(lgo,q);
        
        hgo     = logical((xseq(i50,q) >  50));
        x(hgo)= go(hgo,q);
        
        hgo     = logical((xseq(i50,q) ==  50));
        x(hgo)= nan;        

        p = xseq(i50,q);
        dp = [0;diff(p)];
        idp = find(dp~=0);

        isg = [];
        jxx = [];
        for j=3:length(idp)
            ii = idp(j-1):idp(j);
            if length(ii)>10                
                isg = [isg xseq(ii(2))>50];                
                ix  = [max(ii(1),1) :ii(10)];
                xix = x(ix)';
                                
                jxx = [jxx; xix];                
            end
        end        
        yg{1,q}(i,:)  = nanmean(jxx(isg==0,:),1);
        yg{2,q}(i,:)  = nanmean(jxx(isg==1,:),1);
    end
end

end