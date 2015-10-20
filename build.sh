#!/bin/bash
SOURCE_FILE=${NAME}-${VERSION}.tar.gz
module load ci
echo "SOFT_DIR is ${SOFT_DIR}
echo "WORKSPACE is ${WORKSPACE}"
echo "SRC_DIR is ${SRC_DIR}"
mkdir -p $SOFT_DIR $WORKSPACE $SRC_DIR
echo "NAME is ${NAME}"
echo "VERSION is ${VERSION}"
module load gcc/${GCC_VERSION}"
module load hdf5/1.8.15-gcc-${GCC_VERSION}
module list

if [[ ! -s ${SRC_DIR}/${SOURCE_FILE} ]] ; then
  echo "looks like the tarball isn't there yet"
  ls ${SRC_DIR}
  mkdir -p ${SRC_DIR
  wget  -O ${SRC_DIR}/${SOURCE_FILE} ftp://ftp.unidata.ucar.edu/pub/netcdf/old/netcdf${VERSION}
fi
tar -xz --keep-newer-files -f ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE}
# echo $NAME | tr '[:upper:]' '[:lower:]'
ls ${WORKSPACE}
# Again with the frikkin naming conventions
cd $WORKSPACE/${NAME}-$VERSION
./configure --prefix=${SOFT_DIR}-gcc-${GCC_VERSION} --enable-shared
make -j 8
