#!/bin/bash

source  ${WORKDIR}/scripts/config.sh

function build_ovs()
{
	pushd `pwd`
	cd ovs
	if [ -d _build ]; then
	    rm -rf _build
	fi

	mkdir _build
	./boot.sh
	cd _build
	#LDFLAGS="-ldl" ../configure --with-dpdk=${WORKDIR}/dpdk/x86_64-native-linuxapp-gcc  --disable-ssl
	CFLAGS="-O0 -g -ggdb" LDFLAGS="-ldl" ../configure --with-dpdk=${WORKDIR}/dpdk/x86_64-native-linuxapp-gcc  --disable-ssl
	rm -f errors
	make -j16 install 2> errors
	echo $?
	if [ -f errors ]; then
	    echo "======> Errors"
	    cat errors
	    echo "<====== Errors"
	fi

	popd

	ldd ${prefix}/sbin/ovs-vswitchd | grep -q ${OVS_VSWITCHD_DPDK}
	if [ $? -ne 0 ]; then
		echo "DPDK link not found"
	fi
}


function build_dpdk()
{
	pushd `pwd`
	cd dpdk
	export RTE_SDK="${WORKDIR}/dpdk"
	export RTE_TARGET="x86_64-native-linuxapp-gcc"
	rm -rf x86_64-native-linuxapp-gcc
	rm -f /lib64/libdpdk.so
	rm -f /usr/local/lib/libdpdk.so
	rm -rf /usr/local/lib*/*rte*

	make T=x86_64-native-linuxapp-gcc config
	make -j8 install DESTDIR=/usr/local T=x86_64-native-linuxapp-gcc EXTRA_CFLAGS='-O0 -g -ggdb'
	#make -j8 install DESTDIR=/usr/local T=x86_64-native-linuxapp-gcc
	ldconfig
	popd
}

case "$1" in
"ovs")
	build_ovs
	;;
"dpdk")
	build_dpdk
	;;
"all")
	build_dpdk
	build_ovs
	;;
*)
	echo "Not supported"
	;;
esac
	

