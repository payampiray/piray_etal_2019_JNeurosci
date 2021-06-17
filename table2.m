function table2
% parameter of the winning model
model     = 'model_m4';


fname   = fullfile('data','cm1',sprintf('%s.mat',model));    
cbm     = load(fname); cbm = cbm.cbm;
fx      = cbm.output.parameters;
tlap    = ba_fx(model,fx,0);


q1 = prctile(tlap,25,1);
q2 = prctile(tlap,50,1);
q3 = prctile(tlap,75,1);

fname   = fullfile('data','cm1',sprintf('hierlap_%s.mat',model));    
cbm     = load(fname); cbm = cbm.cbm;
mg      = cbm.output.group_mean;
m       = ba_fx(model,mg,0);

Q  = [q1' q2' q3' m'];
Q = round(Q*10^3)*10^-3;

i_parameters = [3 4 5 2 1 6 7 8];
Q = Q(i_parameters,:);

end