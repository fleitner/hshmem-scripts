#!/bin/bash

source ${WORKDIR}/scripts/config.sh


${ovs_vsctl} add-br ovsbr0 \
        -- set bridge ovsbr0 datapath_type=netdev

${ovs_vsctl} add-port ovsbr0 dpdk0 \
	-- set interface dpdk0 type=dpdk ofport_request=10

${ovs_vsctl} add-port ovsbr0 dpdk1 \
	-- set interface dpdk1 type=dpdk ofport_request=11

${ovs_vsctl} --no-wait set Open_vSwitch . other_config:max-idle=50000
${ovs_ofctl} del-flows ovsbr0
${ovs_ofctl} add-flow ovsbr0 in_port=10,action=11
${ovs_ofctl} add-flow ovsbr0 in_port=11,action=10

cat ${prefix}/var/log/openvswitch/ovs-vswitchd.log

#OVS_PID="$(pidof ovs-vswitchd)"
#for pid in $(ps -e -T  | grep ${OVS_PID} | grep -v 'pmd' | awk '{ print $2 }')
#do
#	taskset -p -c 5,6 ${pid}
#done

#tuna -t ovs-vswitchd -CP


