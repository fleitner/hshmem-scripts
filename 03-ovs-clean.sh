#!/bin/bash

source ${WORKDIR}/scripts/config.sh

pkill -9 -f ovs-vswitchd
pkill -9 -f ovsdb-server


rm -rf /dev/hugepages/rtemap_*
rm -rf ${prefix}/var/log/openvswitch
rm -rf ${prefix}/var/run/openvswitch
rm -rf ${prefix}/etc/openvswitch
rm -rf /var/lib/systemd/coredump/c*

if [ ! -d  ${prefix}/var/run/openvswitch ]; then
	mkdir -p ${prefix}/var/run/openvswitch
fi

if [ ! -d  ${prefix}/var/log/openvswitch ]; then
	mkdir -p ${prefix}/var/log/openvswitch
fi

if [ ! -d  ${prefix}/etc/openvswitch ]; then
	mkdir -p ${prefix}/etc/openvswitch
fi

dmesg -c > /dev/null

rm -f /dev/shm/ivsh0
sleep 1
