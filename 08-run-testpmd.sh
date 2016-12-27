#!/bin/bash


function set_qemu_affinity() {
	QEMU_PID=$(top -H -b -n 1 -p $(pidof qemu-system-x86_64) | awk '/qemu-system/ { print $1 ; exit }')
	echo "vCPU pid $QEMU_PID"

	for qemu in $(ps -e -T | awk '/qemu-system-x86/ { print $2 }' | grep -v ${QEMU_PID})
	do
		taskset -p -c 3-4 ${qemu} >/dev/null
	done

	taskset -p -c 2 ${QEMU_PID} > /dev/null
}

function check_testpmd() {
	if ! ssh root@192.168.1.2 ps auwx | grep -q test-pmd;  then
		echo "Error: testpmd is not running"
		exit 1
	fi
}

function delay_and_set_affinity() {
	sleep 10
#	check_testpmd
	set_qemu_affinity
}

VM_IS_UP=0
# make sure the VM is ready and running testpmd.
sleep 5
for i in $(seq 60); do

	if ssh root@192.168.1.2 /bin/true; then
		VM_IS_UP=1
		break;
	fi
	sleep 1;
done

if [ ${VM_IS_UP} -ne 1 ]; then
	echo "VM didn't boot"
	exit 1
fi

delay_and_set_affinity &

echo "Run /root/testpmd.sh"
ssh root@192.168.1.2
# /root/testpmd.sh




