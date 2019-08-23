#!/bin/bash

echo "============================== Starting pcas build ====================="

echo "EPICS BASE IS $EPICS_BASE"
cat <<EOF > configure/RELEASE.local
EPICS_BASE=$EPICS_BASE
EOF

# setup the compiler environment variables needed by EPICS
source $RECIPE_DIR/find_compiler.sh

make -j $CPU_COUNT INSTALL_LOCATION=$PREFIX/pcas

# Symlink libraries into $PREFIX/lib
cd $PREFIX/lib
find ../epics/lib/$EPICS_HOST_ARCH/ -name \*.so\* -exec ln -vs "{}" . ';' || : # linux
find ../epics/lib/$EPICS_HOST_ARCH/ -name \*.dylib\* -exec ln -vs "{}" . ';' || : # osx
cd -

# Setup symlinks for utilities
BINS="aitGen caDirServ excas genApps"
cd $PREFIX/bin
for file in $BINS ; do
    ln -vs ../pcas/bin/$EPICS_HOST_ARCH/$file .
done
cd -

mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d
scp $RECIPE_DIR/epics_pcas_activate.sh   $PREFIX/etc/conda/activate.d/epics_pcas.sh
scp $RECIPE_DIR/epics_pcas_deactivate.sh $PREFIX/etc/conda/deactivate.d/epics_pcas.sh

