function M = table1

cmdir     = fullfile('data','cm1'); 

L = nan(1,6);
d = nan(1,6);
mnames = cell(1,6);
for i = 1:6
    model = sprintf('model_m%d',i);
    mnames{i} = model;
    fhierlap = fullfile(cmdir,sprintf('hierlap_%s.mat',model));  
    cbm   = load(fhierlap); cbm = cbm.cbm;
    L(i) = cbm.output.log_evidence;
    d(i) = size(cbm.output.parameters,2);
end
L = L + 12000;
L = L-max(L);
M = [mnames; num2cell(d); num2cell(L)]'; M

end