#!/bin/bash
set -x
set -e

echo "deb http://pkg.mxe.cc/repos/apt/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mxeapt.list
sudo apt-key adv --keyserver x-hkp://keys.gnupg.net --recv-keys D43A795B73B16ABE9643FE1AFD8FFF16DB45C6AB
sudo apt-get -qq -y update
sudo apt-get -qq -y install mxe-i686-w64-mingw32.static-gcc mxe-i686-w64-mingw32.static-boost mxe-i686-w64-mingw32.static-sqlite

WORKDIR=$(pwd)/build
TOOLCHAIN=/usr/lib/mxe

mkdir -p $WORKDIR
cd $WORKDIR
rm -rf boost-endian

if [[ ! -d $TOOLCHAIN/usr/i686-w64-mingw32.static/include/boost/endian ]]; then
  mkdir boost-endian
  cd boost-endian
  git init
  git fetch https://github.com/boostorg/endian.git
  git checkout 1b0a41e6cba74f55954b8cb481cb346e5cce39c1
  sudo cp -r include/boost/endian/ $TOOLCHAIN/usr/i686-w64-mingw32.static/include/boost/
  cd ..
fi
