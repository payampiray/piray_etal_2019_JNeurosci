function cbm_example_hierlap
% This script shows an example of how cbm_hierlap should be used
% You need to first run cbm_lap on your data

clc;
% add cbm to your path
cbm_dir = fileparts(which('cbm_example_lap'));
addpath(cbm_dir);

% go to directory of data
example_dir = fullfile(cbm_dir,'cbm_example','RW');
cd(example_dir);

% specify data and a handle to model
fdata = 'alldata.mat';
mydata  = load(fdata); 
data = mydata.data;

% make a computational model, for example like model_RW.
% Try to study the structure of model_RW (especially its inputs and output)
model = @model_RW;

d     = 2; % number of free parameters in the model
% you can test whether the format of the model is good for cbm_lap by
% examining its output for a random set of parameters and for one sample:
t = rand(1,d);
dat = data{1};
F = model(t,dat); %#ok<NASGU>
% F should be a real scaler and negative for choice data.

% the output of cbm_lap is an input to cbm_hierlap
% see cbm_example_lap for more info
fname       = 'RW_hierlap.mat'; % for saving output
fname_lap   = 'RW_lap.mat';
cbm_hierlap(data, model, fname_lap, fname);

% Now open the file RW_hierlap.mat. look at cbm.output that contains four 
% main outputs of the fitting procedure
% cbm.output.parameters are fitted parameters for each subject
% cbm.output.group_mean is the mean of parameters across the group
% cbm.output.group_variance is the variance of parameters across the group
% cbm.output.log_evidence is log-model-evidence across all subjects

end