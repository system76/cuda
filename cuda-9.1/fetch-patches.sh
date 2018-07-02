#!/bin/sh

set -ex

REMOTE_PATCH_DIR=$1/patches
CUDA_VERSION=$2

N=1;
for patch in $3; do
    REMOTE_PATCH=$REMOTE_PATCH_DIR/$(echo $patch | cut -d'=' -f1)
    CHECKSUM=$(echo $patch | cut -d'=' -f2)
    PATCH=patch-$CUDA_VERSION-$N.run
    N=$((N + 1))

    if [ ! -f $PATCH ] || [ $(md5sum $PATCH | cut -d' ' -f1) != $CHECKSUM ]; then
        wget $REMOTE_PATCH -O $PATCH;
        if [ $(md5sum $PATCH | cut -d' ' -f1) != $CHECKSUM ]; then
            echo patch checksum does not match
            exit 1
        fi
    fi
done
