#!/bin/bash

QEMU_PID=$1

for qemu in $(ps -e -T | awk '/qemu-system-x86/ { print $2 }' | grep -v ${QEMU_PID})
do
	taskset -p -c 2-3 ${qemu}
done

taskset -p -c 4  ${QEMU_PID}

