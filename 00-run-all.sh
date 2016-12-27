#!/bin/bash

ulimit -c unlimited
SCRIPT_LIST="01-kill-vm.sh 02-setup.sh 03-ovs-clean.sh 04-ovs.sh 05-ovs-ports-flows.sh 06-guest-start.sh 07-schedule-09.sh 08-run-testpmd.sh"

for script in ${SCRIPT_LIST}; do
	echo "Running $script"
	sh ${script} || exit 1
done

