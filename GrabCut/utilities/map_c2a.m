function varargout = map_c2a(f,varargin)

varargout = cell(1,nargout());
[varargout{:}] = cellfun(f,varargin{:},'UniformOutput',true);
