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
export TF_NEED_JEMALLOC=${TF_NEED_JEMALLOC:-1}
export TF_NEED_VERBS=${TF_NEED_VERBS:-0}
export TF_NEED_MKL=${TF_NEED_MKL:-1}
export TF_DOWNLOAD_MKL=${TF_DOWNLOAD_MKL:-1}
export TF_NEED_MPI=${TF_NEED_MPI:-0}
export TF_ENABLE_XLA=${TF_ENABLE_XLA:-1}
export TF_NEED_S3=${TF_NEED_S3:-0}  # TODO: Remove when replaced by the next line.
export TF_NEED_AWS=${TF_NEED_AWS:-0}
export TF_NEED_GDR=${TF_NEED_GDR:-0}
export TF_CUDA_CLANG=${TF_CUDA_CLANG:-0}
export TF_SET_ANDROID_WORKSPACE=${TF_SET_ANDROID_WORKSPACE:-0}
export TF_NEED_KAFKA=${TF_NEED_KAFKA:-0}
export TF_DOWNLOAD_CLANG=${TF_DOWNLOAD_CLANG:-0}
export TF_NCCL_VERSION=${TF_NCCL_VERSION:-1.3}  # _DEFAULT_NCCL_VERSION from configure.py
export PYTHON_BIN_PATH=${PYTHON_BIN_PATH:-"$(which python3)"}
export PYTHON_LIB_PATH="$($PYTHON_BIN_PATH -c 'import site; print(site.getsitepackages()[0])')"

echo "CUDA support disabled"
cuda_config_opts=""
export TF_NEED_CUDA=0

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
