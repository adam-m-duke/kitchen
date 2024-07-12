FROM ubuntu:24.04 AS base

################################################################################
# ENVIRONMENT

ENV DEBIAN_FRONTEND=noninteractive

ENV CC gcc-14
ENV CXX g++-14
ENV CXX_STANDARD 20
ENV CXX_STANDARD_REQUIRED ON

ARG HOME=/root
WORKDIR $HOME

################################################################################
# SYSTEM PACKAGES

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

################################################################################
# DEV PACKAGES

RUN apt install -yq \
    libgtest-dev \
    libgmock-dev\
    libbenchmark-dev \
    libboost-dev \
    libspdlog-dev

RUN apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

################################################################################
# DEV PACKAGES (FROM SOURCE)

FROM base AS stage-abseil
RUN git clone --depth 1 --branch lts_2024_01_16 https://github.com/abseil/abseil-cpp.git abseil \
    && cd abseil \
    && cmake -DCMAKE_INSTALL_PREFIX=/pantry/absl -DBUILD_TESTING=OFF -DABSL_PROPAGATE_CXX_STD=ON -B build \
    && cmake --build build --config Release --target install -j4 \
    && cd ..

FROM base AS stage-eigen
RUN git clone --depth 1 --branch 3.4.0 https://gitlab.com/libeigen/eigen.git eigen \
    && cd eigen \
    && cmake -DCMAKE_INSTALL_PREFIX=/pantry/eigen -DBUILD_TESTING=OFF -B build \
    && cmake --build build --config Release --target install -j2 \
    && cd ..

FROM base AS stage-flatbuffers
RUN git clone --depth 1 --branch v24.3.25 https://github.com/google/flatbuffers.git flatbuffers \
    && cd flatbuffers \
    && cmake -DCMAKE_INSTALL_PREFIX=/pantry/flatbuffers -B build \
    && cmake --build build --config Release --target install -j4 \
    && cd ..

FROM base AS stage-highway
RUN git clone --depth 1 --branch 1.2.0 https://github.com/google/highway.git highway \
    && cd highway \
    && cmake -DCMAKE_INSTALL_PREFIX=/pantry/hwy -DBUILD_TESTING=OFF -B build \
    && cmake --build build --config Release --target install -j8 \
    && cd ..

FROM stage-abseil as stage-protobuf
RUN git clone --depth 1 --branch v27.2 https://github.com/protocolbuffers/protobuf.git \
    && cd protobuf \
    && cmake -DCMAKE_INSTALL_PREFIX=/pantry/protobuf -Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_ABSL_PROVIDER=package -DCMAKE_PREFIX_PATH=/pantry/absl -B build \ 
    && cmake --build build --config Release --target install -j8 \
    && cd ..

################################################################################
# FINAL

FROM base AS kitchen

COPY --from=stage-abseil       /pantry/absl         /pantry/absl
COPY --from=stage-eigen        /pantry/eigen        /pantry/eigen
COPY --from=stage-flatbuffers  /pantry/flatbuffers  /pantry/flatbuffers
COPY --from=stage-highway      /pantry/hwy          /pantry/hwy
COPY --from=stage-protobuf     /pantry/protobuf     /pantry/protobuf

# CMake Config Paths
ENV absl_ROOT="/pantry/absl/lib/cmake" \
    Eigen3_DIR="/pantry/eigen/share/eigen3/cmake" \
    flatbuffers_ROOT="/pantry/flatbuffers/lib/cmake/flatbuffers" \
    hwy_ROOT="/pantry/hwy/lib/cmake/hwy" \
    utf8_range_ROOT="/pantry/protobuf/lib/cmake/utf8_range" \
    protobuf_ROOT="/pantry/protobuf/lib/cmake/protobuf" \
    PATH="$PATH:/pantry/flatbuffers/bin:/pantry/protobuf/bin"

ARG USERNAME=chef
RUN useradd $USERNAME -lm -G sudo -d /home/$USERNAME -s /bin/bash -p "$(openssl passwd -6 $USERNAME)"
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER $USERNAME
WORKDIR /home/$USERNAME
