#!/bin/bash

OVS_PID="$(pidof ovs-vswitchd)"
for pid in $(ps -e -T  | grep ${OVS_PID} | grep -v 'pmd' | awk '{ print $2 }')
do
	taskset -p -c 21-22 ${pid}
done

tuna -t ovs-vswitchd -CP

