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
RUN wget -q https://gitlab.com/openfoam/openfoam/-/archive/OpenFOAM-v${FOAM_VERSION}/openfoam-OpenFOAM-v${FOAM_VERSION}.tar.gz && \
    tar -xzf openfoam-OpenFOAM-v${FOAM_VERSION}.tar.gz && \
    mv openfoam-OpenFOAM-v${FOAM_VERSION} OpenFOAM-v${FOAM_VERSION} && \
    rm openfoam-OpenFOAM-v${FOAM_VERSION}.tar.gz

# Download and extract ThirdParty
RUN wget -q https://gitlab.com/openfoam/ThirdParty-common/-/archive/v${FOAM_VERSION}/ThirdParty-common-v${FOAM_VERSION}.tar.gz && \
    tar -xzf ThirdParty-common-v${FOAM_VERSION}.tar.gz && \
    mv ThirdParty-common-v${FOAM_VERSION} ThirdParty-v${FOAM_VERSION} && \
    rm ThirdParty-common-v${FOAM_VERSION}.tar.gz

# Set up environment
WORKDIR ${FOAM_INST_DIR}/OpenFOAM-v${FOAM_VERSION}
RUN echo "source ${FOAM_INST_DIR}/OpenFOAM-v${FOAM_VERSION}/etc/bashrc" >> /home/dockeruser/.bashrc

# Compile OpenFOAM (parallel build)
WORKDIR ${FOAM_INST_DIR}/OpenFOAM-v${FOAM_VERSION}
RUN /bin/bash -c "source etc/bashrc && ./Allwmake -j -s -q -l"

# Clean intermediate build files but keep source and compilation tools
RUN /bin/bash -c "source etc/bashrc && wclean all" && \
    find ${FOAM_INST_DIR} -type f -name "*.o" -delete && \
    find ${FOAM_INST_DIR} -type f -name "*.dep" -delete && \
    rm -rf /home/dockeruser/.cache/*

# Set working directory
WORKDIR /home/dockeruser

# Source OpenFOAM environment on container start
CMD ["/bin/bash"]
