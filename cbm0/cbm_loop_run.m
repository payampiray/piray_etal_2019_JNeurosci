function cbm_loop_run


killme = 1;
tic;
try
    quad_lap(input);
catch message
    disp(message.message);
%     killme = 0;
end
toc;
if ~killme, return, end


end

function quad_lap(input)

id   = input(1);
n    = input(2);

fdir   = fullfile(pwd,sprintf('cbm_loop_temp%d',id));
finput = fullfile(fdir,sprintf('input_%d_%03d.mat',id,n));
inputs = load(finput);

cbmdir = inputs.cbmdir;
data   = inputs.data;
models = inputs.models;
priors = inputs.priors;
config = inputs.config;
mode   = inputs.mode;

addpath(cbmdir);
K      = length(models);
N      = length(data);
loglik = nan(K,1);
m      = cell(K,1);
A      = cell(K,1);
G      = cell(K,1);
flag   = nan(K,1);
kopt   = nan(K,1);

for k=1:K
    for i=1:N
        [loglik(k,i),m{k}(:,i),A{k,i},G{k}(i,:),flag(k,i),kopt(k,i)] = ...
            cbm_quad_lap(data{i},models{k},priors(k,i),config(k,i),mode);
    end
end

foutput = fullfile(fdir,sprintf('output_%d_%03d.mat',id,n));
dosave = 1;
while dosave
    save(foutput,'loglik','m','A','G','flag','kopt');
    try 
        load(foutput);
        dosave = 0;
    catch
        dosave = 1;
        pause(5);
    end
end    

end