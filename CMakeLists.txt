cmake_minimum_required(VERSION 3.28)
################################################################################
project(kitchen)

include(GNUInstallDirs)
get_property(existingTargets DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY IMPORTED_TARGETS)

find_package(absl         20240116  REQUIRED CONFIG)
find_package(benchmark    1.8.3     REQUIRED)
find_package(Boost        1.83.0    REQUIRED)
find_package(Eigen3       3.4.0     REQUIRED CONFIG)
find_package(flatbuffers  24.3.5    REQUIRED CONFIG)
find_package(GTest        1.14.0    REQUIRED)
find_package(hwy          1.2.0     REQUIRED CONFIG)
find_package(protobuf     27.2.0    REQUIRED CONFIG)

get_property(importedTargets DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY IMPORTED_TARGETS)
list(REMOVE_ITEM importedTargets ${existingTargets})
message(DEBUG "${importedTargets}")
################################################################################
add_subdirectory(src)
################################################################################
