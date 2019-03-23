#!/bin/bash
set -e

# Test whether one version ($1) is less than or equal to other ($2).
function version_gt {
    test "`printf '%s\n' "$@" | sort -V | head -n 1`" != "$1"
}

# configure environmental variables
export CC_OPT_FLAGS=${CC_OPT_FLAGS:-"-march=ivybridge"}
export TF_NEED_GCP=${TF_NEED_GCP:-0}
export TF_NEED_HDFS=${TF_NEED_HDFS:-0}
export TF_NEED_OPENCL=${TF_NEED_OPENCL:-0}
export TF_NEED_OPENCL_SYCL=${TF_NEED_OPENCL_SYCL:-0}
export TF_NEED_TENSORRT=${TF_NEED_TENSORRT:-0}
export TF_NEED_NGRAPH=${TF_NEED_NGRAPH:-0}
export TF_NEED_JEMALLOC=${TF_NEED_JEMALLOC:-1}
export TF_NEED_VERBS=${TF_NEED_VERBS:-0}
export TF_NEED_MKL=${TF_NEED_MKL:-1}
export TF_DOWNLOAD_MKL=${TF_DOWNLOAD_MKL:-1}
export TF_NEED_MPI=${TF_NEED_MPI:-0}
export TF_ENABLE_XLA=${TF_ENABLE_XLA:-1}
export TF_NEED_AWS=${TF_NEED_AWS:-0}
export TF_NEED_GDR=${TF_NEED_GDR:-0}
export TF_CUDA_CLANG=${TF_CUDA_CLANG:-0}
export TF_SET_ANDROID_WORKSPACE=${TF_SET_ANDROID_WORKSPACE:-0}
export TF_NEED_KAFKA=${TF_NEED_KAFKA:-0}
export TF_DOWNLOAD_CLANG=${TF_DOWNLOAD_CLANG:-0}
export TF_NEED_IGNITE=${TF_NEED_IGNITE:-0}
export TF_NEED_ROCM=${TF_NEED_ROCM:-0}
export TF_NCCL_VERSION=${TF_NCCL_VERSION:-2.3}  # _DEFAULT_NCCL_VERSION from configure.py
export NCCL_INSTALL_PATH=${NCCL_INSTALL_PATH:-${CUDA_TOOLKIT_PATH}}
export PYTHON_BIN_PATH=${PYTHON_BIN_PATH:-"$(which python3)"}
export PYTHON_LIB_PATH="$($PYTHON_BIN_PATH -c 'import site; print(site.getsitepackages()[0])')"
export CUDNN_INSTALL_PATH=$CUDA_TOOLKIT_PATH

if [ -n "${CUDA_TOOLKIT_PATH}" ]; then
    if [[ -z "${CUDNN_INSTALL_PATH}" ]]; then
        echo "CUDA found but no cudnn.h found. Please install cuDNN."
        exit 1
    fi
    echo "CUDA support enabled"
    cuda_config_opts="--config=cuda"
    export TF_NEED_CUDA=1
    export TF_CUDA_COMPUTE_CAPABILITIES=${TF_CUDA_COMPUTE_CAPABILITIES:-"3.5,7.0"}  # default from configure.py
    export TF_CUDA_VERSION="$($CUDA_TOOLKIT_PATH/bin/nvcc --version | sed -n 's/^.*release \(.*\),.*/\1/p')"
    export TF_CUDNN_VERSION="$(sed -n 's/^#define CUDNN_MAJOR\s*\(.*\).*/\1/p' $CUDNN_INSTALL_PATH/include/cudnn.h)"

    # choose the right version of CUDA compiler
    if [ -z "$GCC_HOST_COMPILER_PATH" ]; then
        export GCC_HOST_COMPILER_PATH=${GCC_HOST_COMPILER_PATH:-"/usr/bin/gcc-8"}
    fi

    export CLANG_CUDA_COMPILER_PATH=${CLANG_CUDA_COMPILER_PATH:-"/usr/bin/clang"}
    export TF_CUDA_CLANG=${TF_CUDA_CLANG:-0}
else
    echo "CUDA support disabled"
    cuda_config_opts=""
    export TF_NEED_CUDA=0
fi

# configure and build
./configure

bazel build --config=opt \
    --config=monolithic \
    $cuda_config_opts \
    tensorflow:libtensorflow_cc.so

bazel build --config=opt \
    --config=monolithic \
    $cuda_config_opts \
    //tensorflow:libtensorflow.so

# Python API
bazel build --config=opt \
    --config=monolithic \
    $cuda_config_opts \
    //tensorflow/tools/pip_package:build_pip_package

bazel shutdown
