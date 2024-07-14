################################################################################
add_library(saladbar INTERFACE)
add_library(kitchen::saladbar ALIAS saladbar)
target_link_libraries(saladbar INTERFACE
    absl::flat_hash_map
    Arrow::arrow_shared  # Arrow::arrow_static
    benchmark::benchmark
    Boost::boost
    Eigen3::Eigen
    flatbuffers::flatbuffers
    GTest::gtest
    hwy::hwy
    Parquet::parquet_shared  # Parquet::parquet_static
    protobuf::libprotobuf  # protobuf::libprotobuf-lite
)
################################################################################
