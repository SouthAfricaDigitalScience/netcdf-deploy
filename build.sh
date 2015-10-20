#!/bin/bash
SOURCE_FILE=$NAME-$VERSION.tar.gz
module load ci
echo $SOFT_DIR
echo $WORKSPACE
echo $SRC_DIR
mkdir -p $SOFT_DIR $WORKSPACE $SRC_DIR
echo $NAME
echo $VERSION
module load gcc/${GCC_VERSION}
module load hdf5/1.8.15-gcc-${GCC_VERSION}

if [[ ! -s $SRC_DIR/$SOURCE_FILE ]] ; then
  echo "looks like the tarball isn't there yet"
  ls $SRC_DIR
  mkdir -p $SRC_DIR
  wget  -O $SRC_DIR/$SOURCE_FILE
fi
tar -xzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
# echo $NAME | tr '[:upper:]' '[:lower:]'
ls $WORKSPACE
# Again with the frikkin naming conventions
cd $WORKSPACE/Python-$VERSION
./configure --prefix=$SOFT_DIR --enable-shared
make -j 8
