################################################################################
add_library(saladbar INTERFACE)
add_library(kitchen::saladbar ALIAS saladbar)
target_link_libraries(saladbar INTERFACE
    absl::flat_hash_map
    benchmark::benchmark
    Boost::boost
    Eigen3::Eigen
    flatbuffers::flatbuffers
    GTest::gtest
    hwy::hwy
    protobuf::libprotobuf)
################################################################################
