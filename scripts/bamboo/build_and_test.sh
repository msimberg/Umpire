#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

export UMPIRE_DIR=$(git rev-parse --show-toplevel)
export BUILD_DIR=build-${SYS_TYPE}

export COMPILER=${1:-gcc_4_9_3}
export BUILD_TYPE=${2:-Release}

mkdir ${BUILD_DIR} 2> /dev/null
cd ${BUILD_DIR}

echo "Configuring..."

cmake -C ${UMPIRE_DIR}/host-configs/${SYS_TYPE}/${COMPILER}.cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} ${BUILD_OPTIONS} ../

echo "Building..."
make VERBOSE=1 -j

echo "Testing..."
if [[ $HOSTNAME == *manta* ]]; then
  bsub -x -n 1 -G guests -Ip ctest -T Test
else
  srun -ppdebug -t 5 -N 1 ctest -T Test
fi