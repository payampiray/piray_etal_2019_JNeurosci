function ba_modeling_hierarchical

% indicate model number (1 to 6)
% Note: should first run ba_modeling_individual
i = 4;

run(i);
end

function run(i)
addpath('cbm0');

m = 1;
mdls{m} = @model_m1; m = m+1;
mdls{m} = @model_m2; m = m+1;
mdls{m} = @model_m3; m = m+1;
mdls{m} = @model_m4; m = m+1;
mdls{m} = @model_m5; m = m+1;
mdls{m} = @model_m6;

%--------------------------------------------------------------------------
pipedir   = 'data';
data      = load(fullfile(pipedir,'data.mat')); data = data.data;
cmdir     = fullfile(pipedir,sprintf('cm1')); 

model = mdls{i};   
fname = fullfile(cmdir,sprintf('%s.mat',func2str(model)));        

fhierlap = fullfile(cmdir,sprintf('hierlap_%s.mat',func2str(model)));   
if exist(fname,'file')
    hierconfig = struct('algorithm','hierlap','verbose',0,'save_prog',0,'tolx',.01);                
    cbm = cbm_hierlap(data, model, fname, [], hierconfig); %#ok<NASGU>
    save(fhierlap,'cbm');
else
    fprintf('%s does not exist\n',fname);
end

end