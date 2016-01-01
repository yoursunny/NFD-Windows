#!/bin/bash
set -x
set -e

REPO="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKDIR=$(pwd)/build
STAGING=$(pwd)/staging
TOOLCHAIN=/usr/lib/mxe
export PATH=$PATH:$TOOLCHAIN/usr/bin

rm -rf $STAGING
mkdir -p $WORKDIR
cd $WORKDIR


cd $WORKDIR
rm -rf cryptopp || true
git clone --recursive https://github.com/weidai11/cryptopp.git
cd cryptopp
git checkout aff51055698873166c93d83ce09578d2ec613e64

patch -p1 < $REPO/cryptopp.patch

PREFIX="$STAGING" AS="i686-w64-mingw32.static-as" AR="i686-w64-mingw32.static-ar" RANLIB="i686-w64-mingw32.static-ranlib" STRIP="i686-w64-mingw32.static-strip" CXX="i686-w64-mingw32.static-g++" CXXFLAGS="-march=i686" make static
PREFIX="$STAGING" make install


cd $WORKDIR
rm -rf ndn-cxx || true
git clone --recursive https://github.com/named-data/ndn-cxx.git
cd ndn-cxx
git checkout ed2aebafae2071abe9b1ba4fa11a3de0d6bcd59b

patch -p1 < $REPO/ndn-cxx.patch

CXX="i686-w64-mingw32.static-g++" CXX_NAME="gcc" CXXFLAGS="-g -march=i686" ./waf configure --prefix=$STAGING --without-pch --with-sqlite3=$TOOLCHAIN/usr/i686-w64-mingw32.static --with-cryptopp=$STAGING --boost-includes=$TOOLCHAIN/usr/i686-w64-mingw32.static/include --boost-libs=$TOOLCHAIN/usr/i686-w64-mingw32.static/lib --boost-static --disable-shared --enable-static
./waf
./waf install

cd $STAGING/bin
rm -r ndnsec-* tlvdump.exe || true


cd $WORKDIR
rm -rf NFD || true
git clone --recursive https://github.com/named-data/NFD.git
cd NFD
git checkout da3ba964301a43f15e6b87c3d585713068252ae6

patch -p1 < $REPO/NFD.patch

CXX="i686-w64-mingw32.static-g++" CXX_NAME="gcc" CXXFLAGS="-g -march=i686" PKG_CONFIG_PATH=$STAGING/lib/pkgconfig ./waf configure --prefix=$STAGING --without-pch --without-libpcap --boost-includes=$TOOLCHAIN/usr/i686-w64-mingw32.static/include --boost-libs=$TOOLCHAIN/usr/i686-w64-mingw32.static/lib --boost-static
./waf
./waf install

cd $STAGING/bin
rm -r nrd ndncatchunks3.exe ndnputchunks3.exe ndn-tlv-*.exe nfd-start nfd-stop || true


cd $WORKDIR
rm -rf infoedit || true
git clone --recursive https://github.com/NDN-Routing/infoedit.git
cd infoedit
git checkout 87320990cb7c1a0ef6d520b9e1e2bc6d815abada

make

i686-w64-mingw32.static-g++ -march=i686 -o infoedit.exe -std=c++11 infoedit.cpp -L$TOOLCHAIN/usr/i686-w64-mingw32.static/lib -lboost_program_options-mt
cp infoedit.exe $STAGING/bin

cd $STAGING/etc/ndn
cp nfd.conf.sample nfd.conf
$WORKDIR/infoedit/infoedit -f nfd.conf -d face_system.unix


cd $WORKDIR
rm -rf ndn-tools || true
git clone --recursive https://github.com/named-data/ndn-tools.git
cd ndn-tools
git checkout 3e79c9cda4782ef81dcab9d596df53922b254fda

patch -p1 < $REPO/ndn-tools.patch

CXX="i686-w64-mingw32.static-g++" CXX_NAME="gcc" CXXFLAGS="-g -march=i686" PKG_CONFIG_PATH=$STAGING/lib/pkgconfig ./waf configure --prefix=$STAGING --enable-ping --enable-peek --enable-dissect --boost-includes=$TOOLCHAIN/usr/i686-w64-mingw32.static/include --boost-libs=$TOOLCHAIN/usr/i686-w64-mingw32.static/lib --boost-static
./waf
./waf install
