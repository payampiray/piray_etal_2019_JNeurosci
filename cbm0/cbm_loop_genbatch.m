function cbm_loop_genbatch(fname,inputs,targetdir,biasnum,funcname)
%     genbatch(FNAME,INPUTS)
% FNAME is an m-file.
% INPUTS is a matrix. Each row of this matrix contains inputs that should
% be passed to FNAME.
% -------------------------------------------------------------------------
% Payam Piray, 02-2013
% Payam Piray, 09-2013
% Payam Piray, 06-2017 modified for cbm
% Donders Center for Cognitive Neuroimagig.


%%% check inputs
if nargin<3, error('Number of inputs in %s is less than 3.',mfilename); end;
[fdir, ffname, fext] = fileparts(fname);
if isempty(fext), fext = '.m'; end;
if(~strcmpi(fext,'.m'))
    error('The format of input file (%s) is not correct in %s', fext, mfilename);
end
if nargin<4, biasnum = 0; end;
if nargin<5, funcname = ffname; end;
funcname1 = sprintf('function %s',funcname);

currdir = pwd;

% fname = fullfile(fdir,ffname);
% fname = [fname fext];
% fid = fopen(fname);
% indfunc = [];
% while isempty(indfunc)
%     tline = fgetl(fid);
%     indfunc = strfind(tline,'function');    
% end

%%% read the file
fname = fullfile(fdir,ffname);
fname = [fname fext];
fid = fopen(fname);
ftxt = '';
tline = fgetl(fid);
while ischar(tline)
    ftxt = sprintf('%s\n%s',ftxt,tline);
    tline = fgetl(fid);
end
fclose(fid);

%%% check to be sure the format of m-file is correct (contains at least one function)
indfunc = strfind(ftxt,sprintf('function %s',ffname));
if isempty(indfunc)
    error('The format of %s is not correct in %s', fname, mfilename);
end
%%% delete extra spaces (if any) before starting
ftxt(1:(indfunc(1)-1))=[];
%%% check to be sure that this function does not accept input
indfunc = strfind(ftxt,sprintf('\n'));
line1   = strfind(ftxt(1:indfunc),'(');
if ~isempty(line1)
    error('The format of %s is not correct in %s', fname, mfilename);
end

%%% divide to 3 parts: before function funcname, function funcname, and after it
point1 = strfind(ftxt,funcname1);
ftxt2  = ftxt(point1:end);
point2 = strfind(ftxt2,'function');
if length(point2)<2
    point2 = strfind(ftxt,sprintf('end\n'));
    if isempty(point2), 
        point2 = length(ftxt);
    else
        point2 = point2(end)+3;
    end;
else
    point2 = strfind(ftxt2(1:point2(2)),sprintf('end\n'));
    if isempty(point2), error('Oops!'); end;
    point2 = point1+point2(end)+2;
end

ftxt1 = ftxt(1:(point2-4));
ftxt3 = ftxt((point2+1):end);

%%% delete the first line (mfilename line)
indfunc = strfind(ftxt1,sprintf('\n'));
ftxt1(1:(indfunc(1)-1))=[];

%%% output directory
% targetdir = fullfile(fdir,[ffname '_temp']);
% if(~exist(targetdir,'dir')), mkdir(targetdir); end;
cd(targetdir);

%%% for each row of inputs, write a separate file
ind = 1:size(inputs,1);
for i=1:size(inputs,1)
    fnametarget = sprintf('%s_temp%02d%04d%s',ffname,biasnum,ind(i),fext);
    fid = fopen(fnametarget,'w');    
    
    % write before funcname + funcname, but not the 'end'!
    ftxtvar = sprintf('function %s_temp%02d%04d\n%s=%s;\n',ffname,biasnum,ind(i),'input',mat2str(inputs(i,:)));
    ftxtvar = sprintf('%s%s',ftxtvar,'cd(fullfile(pwd, ''..''));'); % cd(fullfile(pwd,'..'));
    ftxtvar = sprintf('%s\n%s',ftxtvar,ftxt1);
    fprintf(fid,'%s', ftxtvar);
    
    % adding suicide code + 'end'
    commenttxt = '%%%%%%%%%';
    ftxtvar = sprintf('\n%s suicide\n',commenttxt);
    fprintf(fid,'%s', ftxtvar);
    dispmsg  = [sprintf('fprintf(''I kill myself :( !') '\n'');'];
    ftxtvar  = sprintf('%s\n',dispmsg);
    fprintf(fid,'%s', ftxtvar);
    ftxtvar = 'cd(''';
    ftxtvar  =sprintf('%s%s''',ftxtvar,targetdir);
    ftxtvar = sprintf('%s);\n',ftxtvar);
    fprintf(fid,'%s', ftxtvar);

    ftxtvar = sprintf('delete(''');
    ftxtvar = sprintf('%s%s''',ftxtvar,sprintf('%s_temp%02d%04d%s',ffname,biasnum,ind(i),fext));
    ftxtvar = sprintf('%s);',ftxtvar);
    
    dispmsg  = [sprintf('fprintf(''killed.') '\n'');'];
    ftxtvar  = sprintf('%s\n%s',ftxtvar,dispmsg);
    
    ftxtvar = sprintf('%s\nend\n',ftxtvar);
    fprintf(fid,'%s', ftxtvar);
    
    % adding after funcname
    ftxtvar = ftxt3;
    fprintf(fid,'%s', ftxtvar);
    
    fclose(fid);
end

% get back
cd(currdir);
end