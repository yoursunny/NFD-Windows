#!/bin/bash
for I in $(seq 9999); do sleep 60; echo KEEP ALIVE; done &
KEEPALIVE_PID=$!

set -x
set -e

REPO="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOOLCHAIN=$(pwd)/mxe

mkdir -p $TOOLCHAIN
cd $TOOLCHAIN

git init
git fetch https://github.com/mxe/mxe.git
git checkout 56bee8297bd90203b7e3386d5bd2b227c777fd38

make gcc
make CXXFLAGS="-march=i686" boost sqlite

kill $KEEPALIVE_PID
