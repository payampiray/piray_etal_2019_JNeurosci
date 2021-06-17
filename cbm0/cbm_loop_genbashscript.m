function done = cbm_loop_genbashscript(fname,walltime,mem)
% generate a shell script
% -------------------------------------------------------------------------
% Payam Piray, 02-2013
% Payam Piray, 06-2017 modified for cbm
% Donders Center for Cognitive Neuroimagig.

cbmdir = fileparts(which('cbm_loop_genbashscript'));
ffname = fullfile(cbmdir,'cbm_matlabbash');

str_walltime = sprintf('WALLTIME=%02d:%02d:%02d',walltime);
str_mem = sprintf('MEM=%s',mem);

fid = fopen(ffname);

ftxt = '';
tline = fgetl(fid);
while ischar(tline)
    idx = strfind(tline,'WALLTIME=');
    if(~isempty(idx))
        tline = str_walltime;
    end
    idx = strfind(tline,'MEM=');
    if(~isempty(idx))
        tline = str_mem;
    end

    ftxt = sprintf('%s\n%s',ftxt,tline);
    tline = fgetl(fid);    
end
fclose(fid);

fid = fopen(fname,'w');
fprintf(fid,'%s', ftxt);
fclose(fid);
done=true;

end