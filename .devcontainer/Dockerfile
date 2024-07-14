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
        libgtest-dev \
        libgmock-dev\
        libbenchmark-dev \
        libboost-dev \
        libspdlog-dev \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

################################################################################
# DEV PACKAGES (FROM SOURCE)

FROM base AS stage-abseil
ARG INSTALL_ROOT
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
ARG INSTALL_ROOT
RUN cd $HOME \
    && git clone --depth 1 --branch 3.4.0 https://gitlab.com/libeigen/eigen.git eigen \
    && cd eigen \
    && cmake \
        -B build \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT}/eigen \
        -DBUILD_TESTING=OFF \
    && cmake --build build --config Release --target install -j2

FROM base AS stage-flatbuffers
ARG INSTALL_ROOT
RUN cd $HOME \
    && git clone --depth 1 --branch v24.3.25 https://github.com/google/flatbuffers.git flatbuffers \
    && cd flatbuffers \
    && cmake \
        -B build \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT}/flatbuffers \
    && cmake --build build --config Release --target install -j4

FROM base AS stage-highway
ARG INSTALL_ROOT
RUN cd $HOME \
    && git clone --depth 1 --branch 1.2.0 https://github.com/google/highway.git highway \
    && cd highway \
    && cmake \
        -B build \    
        -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT}/hwy \
        -DBUILD_TESTING=OFF \
    && cmake --build build --config Release --target install -j8

FROM stage-abseil as stage-protobuf
ARG INSTALL_ROOT
RUN cd $HOME \ 
    && git clone --depth 1 --branch v27.2 https://github.com/protocolbuffers/protobuf.git \
    && cd protobuf \
    && cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT}/protobuf \
        -B build \
        -Dprotobuf_BUILD_TESTS=OFF \
        -Dprotobuf_ABSL_PROVIDER=package \
        -DCMAKE_PREFIX_PATH=${INSTALL_ROOT}/absl \ 
    && cmake --build build --config Release --target install -j8

# FROM base as stage-arrow
# ARG INSTALL_ROOT
# RUN git clone --depth 1 --branch r-16.1.0 https://github.com/apache/arrow.git \
#     && cd arrow \ 
#     && cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT}/arrow -B cpp/build -S cpp \
#     && cmake --build cpp/build --config Release --target install -j4 \

################################################################################
# FINAL

FROM base AS kitchen
ARG INSTALL_ROOT

COPY --from=stage-abseil       ${INSTALL_ROOT}/absl         ${INSTALL_ROOT}/absl
COPY --from=stage-eigen        ${INSTALL_ROOT}/eigen        ${INSTALL_ROOT}/eigen
COPY --from=stage-flatbuffers  ${INSTALL_ROOT}/flatbuffers  ${INSTALL_ROOT}/flatbuffers
COPY --from=stage-highway      ${INSTALL_ROOT}/hwy          ${INSTALL_ROOT}/hwy
COPY --from=stage-protobuf     ${INSTALL_ROOT}/protobuf     ${INSTALL_ROOT}/protobuf

# protoc, flatc
ENV PATH="$PATH:${INSTALL_ROOT}/flatbuffers/bin:${INSTALL_ROOT}/protobuf/bin"

ARG USERNAME=chef
RUN useradd $USERNAME -lm -G sudo -d /home/$USERNAME -s /bin/bash -p "$(openssl passwd -6 $USERNAME)"
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER $USERNAME
WORKDIR /home/$USERNAME
