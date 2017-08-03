#include <stdio.h>

// A macro for checking the error codes of cuda runtime calls
#define CUDA_ERROR_CHECK(expr) \
  {                            \
    cudaError_t err = expr;    \
    if (err != cudaSuccess)    \
    {                          \
      printf("CUDA call failed!\n%s\n", cudaGetErrorString(err)); \
      exit(1);                 \
    }                          \
  }


__global__
void swapChannel_kernel(uchar3 * device_inputImage, uchar3 * device_outputImage, int rows, int cols)
{
  //----------------------------------------------------------------
  // TODO: Implement this Kernel
  //----------------------------------------------------------------

}

__global__
void blurImage_kernel(uchar3 * device_inputImage, uchar3 * device_outputImage, int rows, int cols)
{
  //----------------------------------------------------------------
  // TODO: Implement this Kernel
  //----------------------------------------------------------------
}

__global__
void inplaceFlip_kernel(uchar3 * device_outputImage, int rows, int cols)
{
  //----------------------------------------------------------------
  // TODO: Implement this Kernel
  //----------------------------------------------------------------

}

__global__
void creative_kernel(uchar3 * device_inputImage, uchar3 * device_outputImage, int rows, int cols)
{
  //----------------------------------------------------------------
  // TODO: Implement this Kernel
  //----------------------------------------------------------------

}


__host__
float filterImage(uchar3 *host_inputImage, uchar3 *host_outputImage, int rows, int cols, int filterNumber){

  int numPixels = rows * cols;

  //allocate memory on device (GPU)
  uchar3 *device_inputImage;
  uchar3 *device_outputImage;

  CUDA_ERROR_CHECK(cudaMalloc(&device_inputImage, sizeof(uchar3) * numPixels));
  CUDA_ERROR_CHECK(cudaMalloc(&device_outputImage, sizeof(uchar3) * numPixels));
  CUDA_ERROR_CHECK(cudaMemset(device_outputImage, 0,  sizeof(uchar3) * numPixels)); //make sure no memory is left laying around

  //copy input image to the device (GPU)
  CUDA_ERROR_CHECK(cudaMemcpy(device_inputImage, host_inputImage, sizeof(uchar3) * numPixels, cudaMemcpyHostToDevice));

  //start timing to measure length of kernel call
  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  cudaEventRecord(start);

  //----------------------------------------------------------------
  // TODO: Fill in the parameters for the kernel calls
  //----------------------------------------------------------------
  // Each of the parameters are as follows:
  //    1. Number of thread blocks, can be either int or dim3 (see CUDA manual)
  //    2. Number of threads per thread block, can be either int or dim3 (see CUDA manual)

  // Also note that you pass the pointers to the device memory to the kernel call

  int gridSize = 1;
  int blockSize = 1;

  switch(filterNumber){
    case 1:
      swapChannel_kernel<<<gridSize,blockSize>>>(device_inputImage, device_outputImage, rows, cols);
      break;
    case 2:
      blurImage_kernel<<<gridSize,blockSize>>>(device_inputImage, device_outputImage, rows, cols);
      break;
    case 3:
      inplaceFlip_kernel<<<gridSize,blockSize>>>(device_inputImage, rows, cols);
      break;
    case 4:
      creative_kernel<<<gridSize,blockSize>>>(device_inputImage, device_outputImage, rows, cols);
      break;
    default:
      break;
  }

  //----------------------------------------------------------------
  // END KERNEL CALLS - Do not modify code beyond this point!
  //----------------------------------------------------------------

  //stop timing
  cudaEventRecord(stop);

  cudaEventSynchronize(stop);

  float timeElapsedInMs = 0;
  cudaEventElapsedTime(&timeElapsedInMs, start, stop);

  //synchronize
  cudaDeviceSynchronize(); CUDA_ERROR_CHECK(cudaGetLastError());

  //copy device output image back to host output image
  //special case for filter swap - since it is in place, we actually copy the input image back to the host output
  if (filterNumber==3){
    CUDA_ERROR_CHECK(cudaMemcpy(host_outputImage, device_inputImage, sizeof(uchar3) * numPixels, cudaMemcpyDeviceToHost));
  }else{
    CUDA_ERROR_CHECK(cudaMemcpy(host_outputImage, device_outputImage, sizeof(uchar3) * numPixels, cudaMemcpyDeviceToHost));
  }


  //free Memory
  CUDA_ERROR_CHECK(cudaFree(device_inputImage));
  CUDA_ERROR_CHECK(cudaFree(device_outputImage));

  return timeElapsedInMs;
}
