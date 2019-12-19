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

    EXTRACT_DIR=$PACKAGES/system76-cuda-${CUDA_VERSION}
    SCRIPT=$EXTRACT_DIR/installer-${CUDA_VERSION}
    CUDA_DIR=cuda-${CUDA_VERSION}

    if test "$3" = "v2"; then
        INSTALLER_SUM=$4
        PATCHES=$5
        REMOTE_CUDA_DIR=http://developer.download.nvidia.com/compute/cuda/${CUDA_VERSION}/Prod
        INSTALLER_URL=${REMOTE_CUDA_DIR}/local_installers/${INSTALLER}
    else
        INSTALLER_SUM=$3
        PATCHES=$4
        REMOTE_CUDA_DIR=https://developer.nvidia.com/compute/cuda/${CUDA_VERSION}/Prod
        INSTALLER_URL=$REMOTE_CUDA_DIR/local_installers/$INSTALLER
    fi

    mkdir $EXTRACT_DIR -p
    fetch_patches $REMOTE_CUDA_DIR ${CUDA_VERSION} $PATCHES
    fetch $SCRIPT $INSTALLER_URL $INSTALLER_SUM
    chmod +x $SCRIPT
}

get_cudnn () {
    fetch "$PACKAGES/system76-cudnn-$1/cudnn.tgz" \
        "http://developer.download.nvidia.com/compute/redist/cudnn/v$2/cudnn-$1-linux-x64-v$3.tgz" $4
}

get_cudnn "9.0" "7.6.5" "7.6.5.32" "60b581d0f05324c33323024a264aa3fb185c533e2f67dae7fda847b926bb7e57"
get_cudnn "9.2" "7.6.5" "7.6.5.32" "a850d62f32c6a18271932d9a96072ac757c2c516bd1200ae8b79e4bdd3800b5b"
get_cudnn "10.0" "7.6.5" "7.6.5.32" "b320606f1840eec0cdd4453cb333554a3fe496dd4785f10d8e87fe1a4f52bd5c"
get_cudnn "10.1" "7.6.5" "7.6.5.32" "c31697d6b71afe62838ad2e57da3c3c9419c4e9f5635d14b683ebe63f904fbc8"
get_cudnn "10.2" "7.6.5" "7.6.5.32" "600267f2caaed2fd58eb214ba669d8ea35f396a7d19b94822e6b36f9f7088c20"

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

get_toolkit 10.1 \
    cuda_10.1.105_418.39_linux.run \
    "33ac60685a3e29538db5094259ea85c15906cbd0f74368733f4111eab6187c8f"

get_toolkit 10.2 \
    cuda_10.2.89_440.33.01_linux.run \
    "v2" \
    "560d07fdcf4a46717f2242948cd4f92c5f9b6fc7eae10dd996614da913d5ca11" \
