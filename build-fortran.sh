#!/bin/bash
. /usr/share/modules/init/bash
SOURCE_FILE=${NAME}-${VERSION}.tar.gz
module load ci
echo "SOFT_DIR is ${SOFT_DIR}"
echo "WORKSPACE is ${WORKSPACE}"
echo "SRC_DIR is ${SRC_DIR}"
mkdir -p ${SOFT_DIR} ${WORKSPACE}/${NAME}-${VERSION}-gcc-${GCC_VERSION} ${SRC_DIR}
echo "NAME is ${NAME}"
echo "VERSION is ${VERSION}"
module add gcc/${GCC_VERSION}
module add openmpi/1.8.8-gcc-${GCC_VERSION}
module add hdf5/1.8.15-gcc-${GCC_VERSION}
module add netcdf/${NETCDF_VERSION}-gcc-${GCC_VERSION}

module list

if [[ ! -s ${SRC_DIR}/${SOURCE_FILE} ]] ; then
  echo "looks like the tarball isn't there yet"
  ls ${SRC_DIR}
  mkdir -p ${SRC_DIR}
  wget  -O ${SRC_DIR}/${SOURCE_FILE} ftp://ftp.unidata.ucar.edu/pub/netcdf/old/${NAME}-${VERSION}.tar.gz
fi
tar -xz --keep-newer-files --strip-components=1 -f ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE}
# echo $NAME | tr '[:upper:]' '[:lower:]'
ls ${WORKSPACE}
cd $WORKSPACE
# we need to fix H5DIR temporarily
export HDF5_DIR=${HDF5_DIR}-gcc-${GCC_VERSION}
echo "new HDF5_DIR is ${HDF5_DIR}"
export CPPFLAGS="-I${HDF5_DIR}/include \
-L${HDF5_DIR}/lib \
-I${OPENMPI_DIR}/include/ \
-L${OPENMPI_DIR}/lib \
-I${NETCDF_DIR}/include \
-L${NETCDF_DIR}/lib"
export CFLAGS="-I${HDF5_DIR}/include \
-L${HDF5_DIR}/lib \
-I${OPENMPI_DIR}/include/ \
-L${OPENMPI_DIR}/lib
-I${NETCDF_DIR}/include \
-L${NETCDF_DIR}/lib"
export FFLAGS="-I${HDF5_DIR}/include \
-L${HDF5_DIR}/lib \
-I${OPENMPI_DIR}/include/ \
-L${OPENMPI_DIR}/lib
-I${NETCDF_DIR}/include \
-L${NETCDF_DIR}/lib"

export F90=mpif90
export CC=mpicc
export CXX=mpicxx
./configure --prefix=${SOFT_DIR}-gcc-${GCC_VERSION} --enable-shared


make -j 8