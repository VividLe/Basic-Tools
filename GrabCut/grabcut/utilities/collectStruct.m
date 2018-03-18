function collectStruct(s,varargin)
% variables to add to the struct, as var names, use command syntax
% if s already exists, members will be overwritten or added (intended behaviour)

n = numel(varargin);
for i = 1:n
	evalin('caller',sprintf('%s.(''%s'') = %s;',s,varargin{i},varargin{i}));
end;
