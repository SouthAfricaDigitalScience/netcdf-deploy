#!/bin/bash -e
source /etc/profile.d/modules.sh
module load ci
module add bzip2
module add gcc/${GCC_VERSION}
module add openssl/1.0.2j
module add curl
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
cd ${WORKSPACE}/netcdf-fortran-4.4.4/build-${BUILD_NUMBER}
make check
echo $?

make install # DESTDIR=$SOFT_DIR

#module add  openmpi-x86_64
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
cd $WORKSPACE

echo "Working directory is $PWD with : "
ls
echo "LD_LIBRARY_PATH is $LD_LIBRARY_PATH"
