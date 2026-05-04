# DAFoam base image - apt dependencies and user setup only
# OpenFOAM installation is performed separately via install.sh

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FOAM_INST_DIR=/home/dafoamuser/dafoam/OpenFOAM

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gfortran \
    ca-certificates \
    cmake \
    flex \
    bison \
    libfl-dev \
    libcgal-dev \
    libopenmpi-dev \
    openmpi-bin \
    libscotch-dev \
    libreadline-dev \
    libncurses-dev \
    sudo \
    wget \
    vim \
    git \
    lcov \
    libxrender1 \
    libxml2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash dafoamuser && \
    echo "dafoamuser:dafoamuser" | chpasswd && \
    usermod -aG sudo dafoamuser

USER dafoamuser
WORKDIR /home/dafoamuser
CMD ["/bin/bash"]