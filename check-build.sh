#!/bin/bash -e
source /etc/profile.d/modules.sh
module add ci
module add gmp
module add mpfr
module add mpc
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add bzip2
module add curl
module add hdf5/1.8.16-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
cd ${WORKSPACE}/build-${BUILD_NUMBER}
#make check
echo $?

make install # DESTDIR=$SOFT_DIR
# don't forget to copy netcdf.inc
# According to : https://www.unidata.ucar.edu/software/netcdf/docs/netcdf-install.html#Building-on-Unix
# To Install
#    Copy libsrc\netcdf.lib to a LIBRARY directory. Copy libsrc\netcdf.h and fortran/netcdf.inc to an INCLUDE directory. Copy
#    libsrc\netcdf.dll, ncdump/ncdump.exe, and ncgen/ncgen.exe to a BIN directory (someplace in your PATH).

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
setenv       NETCDF_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/${NAME}/$::env(VERSION)-gcc-$::env(GCC_VERSION)-mpi-$::env(OPENMPI_VERSION)
prepend-path LD_LIBRARY_PATH   $::env(NETCDF_DIR)/lib
setenv       NETCDF_INCLUDE_DIR   $::env(NETCDF_DIR)/include
prepend-path PATH             $::env(NETCDF_DIR)/bin
MODULE_FILE
) > modules/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}

mkdir -p ${LIBRARIES}/${NAME}
cp modules/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} ${LIBRARIES}/${NAME}/

module avail
#module add  openmpi-x86_64
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
cd $WORKSPACE

echo "Working directory is $PWD with : "
ls
echo "LD_LIBRARY_PATH is $LD_LIBRARY_PATH"
echo "Compiling serial code"
echo "just kidding."
