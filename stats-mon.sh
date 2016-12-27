

ovs-ofctl dump-ports ovsbr0 > before

while :;
do
	read $a
	ovs-ofctl dump-ports ovsbr0 > after
	diff  -u before after
done
	
