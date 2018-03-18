function varargout = map_c2c(f,varargin)

varargout = cell(1,nargout());
[varargout{:}] = cellfun(f,varargin{:},'UniformOutput',false);
