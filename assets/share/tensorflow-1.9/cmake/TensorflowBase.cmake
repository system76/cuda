cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
include(ExternalProject)

ExternalProject_Add(
  tensorflow_base
  GIT_REPOSITORY https://github.com/tensorflow/tensorflow.git
  GIT_TAG "${TENSORFLOW_TAG}"
  TMP_DIR "/tmp"
  STAMP_DIR "tensorflow-stamp"
  DOWNLOAD_DIR "tensorflow"
  SOURCE_DIR "tensorflow"
  BUILD_IN_SOURCE 1
  UPDATE_COMMAND ""
  CONFIGURE_COMMAND make -f tensorflow/contrib/makefile/Makefile clean
            # Fix github.com/tensorflow/tensorflow/issues/19840
            COMMAND cp "${CMAKE_CURRENT_SOURCE_DIR}/stream.patch" .
            COMMAND patch -p1 < stream.patch

            COMMAND tensorflow/contrib/makefile/download_dependencies.sh
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
)
