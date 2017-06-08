#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
echo ${SOFT_DIR}
module add deploy
# Now, dependencies
module add gmp
module add mpfr
module add mpc
module add bzip2
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add hdf5/1.8.16-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
module add netcdf/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
echo ${SOFT_DIR}
cd ${WORKSPACE}/netcdf-fortran-4.4.1/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
# We can just clean out the config directory
rm -rf *
# Set compiler flags
# We need include and lib dirs for :
# HDF5
# MPI
# Parallel NetCDF

export CPPFLAGS="-I${HDF5_DIR}/include \
-L${HDF5_DIR}/lib \
-I${OPENMPI_DIR}/include/ \
-L${OPENMPI_DIR}/lib \
-I${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}/include \
-L${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}/lib"

export CFLAGS="-fPIC -I${HDF5_DIR}/include \
-L${HDF5_DIR}/lib \
-I${OPENMPI_DIR}/include/ \
-L${OPENMPI_DIR}/lib \
-I${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}/include \
-L${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}/lib"

export FFLAGS="-fPIC -I${HDF5_DIR}/include \
-L${HDF5_DIR}/lib \
-I${OPENMPI_DIR}/include/ \
-L${OPENMPI_DIR}/lib \
-I${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}/include \
-L${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}/lib"
../configure --prefix=${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} \
--enable-shared
make install
