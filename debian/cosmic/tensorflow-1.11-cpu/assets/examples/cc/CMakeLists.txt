cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
list(APPEND CMAKE_PREFIX_PATH "/usr/lib/tensorflow/lib/cmake")

find_package(TensorflowCC COMPONENTS Shared)
find_package(CUDA)

add_executable(example example.cpp)

target_link_libraries(example TensorflowCC::Shared)

if(CUDA_FOUND)
  target_link_libraries(example ${CUDA_LIBRARIES})
endif()