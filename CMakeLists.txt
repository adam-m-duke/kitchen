cmake_minimum_required(VERSION 3.28)

project(kitchen)

find_package(absl 20240116 REQUIRED)        # Abseil (Google)
find_package(benchmark 1.8.3 REQUIRED)      # Benchmark (Google)
find_package(Boost 1.83.0 REQUIRED)         # Boost
find_package(Eigen3 3.4.0 REQUIRED CONFIG)  # Eigen (TuxFamily)
find_package(flatbuffers 24.3.5)            # Flat Buffers (Google)
find_package(hwy 1.2.0 REQUIRED)            # Highway (Google)
find_package(GTest 1.14.0 REQUIRED)         # Test (Google)
find_package(protobuf 27.2.0 REQUIRED)      # Protocol Buffers (Google)

add_subdirectory(src)
