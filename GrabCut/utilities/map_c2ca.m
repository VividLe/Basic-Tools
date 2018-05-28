function varargout = map_c2a(f,varargin)
% Run it as cell to cell and then join the cells into an array.

varargout = cell(1,nargout());
[varargout{:}] = cell2mat(cellfun(f,varargin{:},'UniformOutput',false));
