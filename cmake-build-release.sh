#!/usr/bin/sh

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -B cmake-build-release \
    "$@"