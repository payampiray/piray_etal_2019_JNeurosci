function [loglik,m,A,G,flag,kopt,loop] = cbm_loop_quad_lap(alldata,models,allpriors,allconfigs,mode) %#ok<INUSD>

errsource  = '';
warnsource = {};

%--------------------------------------------------------------------------
% check the format of prior, is it common across samples or specfic
% (different per sample)
K          = length(models);
N          = length(alldata);

[pK,pN]    = size(allpriors);
modeprior  = '';
if (length(allpriors)==K), modeprior = 'common'; end
% % if isrow(allpriors), allpriors = allpriors'; end
if (pK==K && pN==N), modeprior = 'specific'; end
if ~any(strcmp(modeprior,{'common','specific'}))
    error('priors is not a recognized format');
end


% check the format of config, is it common across samples or specfic
% (different per sample)
[pK,pN]    = size(allconfigs);
modeconfig = '';
if (length(allconfigs)==K), modeconfig = 'common'; end
% % if isrow(allconfigs), allconfigs = allconfigs'; end
if (pK==K && pN==N), modeconfig = 'specific'; end
if ~any(strcmp(modeconfig,{'common','specific'}))
    error('config is not a recognized format');
end

% the directory of caller function
[s] = dbstack('-completenames');
[calldir] = fileparts(s(2).file);
% temporary
calldir = pwd;

% generates a unique id
id     = str2double(datestr(now,'mmddHHMMSSFFF'));

% create a working directory using the id
fdir   = fullfile(calldir,sprintf('cbm_loop_temp%d',id));
if exist(fdir,'dir')
    rmdir(fdir,'s');
end
[okdir] = mkdir(fdir);
if ~okdir
    error('cannot creat %s',fdir);
end

% cbmdir
cbmdir = fileparts(which('cbm_loop_quad_lap.m'));
if isempty(cbmdir)
    error('cannot find cbm directory');    
end

fid = 1;
% read configs (see cbm_config)
runtime         = allconfigs(1).loop_runtime;
maxruntime      = max(allconfigs(1).loop_maxruntime,runtime);
pausesec        = allconfigs(1).loop_pausesec;
maxnumrun       = allconfigs(1).loop_maxnumrun;
% inrun       = config(1).loop_discard_bad;
loadsavetime    = 5;
maxloadsavetime = 300;


% generate matlab bacth
batchinput = [id*ones(N,1) (1:N)'];
cbm_loop_genbatch('cbm_loop_run.m',batchinput,fdir);
cbm_loop_genbashscript(fullfile(fdir,'matlabsc'),time2vec(runtime),'3gb');
% currdir = pwd;

% send batches for cluster computing
jobscripts = cell(N,1);
fscript = fullfile(fdir,'matlabsc');
% cd(fdir);

system(sprintf('chmod 755 %s',fscript));
for n=1:N
    finput = fullfile(fdir,sprintf('input_%d_%03d.mat',id,n));
    data   = alldata(n); %#ok<NASGU>
    switch modeprior
        case 'common'
            priors = allpriors; %#ok<NASGU>
        case 'specific'
            priors = allpriors(:,n); %#ok<NASGU>
    end
    switch modeconfig
        case 'common'
            config = allconfigs; %#ok<NASGU>
        case 'specific'
            config = allconfigs(:,n); %#ok<NASGU>
    end
    try
        dosave = 1; savesec = 0;
        while dosave && (savesec<=maxloadsavetime)
            save(finput,'data','models','priors','config','mode','cbmdir');
            try 
                saved = load(finput);
                saved.data; saved.models; saved.priors; saved.config; saved.mode; saved.cbmdir;
                dosave  = 0;
            catch
                dosave  = 1;
                savesec = savesec + loadsavetime;
                pause(loadsavetime); % wait for few seconds, maybe it cannot write on the disc right now.
            end
        end
    catch
        error('cannot create %s',finput);        
    end
    fjob = fullfile(fdir,sprintf('cbm_loop_run_temp%06d.m',n));
    [~,jobscripts{n}] = system(sprintf('%s %s',fscript,fjob));
end


% wait a bit and check if all batches are successfully done
pause on;
ok         = false(N,1);
numrun     = 1;
lastminute = 0;
success    = ok;
checked    = zeros(N,1);
while any(~ok)
    pause(pausesec);
    lastminute = lastminute + pausesec/60;
    for n=1:N
        foutput     = fullfile(fdir,sprintf('output_%d_%03d.mat',id,n));
        success(n)  = exist_foutput(foutput); 
        ok(n)       = success(n);
        fnamescript = fullfile(fdir,sprintf('cbm_loop_run_temp%06d.m',n));
        
        % if not successful, check what is the reason
        if ~ok(n) 
            oks = exist(fnamescript,'file');
            if ~oks % already the batch killed itself, so something is probably wrong.
                checked(n) = checked(n)+1; % number of times this happened already
                if checked(n)>2 % sounds serious, let's do something about it
                    % now we try to run it here rather than submitting as a job
                    fprintf('cbm_loop_run cannot run for sample %03d!\ntry inside-running...',n);
                    warnsource = [warnsource sprintf('Step1%03d',n)];
                    finput = fullfile(fdir,sprintf('input_%d_%03d.mat',id,n));
                    try
                        success(n) = inrunning(finput,foutput);
                        ok(n)  = success(n);
                        if ~success(n)
                            error('cbm_loop_run cannot run for sample %03d!\nsomething is wrong with the model, data etc! have to stop...',n);
                        end                        
                    catch msg
                        % It did not work out. something is wrong with the
                        % model, data etc
                        fprintf(fid,'   %s\n',msg.message);
                        error('cbm_loop_run cannot run for sample %03d!\nsomething is wrong with the model, data etc! have to stop...',n);
                    end
                end
            end %~oks
        end %~ok(n)
    end
        
    % maybe it is cancelled, try again with a longer time [the longer time is max(numrun*runtime,maxruntime)]
    if (lastminute>= runtime) && any(~ok)
        for n=1:N
            if ~ok(n)
                if numrun<=maxnumrun
                    lastminute = 0; % reset time
                    numrun = numrun+1;
                    fprintf('cbm_loop_run failed for sample %03d! we try with a longer rum-time\n',n);
                    warnsource = [warnsource sprintf('Step2%03d',n)];
                    
                    cbm_loop_genbashscript(fscript,time2vec(max(numrun*runtime,maxruntime)),'3gb');
                    system(sprintf('chmod 755 %s',fscript));
                    fjob = fullfile(fdir,sprintf('cbm_loop_run_temp%06d.m',n));
                    nn = length(jobscripts)+1;
                    [~,jobscripts{nn}] = system(sprintf('%s %s',fscript,fjob));
                else % cannot be completed in the requested time or even the longer time
%                     if discard_bad % then replace with prior mean and big variance
                    checked(n) = checked(n)+1; % number of times this happened already
                    if checked(n)>2 % sounds serious, let's do something about it
                        fprintf('cbm_loop_run cannot run for sample %03d!try inside-running...',n);
                        warnsource = [warnsource sprintf('Step3%03d',n)];
                        finput = fullfile(fdir,sprintf('input_%d_%03d.mat',id,n));                                                                        
                        try
                            success(n)  = inrunning(finput,foutput);
                            ok(n)  = success(n);
                            if ~success(n)
                                error('cbm_loop_run cannot run for sample %03d!\nsomething is wrong with the model, data etc! have to stop...',n);
                            end
                        catch msg
                            fprintf(fid,'   %s\n',msg.message);
                            error('cbm_loop_run cannot run for sample %03d!\nsomething is wrong with the model, data etc! have to stop...',n);
                        end                        
%                     else
%                         error('cbm_loop_run cannot finish for sample %03d after %d tries! have to stop...',n,numrun);
%                     end
                    end % checked...
                end %numrun<=maxnumrun
            end % ~ok(n)
        end
    end %lastminute>= runtime        
end

% % delete all the scripts (some of them might have been sent more than once,
% % so better to delete them all
% delscripts = cell(size(jobscripts));
% for n=1:length(jobscripts)
%     [~,delscripts{n}]=system(sprintf('qdel %s',jobscripts{n}));
% end

% cd(currdir);
loglik     = nan(K,0);
m          = cell(K,1);
A          = cell(K,0);
flag       = nan(K,0);
kopt       = nan(K,0);
G          = cell(K,1);
for n=1:N
    foutput          = fullfile(fdir,sprintf('output_%d_%03d.mat',id,n));
    output           = load(foutput,'loglik','m','A','G','flag','kopt');
    
    doload = 1; loadsec = 0;
    while doload && (loadsec<maxloadsavetime)        
        try 
            output           = load(foutput,'loglik','m','A','G','flag','kopt');
            output.loglik; output.m; output.A; output.G; output.flag; output.kopt;
            doload = 0;
        catch
            doload = 1;
            loadsec = loadsec + loadsavetime;
            pause(loadsavetime); % wait for few seconds, maybe it cannot write on the disc right now.
        end
    end
        
    loglik           = [loglik output.loglik]; %#ok<AGROW>
    A                = [A output.A]; %#ok<AGROW>
    for k=1:K
        m{k}    = [m{k} output.m{k}];                
        G{k}    = [G{k}; output.G{k}];
    end
    flag             = [flag output.flag]; %#ok<AGROW>
    kopt             = [kopt output.kopt]; %#ok<AGROW>
end
try
    rmdir(fdir,'s');
catch msg
    warnsource = [warnsource sprintf('Step4:rmdir')];
    fprintf(fid,'   %s\n',msg.message);
end
loop = struct('id',id,'success',success,'numrun',numrun,'jobscripts',{jobscripts},'warnsource',{warnsource});
end

function ok = discarding(finput,foutput)
inputs = load(finput);
data   = inputs.data;
models = inputs.models;
priors = inputs.priors;

K      = length(models);
N      = length(data);
loglik = nan(K,N);
m      = cell(K,1);
A      = cell(K,N);
G      = cell(K,1);
flag   = nan(K,N);
kopt   = nan(K,N);

for k = 1:K
    t = priors(k).mean;
    T = .01*priors(k).precision;
    for n=1:N
        [loglik(k,n)] = -cbm_loggaussian(t,models{k},priors(k),data{n});
        m{k}(:,n)     = t;
        A{k,n}        = T;
        G{k}(n,:)     = zeros(size(t))';
        flag(k,n)     = 0;
        kopt(k,n)     = 0;
    end
end

try
    dosave = 1;
    while dosave
        save(foutput,'loglik','m','A','G','flag','kopt');
        try 
            load(finput);
            dosave = 0;
        catch
            dosave = 1;
            pause(5); % wait for few seconds, maybe it cannot write on the disc right now.
        end
    end
    ok = 1;
catch
    ok = 0;
end

end

function ok = inrunning(finput,foutput)

inputs = load(finput);
data   = inputs.data;
models = inputs.models;
priors = inputs.priors;
config = inputs.config;
mode   = inputs.mode;

K      = length(models);
N      = length(data);
loglik = nan(K,N);
m      = cell(K,1);
A      = cell(K,N);
G      = cell(K,1);
flag   = nan(K,N);
kopt   = nan(K,N);

for k = 1:K
    for n=1:N
        [loglik(k,n),m{k}(:,n),A{k,n},G{k}(n,:),flag(k,n),kopt(k,n)] = cbm_quad_lap(data{n},models{k},priors(k,n),config(k),mode);
    end
end

try
    dosave = 1;
    while dosave
        save(foutput,'loglik','m','A','G','flag','kopt');
        try 
            fsaved = load(foutput);
            % test if everything saved properly
            fsaved.loglik; fsaved.m; fsaved.A; fsaved.G; fsaved.flag; fsaved.kopt;
            dosave = 0;
        catch
            dosave = 1;
            pause(5); % wait for few seconds, maybe it cannot write on the disc right now.
        end
    end
    ok = 1;
catch
    ok = 0;
end
    


end

function t = time2vec(runtime)
h = floor(runtime/60);
m = mod(runtime,60);
t = [h m 0];
end

function ok = exist_foutput(foutput)
doload = exist(foutput,'file');
ok     = 0;

loadsec  = 0;
loadtime = 5;
maxloadtime = 60;
while doload && (loadsec<maxloadtime)        
    try 
        output           = load(foutput,'loglik','m','A','G','flag','kopt');
        output.loglik; output.m; output.A; output.G; output.flag; output.kopt;
        doload = 0;
        ok     = 1;
    catch
        doload = 1;
        loadsec = loadsec + loadtime;
        pause(loadtime); % wait for few seconds, maybe it cannot load from the disc right now.
        ok     = 0;
    end
end
end
