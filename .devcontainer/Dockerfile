FROM ubuntu:24.04 AS base

################################################################################
# ENVIRONMENT

ENV DEBIAN_FRONTEND=noninteractive
ENV INSTALL_ROOT="/install"

ENV CC gcc-14
ENV CXX g++-14
ENV CXX_STANDARD 20
ENV CXX_STANDARD_REQUIRED ON

ARG HOME=/root
WORKDIR $HOME

################################################################################
# PACKAGES

# System
RUN apt update \
    && apt install -yq \
        sudo \
        curl \
        wget \
        git \
        bash-completion \
        openssl \
        ${CC} \
        ${CXX} \
        gdb \
        cmake

# Dev
RUN apt install -yq \
        libbenchmark-dev \
        libboost-dev \
        libgtest-dev \
        libgmock-dev\
        libspdlog-dev \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

################################################################################
# DEV PACKAGES (FROM SOURCE)

FROM base AS stage-abseil
RUN cd $HOME \
    && git clone --depth 1 --branch lts_2024_01_16 https://github.com/abseil/abseil-cpp.git abseil \
    && cd abseil \
    && cmake \
        -B build \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT}/absl \
        -DBUILD_TESTING=OFF \
        -DABSL_PROPAGATE_CXX_STD=ON \
    && cmake --build build --config Release --target install -j4

FROM base AS stage-eigen
RUN cd $HOME \
    && git clone --depth 1 --branch 3.4.0 https://gitlab.com/libeigen/eigen.git eigen \
    && cd eigen \
    && cmake \
        -B build \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT}/eigen \
        -DBUILD_TESTING=OFF \
    && cmake --build build --config Release --target install -j2

FROM base AS stage-flatbuffers
RUN cd $HOME \
    && git clone --depth 1 --branch v24.3.25 https://github.com/google/flatbuffers.git flatbuffers \
    && cd flatbuffers \
    && cmake \
        -B build \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT}/flatbuffers \
    && cmake --build build --config Release --target install -j4

FROM base AS stage-highway
RUN cd $HOME \
    && git clone --depth 1 --branch 1.2.0 https://github.com/google/highway.git highway \
    && cd highway \
    && cmake \
        -B build \    
        -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT}/hwy \
        -DBUILD_TESTING=OFF \
    && cmake --build build --config Release --target install -j8

FROM base AS stage-protobuf
COPY --from=stage-abseil  ${INSTALL_ROOT}/absl  ${INSTALL_ROOT}/absl
RUN cd $HOME \ 
    && git clone --depth 1 --branch v27.2 https://github.com/protocolbuffers/protobuf.git \
    && cd protobuf \
    && cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT}/protobuf \
        -B build \
        -Dprotobuf_BUILD_TESTS=OFF \
        -Dprotobuf_ABSL_PROVIDER=package \
        -DCMAKE_PREFIX_PATH=${INSTALL_ROOT}/absl \ 
    && cmake --build build --config Release --target install -j8

FROM base AS stage-arrow
COPY --from=stage-protobuf  ${INSTALL_ROOT}/protobuf  ${INSTALL_ROOT}/protobuf
RUN git clone --depth 1 --recurse-submodules --branch r-16.1.0 https://github.com/apache/arrow.git \
    && cd arrow \ 
    && cmake \
        -B cpp/build -S cpp \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT}/arrow \
        -DARROW_BUILD_STATIC=ON \
        -DARROW_BUILD_TESTS=OFF \
        -DARROW_PARQUET=ON \
        -DARROW_WITH_LZ4=ON \
        -DARROW_WITH_SNAPPY=ON \
        -DARROW_WITH_ZLIB=ON \
        -DARROW_WITH_ZSTD=ON \
        -DARROW_DEPENDENCY_SOURCE=AUTO \
        -DProtobuf_SOURCE=${INSTALL_ROOT}/protobuf \
    && cmake --build cpp/build --config Release --target install -j8

################################################################################
# FINAL

FROM base AS kitchen
ENV PANTRY="/pantry"

COPY --from=stage-abseil       ${INSTALL_ROOT}/absl         ${PANTRY}/absl
COPY --from=stage-eigen        ${INSTALL_ROOT}/eigen        ${PANTRY}/eigen
COPY --from=stage-flatbuffers  ${INSTALL_ROOT}/flatbuffers  ${PANTRY}/flatbuffers
COPY --from=stage-highway      ${INSTALL_ROOT}/hwy          ${PANTRY}/hwy
COPY --from=stage-protobuf     ${INSTALL_ROOT}/protobuf     ${PANTRY}/protobuf
COPY --from=stage-arrow        ${INSTALL_ROOT}/arrow        ${PANTRY}/arrow

# protoc, flatc
ENV PATH="$PATH:${INSTALL_ROOT}/flatbuffers/bin:${INSTALL_ROOT}/protobuf/bin"

ARG USERNAME=chef
RUN useradd $USERNAME -lm -G sudo -d /home/$USERNAME -s /bin/bash -p "$(openssl passwd -6 $USERNAME)"
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER $USERNAME
WORKDIR /home/$USERNAME
