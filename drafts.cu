#include <cuda_runtime.h>
#include <curand_kernel.h>
#include <iostream>
#include <vector>
#include <cooperative_groups.h>
#include "MyCudaToolkit.h"
using namespace std;
namespace cg = cooperative_groups;

__device__ unsigned int reduce_sum(long in, cg::thread_block cta)
{
	extern __shared__ long sdata[];


	// Perform first level of reduction:
	// - Write to shared memory
	unsigned int ltid = threadIdx.x;
//printf("1");
	sdata[ltid] = in;

	cg::sync(cta);
//printf("2");
	// Do reduction in shared mem
	for (unsigned int s = blockDim.x / 2; s > 0; s >>= 1)
	{
		if (ltid < s)
		{
//printf("%d\n",ltid + s);
			sdata[ltid] += sdata[ltid + s];
		}

		cg::sync(cta);
	}


	return sdata[0];
}

__global__ void SimulateAbsorption(long* count,long size, int flag) {
	cg::thread_block cta = cg::this_thread_block();
	int bid = blockIdx.x;
	int tid = blockDim.x * blockIdx.x + threadIdx.x;
if (tid == 0) printf("flag %d processing...\n", flag);
	//if (tid > size) return;
	int count_flag = tid % 2;
//printf("1: %d, %d\n", count_flag, threadIdx.x);
	
	if (tid >= size) count_flag = 0;
	count_flag = reduce_sum(count_flag, cta);
	//__syncthreads();

	if (threadIdx.x == 0) {
		//printf("2\n");
		//printf("%d\n", count_flag);
printf("Check sync in GPU\n");
		count[bid] = count_flag;		
	}
if (tid == 0) printf("flag %d complete...\n", flag);

}


int main() {
	long arysize = 1024;
	long* h_count;
	long* d_count;
	
	dim3 grid, block;
	block.x = 1024;
	grid.x = (arysize - 1) / block.x + 1;
	cout << "block.x: " << block.x << "grid.x: " << grid.x << endl;
	h_count = (long*)malloc(grid.x * sizeof(long));
	CHECK(cudaMalloc((void**)&d_count, grid.x * sizeof(long)));
printf("Check sync 1. h_count[0]: %d\n", h_count[0]);
	SimulateAbsorption << <grid, block, block.x * sizeof(long) >> > (d_count, arysize, 1);
	//CHECK(cudaDeviceSynchronize());
printf("Check sync 2. h_count[0]: %d\n", h_count[0]);
	
CHECK(cudaMalloc((void**)&d_count, grid.x * sizeof(long)));
	SimulateAbsorption << <grid, block, block.x * sizeof(long) >> > (d_count, arysize, 2);
printf("Check sync 3. h_count[0]: %d\n", h_count[0]);


	CHECK(cudaMemcpy((void*) h_count, (void*) d_count, grid.x * sizeof(long), cudaMemcpyDeviceToHost));
	SimulateAbsorption << <grid, block, block.x * sizeof(long) >> > (d_count, arysize, 3);
printf("Check sync 4. h_count[0]: %d\n", h_count[0]);
	
	long total = 0;
	for (int i = 0; i < grid.x; i++) {
		//cout << "element " << i << ": " << h_count[i] << endl;
		total += h_count[i];
	}
	cout << "total: " << total;




	//vector<long*> d_absorb_num_ptrvec, h_absorb_num_ptrvec;
	//d_absorb_num_ptrvec.push_back(nullptr);
	//long* tmplongptr;

	//long** d_absorb_num_ptrary = (long**)malloc(d_absorb_num_ptrvec.size() * sizeof(long*));
	////d_absorb_num_ptrvec[0] = tmplongptr;
	//CHECK(cudaMalloc((void**)&d_absorb_num_ptrary[0], grid.x * sizeof(long)));
	////CHECK(cudaMalloc((void**)&tmplongptr, grid.x * sizeof(long)));


	return 1;
}