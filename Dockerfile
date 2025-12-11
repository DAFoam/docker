# OpenFOAM 2506 on Ubuntu 24.04
# Minimal packages with compilation ability preserved
# SINGLE LAYER BUILD - optimized for smallest size

FROM dafoam/openfoam:ubuntu2404

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
        cd ${FOAM_INST_DIR}/ThirdParty-v${FOAM_VERSION} && ./Allwmake -j && rm -rf source && \
        cd ${FOAM_INST_DIR}/OpenFOAM-v${FOAM_VERSION} && ./Allwmake -j && \
        wclean all && rm -rf build && \
        rm -rf /home/dockeruser/.cache/*"

# Set working directory
WORKDIR /home/dockeruser

# Source OpenFOAM environment on container start
CMD ["/bin/bash"]
