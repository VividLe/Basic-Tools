function file_mkdir(folder)
% Recursively creates directories.
% Checks first if folder exist.
% folder can be a cell of sprintf arguments

% fprintf('\nrequested folder %s\n',folder);

if iscell(folder), folder = sprintf(folder{:}); end;

assert(~any(folder=='"')); % TODO for now not handling " (using " to escape all other characters")
assert(~any(folder=='\')); % TODO not sure if it works inside ", is it still an escape then?

[status,result] = system(sprintf('mkdir -p "%s"',folder));
assert(status==0,result);


% function ver1(folder)
% 
% if iscell(folder), folder = sprintf(folder{:}); end;
% 
% if ~strcmp(folder,'') && ~file_exist(folder)
% 	file_mkdir(file_getFolder(folder));
% 	mkdir(folder);
% end;
