function out = logicals_to_bits(in,bits,dimension)
% Transform logical array into a binary representation (one bit per boolean).
%
% arguments:
%   in = 2d array of logicals
%   bits = 8, 16, 32, 64 (default)
%     data type of output array (uintXX = uint8, uint16, uint32, uint64)
%   dimension = 1, 2 (default)
%     1: uintXX stretches along dimension 1 (encodes a part of a column)
%     2: uintXX stretches along dimension 2 (encodes a part of a row)
%
% output:
%   out = binary representation of in (uintXX)

arg_assert in logical
arg_assert bits numeric default 64
arg_assert dimension numeric default 2

if dimension==1
	transposed = false;
elseif dimension==2
	transposed = true;
	in = in';
else
	assert(false,'dimension=%d',dimension);
end;

type = sprintf('uint%d',bits);

assert(ndims(in)==2);
[m_in n_in] = size(in);

m_fix = ceil(m_in/bits)*bits;
in(end+1:m_fix,:) = false; % TODO worst case it resizes to early

% first transform into uint8
weights8 = bitshift(ones(1,1,'uint8'),0:7)';
in = uint8(in);
in = reshape(in,8,[]);
in = sum(bsxfun(@times,in,weights8),1,'native');

% then transform into desired data type
weights = bitshift(ones(1,1,type),0:8:bits-1)';
in = feval(type,in);
in = reshape(in,bits/8,[]);
out = sum(bsxfun(@times,in,weights),1,'native');

out = reshape(out,[],n_in);

if transposed
	out = out';
end;


function test()

%%
m = 100+randi(100);
n = 100+randi(100);
bits = rnd_selection([8 16 32 64],1);
d = rnd_selection([1 2],1);

fprintf('%#3d x %#3d (%#2dbits) along %d ... ',m,n,bits,d);

a = rand(m,n)>0.5;
b = logicals_to_bits(a,bits,d);
if d==1
	c = bits_to_logicals(b,d,m);
elseif d==2
	c = bits_to_logicals(b,d,n);
else
	assert(false);
end;

if all(a(:)==c(:))
	fprintf('ok\n');
else
	fprintf('not ok\n');
end;
