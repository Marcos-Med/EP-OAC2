// Filename: matrix_multiplication_cuda.cu

#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define N 3  // Dimension of the matrices (n x n)

// CUDA kernel for matrix multiplication
__global__ void matrixMultiplyKernel(double *A, double *B, double *C, int n) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;  // Row index of C and A
    int col = blockIdx.x * blockDim.x + threadIdx.x;  // Column index of C and B

    if (row < n && col < n) {
        double value = 0.0;
        for (int k = 0; k < n; k++) {
            value += A[row * n + k] * B[k * n + col];
        }
        C[row * n + col] = value;
    }
}

// Function to print the matrix
void printMatrix(double *matrix, int n) {
    for (int i = 0; i < n * n; i++) {
        printf("%.1f ", matrix[i]);
        if ((i + 1) % n == 0) {
            printf("\n");
        }
    }
}

int main() {
    int n = N;
    size_t size = n * n * sizeof(double);

    // Allocate memory on the host (CPU)
    double *h_A = (double *)malloc(size);
    double *h_B = (double *)malloc(size);
    double *h_C = (double *)malloc(size);

    // Initialize matrices with 2.0
    for (int i = 0; i < n * n; i++) {
        h_A[i] = 2.0;
        h_B[i] = 2.0;
        h_C[i] = 0.0;
    }

    // Allocate memory on the device (GPU)
    double *d_A, *d_B, *d_C;
    cudaMalloc((void **)&d_A, size);
    cudaMalloc((void **)&d_B, size);
    cudaMalloc((void **)&d_C, size);

    // Copy input matrices from host to device
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

    // Define block and grid sizes
    dim3 threadsPerBlock(16, 16);
    dim3 blocksPerGrid((n + threadsPerBlock.x - 1) / threadsPerBlock.x,
                       (n + threadsPerBlock.y - 1) / threadsPerBlock.y);

    // Create CUDA events for timing
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Record the start event
    cudaEventRecord(start);

    // Launch the matrix multiplication kernel on the GPU
    matrixMultiplyKernel<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, n);

    // Record the stop event
    cudaEventRecord(stop);

    // Wait for the stop event to complete
    cudaEventSynchronize(stop);

    // Calculate the elapsed time in milliseconds
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);
    printf("Kernel execution time: %.3f ms\n", elapsedTime);

    // Copy result matrix from device to host
    cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

    // Print the result matrix
    printf("Result matrix C (after multiplication):\n");
    printMatrix(h_C, n);

    // Free device memory
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    // Free host memory
    free(h_A);
    free(h_B);
    free(h_C);

    // Destroy CUDA events
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    // Reset the device
    cudaDeviceReset();

    return 0;
}