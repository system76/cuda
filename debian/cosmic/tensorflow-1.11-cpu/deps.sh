function exists {
    ldconfig -p | grep $1 &>/dev/null && echo 0 || echo 1
}

CUDA=$(exists libcuda.so)
CUDRT=$(exists libcudart.so)
CUDNN=$(exists libcudnn.so)
CUPTI=$(exists libcupti.so)

if [ $((CUDA + CUDRT + CUDNN + CUPTI)) -ne 0 ]; then
    test $CUDA -eq 0 || echo 'libcuda.so was not found: found in `libnvidia-compute-X`'
    test $CUDRT -eq 0 || echo 'libcudart.so was not found: provided by `system76-cuda-X.Y`'
    test $CUDNN -eq 0 || echo 'libcudnn.so was not found: provided by `system76-cuda-X.Y`'
    test $CUPTI -eq 0 || echo 'libcupti.so was not found: provided by `system76-cuda-X.Y`'
    exit 1
fi
