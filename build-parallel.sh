#!/bin/bash -e
. /etc/profile.d/modules.sh
SOURCE_FILE=${NAME}-${VERSION}.tar.gz
module add ci
mkdir -p ${SOFT_DIR} ${WORKSPACE} ${SRC_DIR}

module add bzip2
module  add  curl
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
#  We always want to use the latest version of HDF5, I guess. If we add HDF5 version here, the build matrix will double in size.
module add hdf5/1.8.16-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}

PNETCDF_SOURCE_FILE=parallel-netcdf-1.6.1.tar.gz
if [ ! -e ${SRC_DIR}/${PNETCDF_SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${PNETCDF_SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${PNETCDF_SOURCE_FILE}.lock
  echo "looks like the tarball isn't there yet"
  mkdir -p ${SRC_DIR}
  wget  -O ${SRC_DIR}/${PNETCDF_SOURCE_FILE} http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/${PNETCDF_SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${PNETCDF_SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${PNETCDF_SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${PNETCDF_SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${PNETCDF_SOURCE_FILE}
fi

echo "Untarring Parallel NETCDF Source File"
tar -xz --keep-newer-files -f ${SRC_DIR}/${PNETCDF_SOURCE_FILE} -C ${WORKSPACE}

# echo $NAME | tr '[:upper:]' '[:lower:]'
ls ${WORKSPACE}
cd ${WORKSPACE}/parallel-netcdf-1.6.1/
echo "Configuring Pnetcdf"
LIBS="-ldl" \
CC=mpicc \
CPPFLAGS="-fPIC -I${HDF5_DIR}/include" LDFLAGS="-L${HDF5_DIR}/lib" \
./configure --prefix=${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} \
--enable-pnetcdf \
--enable-dynamic-loading

make

echo "######################### Done with parallel netcdf ############################"
