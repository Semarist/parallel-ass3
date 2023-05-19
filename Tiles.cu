#include <stdio.h>
#include <time.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <stdlib.h>

__global__ void tiles_matrix_mult(int *M, int *N, int *P,int RM, int CM, int CN)
{
    __shared__ int m[16][16];
    __shared__ int n[16][16];

    int bx = blockIdx.x;
    int by = blockIdx.y;
    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int row = by * blockDim.y + ty;
    int col = bx * blockDim.x + tx;

    int res= 0;

    for (int i = 0; i < (CN - 1) / 16 + 1; i++)
    {
        if (row < rowM && tx * 16 + tx < CM)
        {
            m[ty][tx] = M[row * CM + i * 16 + tx];
        }
        else
        {
            m[ty][tx] = 0;
        }

        if (i * 16 + ty < CM && col < CN)
        {
            n[ty][tx] = N[(i * 16 + ty) * CN + col];
        }
        else
        {
            n[ty][tx] = 0;
        }

        __syncthreads();

        if (row < RM && col < CN)
        {
            for (int j = 0; j < 16; j++)
            {
                prod += m[ty][j] * n[j][tx];
                __syncthreads();
            }
        }
    }

    if (row < RM && col < CN)
    {
        P[row * colN + col] = res
    }
}

int main()
{
    

    int RM, CM, CN;
    scanf("%d %d %d", &RM, &CM, &CN);

    int size1= RM*CM;
    int size2 = CM* CN;
    int size3 = RM*CN;

    int *M = (int *)malloc(sizeof(int) * size1);
    int *N = (int *)malloc(sizeof(int) * size2);
    int *P = (int *)malloc(sizeof(int) * size3);

    for (int i = 0; i < RM; i++)
    {
        for (int j = 0; j < CM; j++)
        {
            M[i * RM + j] = rand() % 1000 + 1;
        }
    }

    for (int i = 0; i < CM;i++)
    {
        for (int j = 0; j < CN;j++)
        {
            N[i * CM + j] = rand() % 1000 + 1;
        }
    }

    int *d_M, *d_N, *d_P;
    cudaMalloc(&d_M, sizeof(int) * size1);
    cudaMalloc(&d_N, sizeof(int) * size2);
    cudaMalloc(&d_P, sizeof(int) * size3);

    cudaMemcpy(d_M, M, sizeof(int) * size1, cudaMemcpyHostToDevice);
    cudaMemcpy(d_N, N, sizeof(int) * size2, cudaMemcpyHostToDevice);

    dim3 blockDim(16,16);
    dim3 gridDim((CN + blockDim.x - 1) / blockDim.x, (RM + blockDim.y - 1) / blockDim.y);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);

    tiles_matrix_mult<<<gridDim, blockDim>>>(d_M, d_N, d_P, RM, CM, CN);

    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    cudaMemcpy(P,d_P, sizeof(int) * size3, cudaMemcpyDeviceToHost);

    cudaFree(d_M);
    cudaFree(d_N);
    cudaFree(d_P);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    printf("Time of execution: %.8f milliseconds\n", milliseconds);

    free(M);
    free(N);
    free(out);

    return 0;
}