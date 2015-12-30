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
cd ${WORKSPACE}/build-${BUILD_NUMBER}
#make check
echo $?

make install # DESTDIR=$SOFT_DIR

mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       NETCDF_VERSION       $VERSION
setenv       NETCDF_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/${NAME}/${VERSION}-gcc-${GCC_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(NETCDF_DIR)/lib
setenv       NETCDF_INCLUDE_DIR   $::env(NETCDF_DIR)/include
prepend-path PATH             $::env(NETCDF_DIR)/bin
MODULE_FILE
) > modules/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}

mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} ${LIBRARIES_MODULES}/${NAME}/

module avail
#module add  openmpi-x86_64
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
cd $WORKSPACE

echo "Working directory is $PWD with : "
ls
echo "LD_LIBRARY_PATH is $LD_LIBRARY_PATH"
echo "Compiling serial code"
echo "just kidding."
