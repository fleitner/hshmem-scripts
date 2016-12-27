
source ${WORKDIR}/config.sh

case ${nr_q} in
  0)
    ;&
  1)
    mq="off"
    cores=4
    queues_parm=""
    ;;

  2)
    mq="on"
    vectors=",vectors=$(( ${nr_q} * 2 + 2 ))"
    cores=4
    queues_parm=",queues=${nr_q}"
    ;;

  *)
    mq="on"
    vectors=",vectors=$(( ${nr_q} * 2 + 2 ))"
    cores=$(( ${nr_q} / ${qemu_threads} ))
    # cores=$(( ${cores} + 1 ))
    queues_parm=",queues=${nr_q}"
    ;;
esac

mq_arg="mq=${mq}${vectors}${qemu_offloads}"

if [ ${qemu_mrgrxbuf_disable} -eq 1 ]; then
	mrgrxbuf_arg="mrg_rxbuf=off,"
else
	mrgrxbuf_arg=""
fi


echo "----"
echo "Running qemu with ${nr_q} queues, and $cores cores $threads threads, ${mrgable_option}"
echo "----"
sleep 1

rm -f qemu.log

#    -serial stdio \
numactl -i ${qemu_socket} \
    ${qemu_bin} \
    -enable-kvm \
    -m ${qemu_mem} \
    -smp sockets=1,cores=${cores},threads=${qemu_threads} \
    -cpu Nehalem,+x2apic \
    -object memory-backend-file,id=mem,size=${qemu_mem}M,mem-path=/dev/hugepages,share=on \
    -numa node,memdev=mem -mem-prealloc \
    -object memory-backend-file,id=ivsh0,size=16M,mem-path=/dev/shm/ivsh0,share=on \
    -device ivshmem-plain,memdev=ivsh0 \
    -netdev bridge,br=br0,id=hostnet0 \
    -device virtio-net-pci,netdev=hostnet0,id=net0,mac=52:54:00:17:aa:7c \
    -hda f22-mq-1.img  2>&1 > qemu.log &
