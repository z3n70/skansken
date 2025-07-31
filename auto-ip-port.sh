#!/bin/bash

> ip_port.txt

scan_ip() {
    ip="$1"
    echo "[*] Scanning $ip ..." >&2
    nmap -Pn -n --open -p- "$ip" | \
    awk -v ip="$ip" '/^[0-9]+\/tcp/ { split($1,p,"/"); print ip ":" p[1] }'
}

export -f scan_ip
cat ip.txt | parallel -j10 scan_ip >> ip_port.txt
