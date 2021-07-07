#!/bin/bash

trap ctrl_c 2

ctrl_c(){
	echo -e "\n[!] Ctrl+C pressed. Closing program...\n"
	tput cnorm
	exit 1
}

if [ -z "$1" ]; then
	echo -en "\n\t[!]Error: Missing interface\n"
	echo -e "\t   Usage: $0 interface\n"
	exit 2
else
	iface="$1"
fi

# Check interface
if /usr/sbin/ifconfig "$iface" &>/dev/null; then
	ip=$(/usr/sbin/ifconfig "$iface" | grep "inet\s" | awk '{printf $2}')
	red="${ip%.*}"
else
	echo -en "\n\t[!]Error: interface not found!\n"
	exit 3
fi

tput civis
for x in {1..255}; do
	timeout 1 ping -c 1 "${red}.$x" &>/dev/null && echo -en "\t[+]Host discovered ${red}.$x\n" &
done; wait


echo -en "\tScan Completed!\n"
tput cnorm
