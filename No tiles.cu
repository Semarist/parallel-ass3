#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <stdlib.h>
#include <time.h>

__global__ void matrix_mult_kernel(int *M, int *N, int *P, int RM, int CM, int CN)
{
    int row = blockIdx.y*blockDim.y + threadIdx.y;
    int col = blockIdx.x*blockDim.x + threadIdx.x;
    
    if (row < RM && col < CN) {
        int end_res= 0;
        for (int i = 0; i < cM; i++) {
            end_res += M[row*RM + i] * N[i*CM + col];
        }
        P[row*CN + col] = end_res;
    }
}
int main()
{
      int RM;
      int CM;
      int CN;
      scanf("%d %d %d", &RM, &CM, &CN);

      int s1 = RM*CM;
      int s2 = CM*CN;
      int s3 = RM*CN;
      
      int *M = (int *)malloc(sizeof(int)*s1);
      int *N = (int *)malloc(sizeof(int)*s2);
      int *p = (int *)malloc(sizeof(int)*s3);

      for(int i=0;i<RM;i++)
      {
        for(int j=0;j<CM;j++)
        {
          M[i*RM+j]=rand()%1000;
        }
      }
      for(int i=0;i<colM;i++)
      {
        for(int j=0;j<colN;j++)
        {
          N[i*CM+j]=rand()%1000;
        }
      }

    int *d_M, *d_N, *d_p;
    cudaMalloc(&d_M, sizeof(int)*s1);
    cudaMalloc(&d_N, sizeof(int)*s2);
    cudaMalloc(&d_p, sizeof(int)*s3);

    cudaMemcpy(d_M, M, sizeof(int)*size1, cudaMemcpyHostToDevice);
    cudaMemcpy(d_N, N, sizeof(int)*size2, cudaMemcpyHostToDevice);

    
    dim3 gridDim((CN + blockDim.x - 1) / blockDim.x, (RM + blockDim.y - 1) / blockDim.y);
    
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);

    matrix_mult_kernel<<<gridDim, blockDim>>>(d_M, d_N, d_p, RM, CM, CN);

    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    cudaMemcpy(p, d_p, sizeof(int)*s3, cudaMemcpyDeviceToHost);
       
    cudaFree(d_M);
    cudaFree(d_N);
    cudaFree(d_p);
    
    
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    printf("Time of execution: %.8f milliseconds\n", milliseconds);

    return 0;
    
  }