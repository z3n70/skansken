#!/bin/bash

# Cek apakah argumen domain diberikan
if [ $# -ne 1 ]; then
  echo "Penggunaan: $0 <domain>"
  exit 1
fi

# Mendapatkan domain dari argumen
DOMAIN=$1

# Menampilkan pilihan wordlist
echo "Pilih wordlist:"
echo "1. raft-medium-directories.txt"
echo "2. all.txt"
echo "3. dicc.txt"
echo "4. dick.txt"
echo "5. directory-list-2.3-small.txt"

# Meminta input dari pengguna untuk memilih wordlist
read -p "Masukkan pilihan (1-5): " CHOICE

# Menentukan path wordlist berdasarkan pilihan
case $CHOICE in
  1) WORDLIST=~/Hacking/tools/SecLists/Discovery/Web-Content/raft-medium-directories.txt ;;
  2) WORDLIST=/Users/little_boy/Hacking/tools/dir/dirsearch/db/all.txt ;;
  3) WORDLIST=/Users/little_boy/Hacking/tools/dir/dirsearch/db/dicc.txt ;;
  4) WORDLIST=/Users/little_boy/Hacking/tools/dir/dirsearch/db/dick.txt ;;
  5) WORDLIST=/Users/little_boy/Hacking/tools/dir/dirsearch/db/directory-list-2.3-small.txt ;;
  *) echo "Pilihan tidak valid"; exit 1 ;;
esac

# Jalankan feroxbuster dengan wordlist yang dipilih
feroxbuster --url "$DOMAIN" -w "$WORDLIST" --scan-dir-listings
