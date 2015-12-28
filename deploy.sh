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
module add zlib
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add hdf5/1.8.15-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}

echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
make distclean
CFLAGS=-fPIC ../configure --prefix=${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} \
--enable-shared \
--enable-pnetcdf \
--enable-netcdf-4 \
--enable-fsync \
--enable-dynamic-loading--enable-dynamic-loading \
--enable-hdf4 \
--enable-remote-fortran-bootstrap \
--enable-cdmremote \
--enable-benchmarks \
--enable-mmap \
--enable-jna \
--enable-hdf4-file-tests \
--enable-extra-example-tests \
--enable-parallel-tests \
--enable-extra-tests
make install
mkdir -p ${LIBRARIES_MODULES}/${NAME}

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
prereq gmp
module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/netcdf-deploy"
setenv       NETCDF_VERSION       $VERSION
setenv       NETCDF_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-$GCC_VERSION-mpi-$OPENMPI_VERSION
prepend-path LD_LIBRARY_PATH   $::env(NETCDF_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(NETCDF_DIR)/include
MODULE_FILE
) > ${LIBRARIES_MODULES}/${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
