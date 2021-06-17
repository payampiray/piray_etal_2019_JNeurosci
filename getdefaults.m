function varargout = getdefaults(action,varargin)

pipedir = 'data';

ss = [1:19 21:45];
subjs = cell(length(ss),1);
subjs_old = cell(length(ss),1);
for s=1:length(ss)
    subjs{s} = sprintf('S%02d',ss(s));
    subjs_old{s} = sprintf('subj%02d',ss(s));
end

switch action
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'pipedir'
    varargout{:} = pipedir;

case 'N' % subjects
    varargout{:}=44;
case 'Q' % cue-types
    varargout{:}=4;
case 'S' % sessions
    varargout{:}=3;
case 'L' % length of session
    varargout{:}=120;
case 'T' % total number of trials
    varargout{:}=480;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% subjects
case 'subjs'
varargout{:}=subjs; 
% case 'age'
% age = getage;   
% varargout{:}=age(ss);

case 'LSAS'
    [varargout{1},varargout{2}] = LSAS;

case 'sessions'
    varargout{:}={'s1','s2','s3'};       

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'getxseqdata'
    fname = fullfile(pipedir,'xseqdata.mat'); % of all 44 subjects
    data = load(fname); data=data.xseqdata;
    varargout{:} = data;

case {'rt','RT'}
    varargout{:} = 2.32;

otherwise
    error('Unknown action: %s\n',action);
end


end

function [g,a] = LSAS

fn      = fullfile('data','LSAS.mat');
x       = load(fn); x = x.LSAS;

z = [x.test.subjno x.test.score];
x = [x.screen.ppno x.screen.subjno x.screen.score];

N = size(x,1);
Y = nan(N,size(x,2));

for i=1:N
    s = x(i,2);
    Y(s,:) = x(i,:);
end
Y = [Y z(:,2)];

ss = [1:19 21:45];
y  = Y(ss,:); 
a = y(:,3);
ma = median(a);
g = a>ma;
end

