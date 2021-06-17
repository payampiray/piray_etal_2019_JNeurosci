function tx = ba_fx(modelname,params,isinv)

ux    = @(x,A)A./(1+exp(-x));
uxinv = @(y,A)(log(y./(A-y)));

fx = ux;
if isinv
    fx = uxinv;
end

modelname = modelname(7:end);
tx = nan(size(params));

if any(strcmp(modelname, {'m4'}))
    tx(:,1)     = exp(params(:,1));
    tx(:,2)     = fx(params(:,2),1);
    tx(:,3)     = fx(params(:,3),1);    
    tx(:,4)     = fx(params(:,4),1);
    tx(:,5)     = fx(params(:,5),1);
    d = size(params,2);
    tx(:,6:d)   = params(:,6:d);
end
if any(strcmp(modelname, {'m2'}))
    tx(:,1)     = exp(params(:,1));
    tx(:,2)     = fx(params(:,2),1);
    tx(:,3)     = fx(params(:,3),1);    
    tx(:,4)     = fx(params(:,4),1);
    d = size(params,2);
    tx(:,5:d)   = params(:,5:d);
end

if any(strcmp(modelname, {'m3'}))
    tx(:,1)     = exp(params(:,1));
    tx(:,2)     = fx(params(:,2),1);
    tx(:,3)     = fx(params(:,3),1);    
    d = size(params,2);
    tx(:,4:d)   = params(:,4:d);
end


end


%----
function tx = fx_phj1(fx,params)
tx = nan(size(params));
    tx(:,1:4) = fx(params(:,1:4),10);
    tx(:,5:6) = fx(params(:,5:6),1);    
    tx(:,7:10) = params(:,7:10);
end

function tx = fx_phj2(fx,params)
    tx = nan(size(params));
    tx(:,1:4) = fx(params(:,1:4),10);
    tx(:,5:7) = fx(params(:,5:7),1);    
    tx(:,8:11) = params(:,8:11);
end
function tx = fx_phj5(fx,params)
    tx = nan(size(params));
    tx(:,1:2) = fx(params(:,1:2),10);
    tx(:,3:5) = fx(params(:,3:5),1);    
    tx(:,6:9) = params(:,6:9);    
end

