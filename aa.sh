#!/bin/bash

> ip_port.txt  # Kosongkan file output terlebih dahulu

while read ip; do
    echo "[*] Scanning $ip ..."

    rustscan -a "$ip" --ulimit 5000 -- -Pn -n --open |
    grep -oP '\d+/tcp' | cut -d'/' -f1 |
    sort -n | uniq | while read port; do
        echo "${ip}:${port}"
    done >> ip_port.txt

done < aa.txt

