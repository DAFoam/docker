# OpenFOAM 2506 on Ubuntu 24.04
# Minimal packages with compilation ability preserved
# SINGLE LAYER BUILD - optimized for smallest size

FROM ubuntu:24.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive
# Set OpenFOAM version and install directory
ENV FOAM_VERSION=2506
ENV FOAM_INST_DIR=/home/dockeruser/OpenFOAM

# Install minimal dependencies (build + runtime)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create dockeruser with password and sudo privileges
RUN useradd -m -s /bin/bash dockeruser && \
    echo "dockeruser:dockeruser" | chpasswd && \
    usermod -aG sudo dockeruser

# Switch to dockeruser
USER dockeruser

# Download, extract, compile, and clean in ONE layer
RUN mkdir -p ${FOAM_INST_DIR} && mkdir -p /home/dockeruser/mount && \
    cd ${FOAM_INST_DIR} && \
    wget -q https://dl.openfoam.com/source/v${FOAM_VERSION}/OpenFOAM-v${FOAM_VERSION}.tgz && \
    tar -xzf OpenFOAM-v${FOAM_VERSION}.tgz && \
    rm OpenFOAM-v${FOAM_VERSION}.tgz && \
    wget -q https://dl.openfoam.com/source/v${FOAM_VERSION}/ThirdParty-v${FOAM_VERSION}.tgz && \
    tar -xzf ThirdParty-v${FOAM_VERSION}.tgz && \
    rm ThirdParty-v${FOAM_VERSION}.tgz && \
    cd ${FOAM_INST_DIR}/OpenFOAM-v${FOAM_VERSION} && \
    echo "source ${FOAM_INST_DIR}/OpenFOAM-v${FOAM_VERSION}/etc/bashrc" >> /home/dockeruser/.bashrc && \
    /bin/bash -c "source etc/bashrc && export WM_QUIET=true && \
        cd ${FOAM_INST_DIR}/ThirdParty-v${FOAM_VERSION} && ./Allwmake -j -q && \
        cd ${FOAM_INST_DIR}/OpenFOAM-v${FOAM_VERSION} && ./Allwmake -j -q && \
        wclean all && rm -rf build && \
        rm -rf /home/dockeruser/.cache/*"

# Set working directory
WORKDIR /home/dockeruser

# Source OpenFOAM environment on container start
CMD ["/bin/bash"]
