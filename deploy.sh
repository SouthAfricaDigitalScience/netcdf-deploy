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

echo ${SOFT_DIR}
cd ${WORKSPACE}/build-${BUILD_NUMBER}
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
--enable-shared \
--enable-fsync \
--enable-dynamic-loading--enable-dynamic-loading \
--enable-remote-fortran-bootstrap \
--enable-benchmarks \
--enable-mmap \
--enable-jna \
--enable-extra-example-tests \
--enable-extra-tests

make install

mkdir -p ${LIBRARIES}/${NAME}

# Now, create the module file for deployment
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}
module add gcc/$::env(GCC_VERSION)
module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/netcdf-deploy"
setenv       NETCDF_VERSION       $VERSION
setenv       NETCDF_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-$GCC_VERSION-mpi-$OPENMPI_VERSION
prepend-path LD_LIBRARY_PATH   $::env(NETCDF_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(NETCDF_DIR)/include
prepend-path PATH              $::env(NETCDF_DIR)/bin
MODULE_FILE
) > ${LIBRARIES}/${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
echo "checking deploy module"
module  avail ${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
