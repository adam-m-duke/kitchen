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
    && cmake -DBUILD_TESTING=OFF -DABSL_PROPAGATE_CXX_STD=ON -B build \
    && cmake --build build --config Release -j2 \
    && cd ..

FROM base AS stage-eigen
RUN git clone --depth 1 --branch 3.4.0 https://gitlab.com/libeigen/eigen.git eigen \
    && cd eigen \
    && cmake -DBUILD_TESTING=OFF -B build \
    && cmake --build build --config Release -j2 \
    && cd ..

FROM base AS stage-flatbuffers
RUN git clone --depth 1 --branch v24.3.25 https://github.com/google/flatbuffers.git flatbuffers \
    && cd flatbuffers \
    && cmake -B build \
    && cmake --build build --config Release -j2 \
    && cd ..

FROM base AS stage-highway
RUN git clone --depth 1 --branch 1.2.0 https://github.com/google/highway.git highway \
    && cd highway \
    && cmake -DBUILD_TESTING=OFF -B build \
    && cmake --build build --config Release -j2 \
    && cd ..

################################################################################
# FINAL

FROM base AS kitchen

COPY --from=stage-abseil $HOME/abseil abseil
COPY --from=stage-eigen $HOME/eigen eigen
COPY --from=stage-flatbuffers $HOME/flatbuffers flatbuffers
COPY --from=stage-highway $HOME/highway highway

RUN    cmake --install abseil/build \
    && cmake --install eigen/build \
    && cmake --install flatbuffers/build \
    && cmake --install highway/build \
    && rm -rf ./*

ARG USERNAME=chef
RUN useradd $USERNAME -lm -G sudo -d /home/$USERNAME -s /bin/bash -p "$(openssl passwd -6 $USERNAME)"
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER $USERNAME
WORKDIR /home/$USERNAME
