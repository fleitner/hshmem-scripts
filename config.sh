
source ${WORKDIR}/config-env.sh

# Generic
socket=0
nr_q=1

# ----------------  OVS  ---------------
OVSDPDK_LCOREMASK="0x60"
OVSDPDK_PMDCPUMASK="0x80"
OVSDPDK_SOCKETMEM="2048,0"

_prefix="/usr"
if [ ! -z "${prefix}" ]; then
    _prefix="${prefix}"
fi
	
ovsdb_tool="${_prefix}/bin/ovsdb-tool"
ovs_vsctl="${_prefix}/bin/ovs-vsctl"
ovs_ofctl="${_prefix}/bin/ovs-ofctl"
ovs_appctl="${_prefix}/bin/ovs-appctl"
ovs_vswitchd="${_prefix}/sbin/ovs-vswitchd"
ovsdb_server="${_prefix}/sbin/ovsdb-server"
ovs_socket=${socket}



# ----------------  QEMU  ---------------
qemu_bin="/usr/local/bin/qemu-system-x86_64"
qemu_socket=${socket}
# CPUs 2,3,4
qemu_mask="0xff"
qemu_mem="2048"
qemu_mrgrxbuf_disable=0
#qemu_offloads=",csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off"
qemu_offloads=""
qemu_threads=1


