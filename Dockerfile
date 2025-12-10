# OpenFOAM 2506 on Ubuntu 24.04
# Minimal packages with compilation ability preserved

FROM ubuntu:24.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies (build + runtime)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    flex \
    libopenmpi-dev \
    openmpi-bin \
    sudo \
    wget \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Create dockeruser with password and sudo privileges
RUN useradd -m -s /bin/bash dockeruser && \
    echo "dockeruser:dockeruser123" | chpasswd && \
    usermod -aG sudo dockeruser

# Set OpenFOAM version and install directory
ENV FOAM_VERSION=2506
ENV FOAM_INST_DIR=/home/dockeruser/OpenFOAM

# Switch to dockeruser and create installation directory
USER dockeruser
RUN mkdir -p ${FOAM_INST_DIR} && mkdir -p /home/dockeruser/mount

# Download and extract OpenFOAM
WORKDIR ${FOAM_INST_DIR}
RUN wget -q https://dl.openfoam.com/source/v${FOAM_VERSION}/OpenFOAM-v${FOAM_VERSION}.tgz && \
    tar -xzf OpenFOAM-v${FOAM_VERSION}.tgz && \
    rm OpenFOAM-v${FOAM_VERSION}.tgz

# Download and extract ThirdParty
RUN wget -q https://dl.openfoam.com/source/v${FOAM_VERSION}/ThirdParty-v${FOAM_VERSION}.tgz && \
    tar -xzf ThirdParty-v${FOAM_VERSION}.tgz && \
    rm ThirdParty-v${FOAM_VERSION}.tgz

# Set up environment
WORKDIR ${FOAM_INST_DIR}/OpenFOAM-v${FOAM_VERSION}
RUN echo "source ${FOAM_INST_DIR}/OpenFOAM-v${FOAM_VERSION}/etc/bashrc" >> /home/dockeruser/.bashrc

# Compile OpenFOAM (parallel build)
WORKDIR ${FOAM_INST_DIR}/OpenFOAM-v${FOAM_VERSION}
RUN /bin/bash -c "source etc/bashrc && export WM_QUIET=true && ./Allwmake -j -s -q -l"

# Clean intermediate build files but keep source and compilation tools
RUN /bin/bash -c "source etc/bashrc && wclean all" && \
    find ${FOAM_INST_DIR} -type f -name "*.o" -delete && \
    find ${FOAM_INST_DIR} -type f -name "*.dep" -delete && \
    rm -rf /home/dockeruser/.cache/*

# Set working directory
WORKDIR /home/dockeruser

# Source OpenFOAM environment on container start
CMD ["/bin/bash"]
