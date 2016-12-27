

ssh root@192.168.1.2 poweroff || ( sleep 5; killall qemu-system-x86_64 )
exit 0
