function d = distance_hamming(from,to)

[n1 D1] = size(from);
assert(n1==1);

[n2 D2] = size(to);
assert(D1==D2);

d = mex_hammingDistanceBitwise(from',to');

