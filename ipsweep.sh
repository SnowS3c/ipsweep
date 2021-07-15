#!/bin/bash

declare -a network_list

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
	networks=($(ip route | grep "$iface" | cut -d" " -f1 | cut -d"/" -f1 | cut -d"." -f-3))
	for net in "${networks[@]}"; do
		[ "$net" != "default" ] && network_list+=("$net")
	done
else
	echo -en "\n\t[!]Error: interface not found!\n"
	exit 3
fi

tput civis
echo -en "\t[*] ${#network_list[@]} network(s) found\n"
for net in "${network_list[@]}"; do
	echo -en "\n\t[*] Scanning $net.0/24 network...\n"
	for x in {1..255}; do
		timeout 1 ping -c 1 "${net}.$x" &>/dev/null && echo -en "\t\t[+] Host discovered ${net}.$x\n" &
	done; wait
done


echo -en "\n\t[!] Scan Completed!\n\n"
tput cnorm
