#!/usr/bin/env bash

set -ex

PACKAGES="assets/packages"

function fetch {
    echo LOCATION = $1
    echo URL = $2
    echo CHECKSUM = $3

    mkdir $(dirname $1) -p
    CHECKSUM=$(md5sum $1 | cut -d' ' -f1)
    if [ ! $CHECKSUM ] || [ $CHECKSUM != $3 ]; then
        wget $2 -O $1
        if [ $(md5sum $1 | cut -d' ' -f1) != $3 ]; then
            echo checksum does not match
            exit 1;
        fi
    fi
}

function fetch_patches {
    REMOTE_PATCH_DIR=$1/patches
    CUDA_VERSION=$2

    N=1;
    for patch in $3; do
        REMOTE_PATCH=$REMOTE_PATCH_DIR/$(echo $patch | cut -d'=' -f1)
        CHECKSUM=$(echo $patch | cut -d'=' -f2)
        PATCH=$EXTRACT_DIR/patch-$CUDA_VERSION-$N.run
        N=$((N + 1))

        fetch $PATCH $REMOTE_PATCH $CHECKSUM
        chmod +x $PATCH
    done
}

function get_toolkit {
    CUDA_VERSION=$1
    INSTALLER=$2
    INSTALLER_SUM=$3
    PATCHES=$4

    EXTRACT_DIR=$PACKAGES/system76-cuda-$CUDA_VERSION
    SCRIPT=$EXTRACT_DIR/installer-$CUDA_VERSION
    REMOTE_CUDA_DIR=https://developer.nvidia.com/compute/cuda/$CUDA_VERSION/Prod
    INSTALLER_URL=$REMOTE_CUDA_DIR/local_installers/$INSTALLER
    CUDA_DIR=cuda-$CUDA_VERSION

    mkdir $EXTRACT_DIR -p
    fetch_patches $REMOTE_CUDA_DIR $CUDA_VERSION $PATCHES
    fetch $SCRIPT $INSTALLER_URL $INSTALLER_SUM
    chmod +x $SCRIPT
}

CUDNN_9_0="$PACKAGES/system76-cudnn-9.0/cudnn.tgz"
CUDNN_9_0_URL="http://developer.download.nvidia.com/compute/redist/cudnn/v7.1.4/cudnn-9.0-linux-x64-v7.1.tgz"
CUDNN_9_0_SUM="b29fd0cf7faf7b1b44acc4edeef6b802"

CUDNN_9_2="$PACKAGES/system76-cudnn-9.2/cudnn.tgz"
CUDNN_9_2_URL="http://developer.download.nvidia.com/compute/redist/cudnn/v7.1.4/cudnn-9.2-linux-x64-v7.1.tgz"
CUDNN_9_2_SUM="814fe34f2963948d4ee236a34792f872"

fetch $CUDNN_9_0 $CUDNN_9_0_URL $CUDNN_9_0_SUM
fetch $CUDNN_9_2 $CUDNN_9_2_URL $CUDNN_9_2_SUM

get_toolkit 9.0 \
    cuda_9.0.176_384.81_linux-run \
    7a00187b2ce5c5e350e68882f42dd507 \
    "/1/cuda_9.0.176.1_linux-run=8477e5733c8250dd3e110ee127002b9c \
        /2/cuda_9.0.176.2_linux-run=4d3113ffd68a4c67511ca66e497badba \
        /3/cuda_9.0.176.3_linux-run=0d7d07dc3084e0f0ce7d861b5a642f19"

get_toolkit 9.1 \
    cuda_9.1.85_387.26_linux \
    67a5c3933109507df6b68f80650b4b4a \
    "/1/cuda_9.1.85.1_linux=2babebcbdf656000ebba30ee2efa4ad3 \
        /2/cuda_9.1.85.2_linux=b991d63601b32540c445f6df52e1648d \
        /3/cuda_9.1.85.3_linux=dcdb6c0adb5457fcf43cb520995a3112"

get_toolkit 9.2 \
    cuda_9.2.88_396.26_linux \
    dd6e33e10d32a29914b7700c7b3d1ca0 \
    "/1/cuda_9.2.88.1_linux=0e615d99152b9dfce5da20dfece6b7ea"
