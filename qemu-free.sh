#!/bin/bash


QEMU_PID=$1

for qemu in $(ps -e -T | awk '/qemu-system-x86/ { print $2 }')
do
	taskset -p -c 1-6 ${qemu}
done

#taskset -p -c 4  ${QEMU_PID}

