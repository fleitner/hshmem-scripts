#!/bin/bash

source ${WORKDIR}/scripts/config.sh

echo "rxqs=${nr_q} cpu-mask=${OVSDPDK_LCOREMASK}"
if [ ! -f ${prefix}/etc/openvswitch/conf.db ]; then
	${ovsdb_tool} create \
		${prefix}/etc/openvswitch/conf.db \
		${_prefix}/share/openvswitch/vswitch.ovsschema
fi

# Run ovsdb-server
#numactl -i ${ovs_socket} -C 1 \
	${ovsdb_server} \
	${prefix}/etc/openvswitch/conf.db \
	-vconsole:emer -vsyslog:err -vfile:info \
	--remote=punix:${prefix}/var/run/openvswitch/db.sock \
	--private-key=db:Open_vSwitch,SSL,private_key \
	--certificate=db:Open_vSwitch,SSL,certificate \
	--bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
	--log-file=${prefix}/var/log/openvswitch/ovsdb-server.log \
	--pidfile=${prefix}/var/run/openvswitch/ovsdb-server.pid \
	--no-chdir --monitor --detach

sleep 1

# configure OVS DPDK
VSWITCHD_DPDK_PARAM=""
if [ ${OVSDB_DPDK} -eq 1 ]; then
	${ovs_vsctl} --no-wait --if-exists del-br ovsbr0
	${ovs_vsctl} --no-wait set Open_vSwitch . \
		other_config:dpdk-init=true
	${ovs_vsctl} --no-wait set Open_vSwitch . \
		other_config:dpdk-socket-mem="${OVSDPDK_SOCKETMEM}"
	${ovs_vsctl} --no-wait set Open_vSwitch . \
		other_config:pmd-cpu-mask="${OVSDPDK_PMDCPUMASK#0x}"
	${ovs_vsctl} --no-wait set Open_vSwitch . \
		other_config:dpdk-lcore-mask="${OVSDPDK_LCOREMASK}"
	#${ovs_vsctl} --no-wait set Open_vSwitch . \
	#	other_config:vhost-sock-dir="${prefix}/var/run/openvswitch"
else
	${ovs_vsctl} --no-wait set Open_vSwitch . \
		other_config:pmd-cpu-mask="${OVSDPDK_PMDCPUMASK#0x}"
	VSWITCHD_DPDK_PARAM="--dpdk -c ${OVSDPDK_LCOREMASK#0x} -n 4 --socket-mem ${OVSDPDK_SOCKETMEM} --"
fi


# Run ovs-vswitchd
#numactl -i ${ovs_socket}
	${ovs_vswitchd} \
	${VSWITCHD_DPDK_PARAM} \
	unix:${prefix}/var/run/openvswitch/db.sock \
	-vconsole:emer -vsyslog:err -vfile:info \
	--log-file=${prefix}/var/log/openvswitch/ovs-vswitchd.log \
	--pidfile=${prefix}/var/run/openvswitch/ovs-vswitchd.pid \
	--mlockall --no-chdir  2>&1 > vswitchd.log &

