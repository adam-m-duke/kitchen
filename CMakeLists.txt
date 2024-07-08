cmake_minimum_required(VERSION 3.28)

project(kitchen)

find_package(Boost 1.83.0 REQUIRED)     # Boost
find_package(absl 20240116 REQUIRED)    # Google Abseil
find_package(benchmark 1.8.3 REQUIRED)  # Google Benchmark
find_package(hwy 1.2.0 REQUIRED)        # Google Highway
find_package(GTest 1.14.0 REQUIRED)     # Google Test

add_subdirectory(src)