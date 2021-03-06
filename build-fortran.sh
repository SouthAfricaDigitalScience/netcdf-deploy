#!/bin/bash
. /etc/profile.d/modules.sh
SOURCE_FILE=v4.4.4.tar.gz
module add ci
mkdir -p ${SOFT_DIR} ${SRC_DIR}
echo "NAME is ${NAME}"
echo "VERSION is ${VERSION}"
module add gcc/${GCC_VERSION}
module add openmpi/1.8.8-gcc-${GCC_VERSION}
module add hdf5/1.8.16-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
module add netcdf/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
module  add curl
module list

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "looks like the tarball isn't there yet"
  wget  https://github.com/Unidata/netcdf-fortran/archive/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
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

tar -xz --keep-newer-files -f ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE}

mkdir -p ${WORKSPACE}/netcdf-fortran-4.4.4/build-${BUILD_NUMBER}
# we need to fix H5DIR temporarily
export HDF5_DIR=${HDF5_DIR}-gcc-${GCC_VERSION}
echo "new HDF5_DIR is ${HDF5_DIR}"
export CPPFLAGS="-I${HDF5_DIR}/include \
-I${OPENMPI_DIR}/include/ \
-I${NETCDF_DIR}/include"
export CFLAGS="-I${HDF5_DIR}/include \
-I${OPENMPI_DIR}/include \
-I${NETCDF_DIR}/include"

export F90=mpif90
export CC=mpicc
export CXX=mpicxx
cd ${WORKSPACE}/netcdf-fortran-4.4.4/build-${BUILD_NUMBER}
../configure --prefix=${SOFT_DIR}-gcc-${GCC_VERSION} \
--enable-shared
make
