#!/bin/bash

set -e
source ${WORKDIR}/scripts/config.sh

export RTE_SDK="${WORKDIR}/dpdk"
export RTE_TARGET="x86_64-native-linuxapp-gcc"
rm -rf x86_64-native-linuxapp-gcc
rm -f /lib64/libdpdk.so
rm -rf /usr/local/lib*/*rte*

make T=x86_64-native-linuxapp-gcc config
make -j8 DESTDIR=/usr/local T=x86_64-native-linuxapp-gcc install
ldconfig
