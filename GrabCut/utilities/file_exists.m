function e = file_exists(file)
% file_exist checks for the existance of a file or folder.
% Works for cell arrays of files.

if iscell(file)
	e = cellfun(@file_exist,file);
else
	if exist(file,'file')
		e = true;
	else
		e = false;
	end;
end;
