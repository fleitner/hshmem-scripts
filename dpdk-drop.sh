#!/bin/bash

OFPORT=$1

PKTS=0
PKTS_NOW=0
DROP=0
DROP_NOW=0
TOTAL_NOW=0
while :;
do
	VARS=$(ovs-ofctl dump-ports ovsbr0 |\
	  sed -n "s/.*${OFPORT}: rx pkts=\([0-9]\+\),.*drop=\([0-9]\+\),.*/\1 \2/p")
	
	PKTS_NOW=${VARS/ */}
	DROP_NOW=${VARS/* /}

	if [ ${PKTS} -ne 0 ]; then
		RX=$((PKTS_NOW - PKTS))
	fi
	PKTS=${PKTS_NOW}

	if [ ${DROP} -ne 0 ]; then
		DR=$((DROP_NOW - DROP))
	fi
	DROP=${DROP_NOW}
	TOTAL_NOW=$((RX + DR))

	if [ ${TOTAL_NOW} -ne 0 ]; then
		RX_PTG=$(( RX * 100 / TOTAL_NOW ))
		DROP_PTG=$(( DR * 100 / TOTAL_NOW ))
	fi

	echo "FW: ${RX}/s ${RX_PTG}%  Dropped: ${DR}/s ${DROP_PTG}% Total: ${TOTAL_NOW}/s"
	sleep 1
done




