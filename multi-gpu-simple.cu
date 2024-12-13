#include <stdio.h>

__global__ void add(int *a, int *b, int *c, int n) {
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    if (index < n) {
        c[index] = a[index] + b[index];
    }
}

int main()
{
    int *a, *b, *c;
    int *d_a1, *d_b1, *d_c1;
    int *d_a2, *d_b2, *d_c2;
    int N = 1000;

    a = (int *)malloc(N * sizeof(int));
    b = (int *)malloc(N * sizeof(int));
    c = (int *)malloc(N * sizeof(int));
    for(int i = 0; i < N; i++) {
        a[i] = i;
        b[i] = i;
    }
    cudaSetDevice(0);
    cudaMalloc(&d_a1, N * sizeof(int));
    cudaMalloc(&d_b1, N * sizeof(int));
    cudaMalloc(&d_c1, N * sizeof(int));
    cudaMemcpy(d_a1, a, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b1, b, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaSetDevice(1);
    cudaMalloc(&d_a2, N * sizeof(int));
    cudaMalloc(&d_b2, N * sizeof(int));
    cudaMalloc(&d_c2, N * sizeof(int));
    cudaMemcpy(d_a2, a, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b2, b, N * sizeof(int), cudaMemcpyHostToDevice);

    cudaSetDevice(0);
    add<<<(N + 255) / 256, 256>>>(d_a1, d_b1, d_c1, N);
    cudaSetDevice(1);
    add<<<(N + 255) / 256, 256>>>(d_a2, d_b2, d_c2, N);
    
    cudaMemcpy(c, d_c1, N * sizeof(int), cudaMemcpyDeviceToHost);
    for(int i = 0; i < N; i++) {
        printf("%d ", c[i]);
    }
    printf("\n");
    cudaMemcpy(c, d_c2, N * sizeof(int), cudaMemcpyDeviceToHost);
    for(int i = 0; i < N; i++) {
        printf("%d ", c[i]);
    }
    printf("\n");

    cudaFree(d_a1);
    cudaFree(d_b1);
    cudaFree(d_c1);
    cudaFree(d_a2);
    cudaFree(d_b2);
    cudaFree(d_c2);
    free(a);
    free(b);
    free(c);
    return 0;
}