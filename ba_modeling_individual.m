function ba_modeling_individual

% indicate subject number (1 to 44)
% n = 1:44 for all of them
n = 1;

run(n);
end

function run(nn)
addpath('cbm0');

% % precision = 0.05;
% % x         = log(1/precision-1);
% % v0        = fzero(@(v)log(normpdf(x,0,v)/normpdf(0,0,v))-log(.5),3)^2;
v0        = 6.2539;

m = 1;
mdls{m} = @model_m1;
init{m}   = zeros(1,5); m = m+1;
mdls{m} = @model_m2;
init{m}   = zeros(1,7); m = m+1;
mdls{m} = @model_m3;
init{m}   = zeros(1,6); m = m+1;
mdls{m} = @model_m4; 
init{m}   = zeros(1,7); m = m+1;
mdls{m} = @model_m5; 
init{m}   = zeros(1,8); m = m+1;
mdls{m} = @model_m6;
init{m}   = zeros(1,8);

ii = 1:length(mdls);

% 
%-------------------
pipedir   = 'data';
data      = load(fullfile(pipedir,'data.mat')); data = data.data;
cmdir     = fullfile(pipedir,sprintf('cmx')); 
temp_dir     = fullfile(cmdir,'temp'); mkdir(temp_dir);
N         = length(data);

for i     = ii
    model = mdls{i};   
    fname = fullfile(cmdir,sprintf('%s.mat',func2str(model)));        
    
    if ~exist(fname,'file')
        d     = length(init{i}); 
        config.save_data = 0; 
        config.rng = [-2*ones(1,d);2*ones(1,d)];
        prior = struct('mean',zeros(d,1),'variance',v0);            
        for n = nn
            flap = fullfile(temp_dir,sprintf('%s_%02d.mat',func2str(model),n));
            if ~exist(flap,'file')
                cbm  = cbm_lap(data(n), model, prior, [], config); %#ok<NASGU>
                save(flap,'cbm');
            end
        end
        
        [fnames,ok] = getfileordered(temp_dir,sprintf('%s_%s.mat',func2str(model),'%02d'),1:N);
        if ok
            cbm = cbm_lap_aggregate(fnames); %#ok<NASGU>        
            save(fname,'cbm');
        end
    end    
    
end

end