#!/bin/bash
set -x
set -e

REPO="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKDIR=$(pwd)/build
STAGING=$(pwd)/staging

TOOLCHAIN=$(pwd)/mxe
export PATH=$PATH:$TOOLCHAIN/usr/bin

mkdir -p $WORKDIR
cd $WORKDIR


mkdir cryptopp
cd cryptopp

git init
git fetch https://github.com/weidai11/cryptopp.git
git checkout aff51055698873166c93d83ce09578d2ec613e64

patch -p1 < $REPO/cryptopp.patch

PREFIX="$STAGING" AS="i686-w64-mingw32.static-as" AR="i686-w64-mingw32.static-ar" RANLIB="i686-w64-mingw32.static-ranlib" STRIP="i686-w64-mingw32.static-strip" CXX="i686-w64-mingw32.static-g++" CXXFLAGS="-march=i686" make static
PREFIX="$STAGING" make install

cd ..


mkdir ndn-cxx
cd ndn-cxx

git init
git fetch https://github.com/named-data/ndn-cxx.git
git checkout bbca1b9ec1cc0a042560db6ab5f66a975647b46e

patch -p1 < $REPO/ndn-cxx.patch

CXX="i686-w64-mingw32.static-g++" CXX_NAME="gcc" CXXFLAGS="-g -march=i686" ./waf configure --prefix=$STAGING --without-pch --with-sqlite3=$TOOLCHAIN/usr/i686-w64-mingw32.static --with-cryptopp=$STAGING --boost-includes=$TOOLCHAIN/usr/i686-w64-mingw32.static/include --boost-libs=$TOOLCHAIN/usr/i686-w64-mingw32.static/lib --boost-static --disable-shared --enable-static
./waf
./waf install

cd ..


mkdir NFD
cd NFD

git init
git fetch https://github.com/named-data/NFD.git
git checkout 5c47597be9cbcbff920a5f780cbf94bb649e8d4f
git submodule update --init

patch -p1 < $REPO/NFD.patch

CXX="i686-w64-mingw32.static-g++" CXX_NAME="gcc" CXXFLAGS="-g -march=i686" PKG_CONFIG_PATH=$STAGING/lib/pkgconfig ./waf configure --prefix=$STAGING --without-pch --without-libpcap --boost-includes=$TOOLCHAIN/usr/i686-w64-mingw32.static/include --boost-libs=$TOOLCHAIN/usr/i686-w64-mingw32.static/lib --boost-static
./waf
./waf install

cd ..


mkdir infoedit
cd infoedit

git init
git fetch https://github.com/NDN-Routing/infoedit.git
git checkout 87320990cb7c1a0ef6d520b9e1e2bc6d815abada

make

i686-w64-mingw32.static-g++ -march=i686 -o infoedit.exe -std=c++11 infoedit.cpp -L$TOOLCHAIN/usr/i686-w64-mingw32.static/lib -lboost_program_options-mt
cp infoedit.exe $STAGING/bin

cd ..


cp $STAGING/etc/ndn/nfd.conf.sample $STAGING/etc/ndn/nfd.conf
infoedit/infoedit -f $STAGING/etc/ndn/nfd.conf -d face_system.unix


mkdir ndn-tools
cd ndn-tools

git init
git fetch https://github.com/named-data/ndn-tools.git
git checkout 3e79c9cda4782ef81dcab9d596df53922b254fda

patch -p1 < $REPO/ndn-tools.patch

CXX="i686-w64-mingw32.static-g++" CXX_NAME="gcc" CXXFLAGS="-g -march=i686" PKG_CONFIG_PATH=$STAGING/lib/pkgconfig ./waf configure --prefix=$STAGING --enable-ping --enable-peek --boost-includes=$TOOLCHAIN/usr/i686-w64-mingw32.static/include --boost-libs=$TOOLCHAIN/usr/i686-w64-mingw32.static/lib --boost-static
./waf
./waf install

cd ..
