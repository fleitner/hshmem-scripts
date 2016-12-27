#!/bin/bash

source ${WORKDIR}/scripts/config.sh

for i in {1..10}
do
	if [ -f /dev/shm/ivsh0 ]; then
		break
	fi
	sleep 1
done

if [ ! -f /dev/shm/ivsh0 ]; then
	echo "ERROR: file not found: /dev/shm/ivsh0"
	exit -1
fi

# need to check if testpmd is running in the guest
while :;
do
	sleep 1
	PID=$(ssh 192.168.1.2 pidof testpmd)
	ret=$?
	if [ ${ret} -eq 255 ]; then
		if [ ! -f /dev/shm/ivsh0 ]; then
			echo "VM is not ready, aborting"
			exit -1
		fi
		continue
	fi

	if [ ${ret} -eq 1 ]; then
		continue
	fi

	if [ ${PID} -gt 0 ]; then
		break
	fi

done

sleep 5
${ovs_vsctl} add-port ovsbr0 ivsh0 \
	-- set interface ivsh0 type=dpdkhshmem ofport_request=20

${ovs_ofctl} del-flows ovsbr0
${ovs_ofctl} add-flow ovsbr0 in_port=11,actions=20
${ovs_ofctl} add-flow ovsbr0 in_port=20,actions=11

