#!/bin/bash -e
. /etc/profile.d/modules.sh
SOURCE_FILE=${NAME}-${VERSION}.tar.gz
module add ci
echo "SOFT_DIR is ${SOFT_DIR}"
echo "WORKSPACE is ${WORKSPACE}"
echo "SRC_DIR is ${SRC_DIR}"
mkdir -p ${SOFT_DIR} ${WORKSPACE} ${SRC_DIR}
echo "NAME is ${NAME}"
echo "VERSION is ${VERSION}"
module add gmp
module add mpfr
module add mpc
module add bzip2
module  add  curl
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
#  We always want to use the latest version of HDF5, I guess. If we add HDF5 version here, the build matrix will double in size.
module add hdf5/1.8.16-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}

module list

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "looks like the tarball isn't there yet"
  ls ${SRC_DIR}
  mkdir -p ${SRC_DIR}
  wget  -O ${SRC_DIR}/${SOURCE_FILE} ftp://ftp.unidata.ucar.edu/pub/netcdf/old/netcdf-${VERSION}.tar.gz
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi

mkdir -p ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "Untarring NETCDF source file"
tar -xz --keep-newer-files --strip-components=1 -f ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE}
cd ${WORKSPACE}
mkdir -p ${WORKSPACE}/build-${BUILD_NUMBER}
# we need to fix H5DIR temporarily
#export HDF5_DIR=${HDF5_DIR} #-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
echo "new HDF5_DIR is ${HDF5_DIR}"

# Set compiler flags
# We need include and lib dirs for :
# HDF5
# MPI
# Parallel NetCDF
export LDFLAGS="-L${HDF5_DIR}/lib \
-L${OPENMPI_DIR}/lib \
-L${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}/lib \
-L${HDF5_DIR}/lib \
-L${OPENMPI_DIR}/lib"

export CPPFLAGS="-I${HDF5_DIR}/include \
-I${OPENMPI_DIR}/include/ \
-I${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}/include"

export CFLAGS="-fPIC -I${HDF5_DIR}/include \
-I${OPENMPI_DIR}/include/ \
-I${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}/include"

export FFLAGS="-I${HDF5_DIR}/include \
-I${OPENMPI_DIR}/include/ \
-I${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}/include"

export F90=mpif90
export CC=mpicc
export CXX=mpicxx
# H5Pset_fapl_mpiposix is deprecated  https://www.hdfgroup.org/HDF5/doc/RM/H5P/H5Pset_fapl_mpiposix.htm
# echo "fixing mpiposix"
# egrep -ilRZ H5Pset_fapl_mpiposix ${PWD} | xargs  -0 -e sed -i 's/H5Pset_fapl_mpiposix/H5Pset_fapl_mpio/g'
cd ${WORKSPACE}/build-${BUILD_NUMBER}
../configure --prefix=${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} \
--enable-shared \
--enable-fsync \
--enable-dynamic-loading \
--enable-benchmarks \
--enable-mmap \
--enable-jna \
--enable-extra-example-tests \
--enable-extra-tests \
--enable-pnetcdf

make
