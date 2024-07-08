FROM ubuntu:24.04

################################################################################
# ENVIRONMENT

ENV DEBIAN_FRONTEND=noninteractive

ENV CC gcc-14
ENV CXX g++-14
ENV CXX_STANDARD 20
ENV CXX_STANDARD_REQUIRED ON

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

# Google Abseil
RUN git clone https://github.com/abseil/abseil-cpp \
    && cd abseil-cpp \
    && git checkout lts_2024_01_16 \
    && cmake \
        -DBUILD_TESTING=OFF \
        -DABSL_PROPAGATE_CXX_STD=ON \
        -B build \
    && cmake --build build --target install -j4 \
    && cd .. \
    && rm -rf abseil-cpp

# Google Highway
RUN git clone https://github.com/google/highway.git \
    && cd highway \
    && git checkout 1.2.0 \
    && cmake \
        -DBUILD_TESTING=OFF \
        -B build \
    && cmake --build build --target install -j4 \
    && cd .. \
    && rm -rf highway

################################################################################
# USER

ARG USERNAME=chef
RUN useradd $USERNAME -lm -G sudo -d /home/$USERNAME -s /bin/bash -p "$(openssl passwd -6 $USERNAME)"
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER $USERNAME
WORKDIR /home/$USERNAME
