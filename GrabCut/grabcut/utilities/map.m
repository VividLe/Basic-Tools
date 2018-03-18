function varargout = map(out,mode,func,in,args)
% Maps a function to (several) arrays / cells.
%
% arguments:
%   out = chars of 'ca'
%     Controles the aggregation of output arguments.
%     c = as a cell
%     a = as an array
%     The size and shape will be the same as the input arrays/cells.
%   mode = for | par
%     for = using a plain matlab for loop (not parallel)
%     par = using the par toolbox (parallel)
%   func = function handle
%     function to be mapped
%   in = chars of '-ca'
%     Determines the type of the input arguments to the function (see args).
%     - = non-indexed argument, the same for each index
%     c = cell to be mapped
%     a = array to be mapped
%   args = row cell of args
%     input arguments to be mapped

assert(nargout()==length(out),'number of output arguments doesnt match');
assert(length(in)==length(args));

K = nargout();

% TODO par disabled, it's not implemented for your configuration
if strcmp(mode,'par')
	mode = 'for';
end;

switch mode

	case 'for' % for loop
		
		D = get_in_dim(in,args);
		n = prod(D);

		res = cell(n,K);
		for i = 1:n
			[res{i,:}] = call_indexed(i,func,in,args);
		end;

		varargout = cell(1,K);
		for k = 1:K
			varargout{k} = res(:,k);
			varargout{k} = reshape(varargout{k},D);
			switch out(k)
				case 'a'
					varargout{k} = cell2mat(varargout{k});
				case 'c'
				otherwise
					assert(false);
			end;
		end;

	case 'par' % TODO implement your own parallel computing

		assert(false);

	otherwise
		assert(false,'unknown mode %s',mode);

end;


function varargout = par_map_call_indexed(func,L,in_static,in_indexed,static,varargin)

args = cell(1,L);
args(in_static) = static;
args(in_indexed) = varargin;

K = nargout();
varargout = cell(1,K);

[varargout{:}] = func(args{:});


function D = get_in_dim(in,args)

K = length(in);
assert(K==length(args));

D = [];

for k = 1:K
	switch in(k)
		case '-'
		case {'a','c'}
			if isempty(D)
				D = size(args{k});
			else
				assert(all(D==size(args{k})));
			end;
		otherwise
			assert(false);
	end;
end;

assert(~isempty(D));


function varargout = call_indexed(index,func,in,args)

n = length(in);
for i = 1:n
	switch in(i)
		case '-'
		case 'a'
			args{i} = args{i}(index);
		case 'c'
			args{i} = args{i}{index};
		otherwise
			assert(false);
	end;
end;

varargout = cell(1,nargout());
[varargout{:}] = func(args{:});

