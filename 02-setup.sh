#!/bin/bash

for gov in /sys/devices/system/cpu/*/cpufreq/scaling_governor
do
        echo performance > $gov
done

if ! mount | grep -q '/dev/hugepages'; then
	mount -t hugetlbfs -o pagesize=1G none /dev/hugepages
fi

ip l show br0 2> /dev/null > /dev/null
if [ $? -ne 0 ]; then
	brctl addbr br0 
	ip link set br0 up 
	echo 1 > /proc/sys/net/ipv4/ip_forward
	EGRESSDEV=$(ip route get 8.8.8.8 | sed -n 's/.*dev \(.*\) src.*/\1/p')
	iptables -I FORWARD -o ${EGRESSDEV} -j ACCEPT
	iptables -t nat -I POSTROUTING -o ${EGRESSDEV} -j MASQUERADE
	ip address add 192.168.1.1/24 dev br0
fi

tuna -c 2,3,4,6,7 --isolate &> /dev/null

