function d = distance_L2(from,to)

[n1 D1] = size(from);
assert(n1==1);

[n2 D2] = size(to);
assert(D1==D2);

D = D1;
n = n2;

d = sqrt( sum( (repmat(from,n,1)-to).^2 , 2 ) );

