#!/bin/bash -e
source /etc/profile.d/modules.sh
module load ci
module add gmp
module add mpfr
module add mpc
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add bzip2
module add zlib
module add hdf5/1.8.15-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
module add netcdf/${VERSION}-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
cd ${WORKSPACE}/build-${BUILD_NUMBER}
make check
echo $?

make install # DESTDIR=$SOFT_DIR

#module add  openmpi-x86_64
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
cd $WORKSPACE

echo "Working directory is $PWD with : "
ls
echo "LD_LIBRARY_PATH is $LD_LIBRARY_PATH"
