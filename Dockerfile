# OpenFOAM 2506 on Ubuntu 24.04
# Minimal packages with compilation ability preserved
# SINGLE LAYER BUILD - optimized for smallest size

FROM dafoam/openfoam:thirdparty

# Switch to dockeruser
USER dockeruser

# Download, extract, compile, and clean in ONE layer
RUN cd /home/dockeruser/OpenFOAM/OpenFOAM-v2506 && \
    source etc/bashrc && export WM_QUIET=true && ./Allwmake -j && \
    wclean all && rm -rf build && \
    rm -rf /home/dockeruser/.cache/*

# Set working directory
WORKDIR /home/dockeruser

# Source OpenFOAM environment on container start
CMD ["/bin/bash"]
