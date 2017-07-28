#!/bin/bash -e
#  Testing  :
# testing          - test PnetCDF build for sequential run
#   ptest            - test PnetCDF build for parallel run
#   install          - install PnetCDF


. /etc/profile.d/modules.sh
SOURCE_FILE=${NAME}-${VERSION}.tar.gz
module add ci
echo "SOFT_DIR is ${SOFT_DIR}"
echo "WORKSPACE is ${WORKSPACE}"
echo "SRC_DIR is ${SRC_DIR}"
mkdir -p ${SOFT_DIR} ${WORKSPACE} ${SRC_DIR}
echo "NAME is ${NAME}"
echo "VERSION is ${VERSION}"
module add bzip2
module  add  curl
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
#  We always want to use the latest version of HDF5, I guess. If we add HDF5 version here, the build matrix will double in size.
module add hdf5/1.8.16-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}

cd ${WORKSPACE}/parallel-netcdf-1.6.1/
make check
make test
make ptest

make install
