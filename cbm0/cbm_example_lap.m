function cbm_example_lap
% This script shows an example of how cbm_lap should be used

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
% Try to study the structure of model_RW
model = @model_RW;


d     = 2; % number of free parameters in the model
% you can test whether the format of the model is good for cbm_lap by
% examining its output for a random set of parameters and for one sample:
t = rand(1,d);
dat = data{1};
F = model(t,dat); %#ok<NASGU>
% F should be a real scaler and negative for choice data.

% for prior, we assume a large variance and zero mean
v     = 10;
prior = struct('mean',zeros(d,1),'variance',v);

% for saving output
fname = 'RW_lap.mat'; 

% run it
cbm_lap(data, model, prior, fname);

% Now open the file RW_lap.mat. look at cbm.output that contains two 
% main outputs of the fitting procedure
% cbm.output.parameters are fitted parameters for each subject
% cbm.output.log_evidence are log-model-evidence for each subject

end