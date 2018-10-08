#!/usr/bin/env bash

set -ex

PACKAGES="assets/packages"

function fetch {
    echo LOCATION = $1
    echo URL = $2
    echo CHECKSUM = $3

    mkdir $(dirname $1) -p
    CHECKSUM=$(sha256sum $1 | cut -d' ' -f1)
    if [ ! $CHECKSUM ] || [ $CHECKSUM != $3 ]; then
        wget $2 -O $1
        if [ $(sha256sum $1 | cut -d' ' -f1) != $3 ]; then
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
CUDNN_9_0_SUM="60b581d0f05324c33323024a264aa3fb185c533e2f67dae7fda847b926bb7e57"

CUDNN_9_1="$PACKAGES/system76-cudnn-9.1/cudnn.tgz"
CUDNN_9_1_URL="http://developer.download.nvidia.com/compute/redist/cudnn/v7.1.2/cudnn-9.1-linux-x64-v7.1.tgz"
CUDNN_9_1_SUM="c61000ed700bc5a009bc2e135bbdf736c9743212b2174a2fc9018a66cc0979ec"

CUDNN_9_2="$PACKAGES/system76-cudnn-9.2/cudnn.tgz"
CUDNN_9_2_URL="http://developer.download.nvidia.com/compute/redist/cudnn/v7.1.4/cudnn-9.2-linux-x64-v7.1.tgz"
CUDNN_9_2_SUM="f875340f812b942408098e4c9807cb4f8bdaea0db7c48613acece10c7c827101"

CUDNN_10_0="$PACKAGES/system76-cudnn-10.0/cudnn.tgz"
CUDNN_10_0_URL="http://developer.download.nvidia.com/compute/redist/cudnn/v7.3.1/cudnn-10.0-linux-x64-v7.3.1.20.tgz"
CUDNN_10_0_SUM="4e15a323f2edffa928b4574f696fc0e449a32e6bc35c9ccb03a47af26c2de3fa"

fetch $CUDNN_9_0 $CUDNN_9_0_URL $CUDNN_9_0_SUM
fetch $CUDNN_9_1 $CUDNN_9_1_URL $CUDNN_9_1_SUM
fetch $CUDNN_9_2 $CUDNN_9_2_URL $CUDNN_9_2_SUM
fetch $CUDNN_10_0 $CUDNN_10_0_URL $CUDNN_10_0_SUM

get_toolkit 9.0 \
    cuda_9.0.176_384.81_linux-run \
    "96863423feaa50b5c1c5e1b9ec537ef7ba77576a3986652351ae43e66bcd080c" \
    "/1/cuda_9.0.176.1_linux-run=a4bf63e08f01fcbdfa9ff147f54e45a84a3a70e571b28d2d62e9277c4f7a78ed \
        /2/cuda_9.0.176.2_linux-run=ec345f6d17d52c0ab6ea296ec389efdabca2ca56bddde8723bcea7be646ce5eb \
        /3/cuda_9.0.176.3_linux-run=429e2c30da8021ec10f047ce475bc628832a5f93110f5cf487f2327dfb1aa8ca"

get_toolkit 9.1 \
    cuda_9.1.85_387.26_linux \
    "8496c72b16fee61889f9281449b5d633d0b358b46579175c275d85c9205fe953" \
    "/1/cuda_9.1.85.1_linux=af9ce3d7ce4ea3b9b075135640077695f420d5dc585d76cbdae09d658b8ca3b8 \
        /2/cuda_9.1.85.2_linux=d59f07a35ba750fc8ab04e144e7556d03b57a4f1a0060f895615af0113e0e099 \
        /3/cuda_9.1.85.3_linux=421094368e4732677e5963d790fa161be2586ed90b291988477f8c8f9cd9ac8a"

get_toolkit 9.2 \
    cuda_9.2.88_396.26_linux \
    "8d02cc2a82f35b456d447df463148ac4cc823891be8820948109ad6186f2667c" \
    "/1/cuda_9.2.88.1_linux=d2f2d0e91959e4b9a93cd2fa82dced3541e3b8046c3ab7ae335d36f71dbbca13"

get_toolkit 10.0 \
    cuda_10.0.130_410.48_linux \
    "92351f0e4346694d0fcb4ea1539856c9eb82060c25654463bfd8574ec35ee39a"