#!/usr/bin/sh

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -G "Unix Makefiles" \
    -B cmake-build-release \
    "$@"
