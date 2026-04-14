# OpenFOAM v1812 on Ubuntu 24.04
# Minimal packages with compilation ability preserved
# SINGLE LAYER BUILD - optimized for smallest size

FROM ubuntu:24.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive
# Set OpenFOAM version and install directory
ENV FOAM_INST_DIR=/home/dafoamuser/dafoam/OpenFOAM

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

# Create dafoamuser with password and sudo privileges
RUN useradd -m -s /bin/bash dafoamuser && \
    echo "dafoamuser:dafoamuser" | chpasswd && \
    usermod -aG sudo dafoamuser

# Switch to dafoamuser
USER dafoamuser

# Download, extract, compile, and clean in ONE layer
RUN mkdir -p /home/dafoamuser/dafoam && mkdir -p ${FOAM_INST_DIR} && mkdir -p /home/dafoamuser/mount && \
    echo "source ${FOAM_INST_DIR}/OpenFOAM-v1812/etc/bashrc" >> /home/dafoamuser/.bashrc && \
    cd ${FOAM_INST_DIR} && \
    wget https://sourceforge.net/projects/openfoam/files/v1812/OpenFOAM-v1812.tgz/download -O OpenFOAM-v1812.tgz && \
    wget https://sourceforge.net/projects/openfoam/files/v1812/ThirdParty-v1812.tgz/download -O ThirdParty-v1812.tgz && \
    tar -xvf OpenFOAM-v1812.tgz && \
    tar -xvf ThirdParty-v1812.tgz && \
    rm -rf OpenFOAM-v1812.tgz ThirdParty-v1812.tgz && \
    cd ${FOAM_INST_DIR}/OpenFOAM-v1812 && \
    wget https://github.com/DAFoam/files/releases/download/v1.0.0/OpenFOAM-v1812-patch-files.tar.gz && \
    tar -xvf OpenFOAM-v1812-patch-files.tar.gz && \
    cd OpenFOAM-v1812-patch-files && \
    ./runPatch.sh && \
    cd .. && \
    /bin/bash -c "source etc/bashrc && export WM_QUIET=true && \
        cd ${FOAM_INST_DIR}/OpenFOAM-v1812 && ./Allwmake -j -q && \
        wclean all && rm -rf build && \
        rm -rf /home/dafoamuser/.cache/*"

# Set working directory
WORKDIR /home/dafoamuser/mount

# Source OpenFOAM environment on container start
CMD ["/bin/bash"]
