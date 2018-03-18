
#include "mex.h"

/* matlab: d = f(from,to)
 *
 * arguments
 *   from = one column vector (uint64, bitwise feature vector)
 *   to = n column vectors (uint64, bitwise feature vectors)
 *
 * output
 *   d = column vector of not normalized hamming distance (uint16)
 *
 * The codelength of the binary code is limited to 2^16-1 because
 * of the size of the output type.
 *
 * The codelength does not have to be a multiple of 64 but the remaining
 * bits all have to be set to the same (0 or 1) for accurate results.
 *
 * Links about bitcounting:
 * best: http://gurmeet.net/puzzles/fast-bit-counting-routines/
 * nice: http://dalkescientific.com/writings/diary/archive/2008/07/03/hakmem_and_other_popcounts.html
 * code: http://dalkescientific.com/writings/diary/popcnt.cpp
 *
 * runtime:
 * scales linearly with length of to (for non-small lengths)
 * scales linearly with code length (for code lengths >= 64 bits)
 *
 */

unsigned char* lut;

void compute(short* d, int D, unsigned long* from, int n, unsigned long* to) {
	
	int i,j;
	unsigned long* to1;
	unsigned long* from1;
	unsigned long x;
	short d1;
	
	to1 = to;
	for(i=0; i<n; i++) {
		
		d1 = 0;
		from1 = from;
		for(j=0; j<D; j++) {
			x = *from1 ^ *to1;
			
// 			d1 += x;
			
			/* 16 bit look up table */
			d1 += lut[(unsigned short)(x>>0 & 0xffff)];
			d1 += lut[(unsigned short)(x>>16 & 0xffff)];
			d1 += lut[(unsigned short)(x>>32 & 0xffff)];
			d1 += lut[(unsigned short)(x>>48 & 0xffff)];

			/* 8 bit look up table */
// 			d1 += lut[(unsigned char)(x>>0 & 0xff)];
// 			d1 += lut[(unsigned char)(x>>8 & 0xff)];
// 			d1 += lut[(unsigned char)(x>>16 & 0xff)];
// 			d1 += lut[(unsigned char)(x>>24 & 0xff)];
// 			d1 += lut[(unsigned char)(x>>32 & 0xff)];
// 			d1 += lut[(unsigned char)(x>>40 & 0xff)];
// 			d1 += lut[(unsigned char)(x>>48 & 0xff)];
// 			d1 += lut[(unsigned char)(x>>56 & 0xff)];

// 			d1 += __builtin_popcount((unsigned int)(x & 0x00000000ffffffff));
// 			d1 += __builtin_popcount((unsigned int)(x>>32 & 0x00000000ffffffff));
// 			d1 += __builtin_popcount(*from1 ^ *to1);

			from1++;
			to1++;
		}
		
 		d[i] = d1; // /(float)D;
		
	}
	
}

void mexFunction(
		int nlhs, mxArray *plhs[],
		int nrhs, const mxArray *prhs[] ) {
	
	/* TODO use matlabs uint64 data type instead of unsigned long ? */
	
	int D64; // codelength in number of uint64s
	int n;
	unsigned long* from;
	unsigned long* to;
	short* d;
	unsigned int i;
	
	/* input arguments */
	
	if(nrhs!=2) mexErrMsgTxt("Two inputs required");
	
	if(mxGetNumberOfDimensions(prhs[0])>2) mexErrMsgTxt("from can't have more than 2 dimensions");
	D64 = mxGetM(prhs[0]);
	if(mxGetN(prhs[0])!=1) mexErrMsgTxt("from needs to be a row vector");
	if(!mxIsUint64(prhs[0])) mexErrMsgTxt("from needs to be uint64");
	from = (unsigned long*)mxGetData(prhs[0]);
	
	if(mxGetNumberOfDimensions(prhs[1])>2) mexErrMsgTxt("to can't have more than 2 dimensions");
	n = mxGetN(prhs[1]);
	if(mxGetM(prhs[1])!=D64) mexErrMsgTxt("from and to need to have the same number of columns");
	if(!mxIsUint64(prhs[1])) mexErrMsgTxt("from needs to be uint64");
	to = (unsigned long*)mxGetData(prhs[1]);
	
	/* output arguments */
	if(nlhs!=1) mexErrMsgTxt("One output required");
	if(D64*64>65535) mexErrMsgTxt("D>65535 is not supported, as the output is only uint16");
	plhs[0] = mxCreateNumericMatrix(n,1,mxUINT16_CLASS,mxREAL);
	d = (short*)mxGetData(plhs[0]);
	
	/* fill lut */
	lut = (unsigned char*)malloc(65536*sizeof(unsigned char));
	for(i=0; i<65536; i++)
		lut[i] = __builtin_popcount(i);
	
	/* computation */
	compute(d,D64,from,n,to);
	
	free(lut);
	
}
