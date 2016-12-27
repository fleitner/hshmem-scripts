#!/bin/bash

source ${WORKDIR}/config.sh
echo ${OVSDPDK_LCOREMASK#0x} > /sys/kernel/debug/tracing/tracing_cpumask
