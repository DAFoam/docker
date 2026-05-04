#!/bin/bash
FOAM_INST_DIR=/home/dafoamuser/dafoam/OpenFOAM

mkdir -p /home/dafoamuser/dafoam
mkdir -p ${FOAM_INST_DIR}
mkdir -p /home/dafoamuser/mount

cd ${FOAM_INST_DIR}
wget https://sourceforge.net/projects/openfoam/files/v2506/OpenFOAM-v2506.tgz/download -O OpenFOAM-v2506.tgz
wget https://sourceforge.net/projects/openfoam/files/v2506/ThirdParty-v2506.tgz/download -O ThirdParty-v2506.tgz
tar -xvf OpenFOAM-v2506.tgz
tar -xvf ThirdParty-v2506.tgz
rm -rf OpenFOAM-v2506.tgz ThirdParty-v2506.tgz

cd ${FOAM_INST_DIR}/OpenFOAM-v2506

source etc/bashrc 

export WM_QUIET=true

./Allwmake -j -q

wclean all && rm -rf build ../ThirdParty-v2506/build

rm -rf /home/dafoamuser/.cache/*"
