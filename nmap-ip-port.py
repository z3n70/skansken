#!/usr/bin/env python3

import subprocess
import time
import sys

# Validasi Python package
try:
    from tqdm import tqdm
except ImportError:
    print("[!] Modul 'tqdm' belum terpasang.")
    print("    Jalankan: pip install tqdm")
    sys.exit(1)

# Validasi Nmap
def is_installed(cmd):
    return subprocess.call(f"command -v {cmd}", shell=True, stdout=subprocess.DEVNULL, 
stderr=subprocess.DEVNULL) == 0

if not is_installed("nmap"):
    print("[!] Nmap belum terinstal. Silakan install terlebih dahulu.")
    sys.exit(1)

input_file = "ip.txt"
output_file = "ip_port.txt"

# Baca IP dari file
try:
    with open(input_file, "r") as f:
        ips = [line.strip() for line in f if line.strip()]
except FileNotFoundError:
    print(f"[!] File {input_file} tidak ditemukan.")
    sys.exit(1)

print(f"[*] Memulai scanning untuk {len(ips)} IP...\n")

results = set()
start = time.time()

# Scanning dengan tqdm
for ip in tqdm(ips, desc="Scanning", unit="ip"):
    tqdm.write(f"   [>] Scanning: {ip}")
    try:
        # Jalankan nmap untuk IP
        proc = subprocess.run(
            ["nmap", "-Pn", "-p-", "--open", ip],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True
        )
        for line in proc.stdout.splitlines():
            if "/tcp" in line and "open" in line:
                port = line.strip().split("/")[0]
                results.add(f"{ip}:{port}")
    except Exception as e:
        tqdm.write(f"[!] Gagal scan {ip}: {e}")

# Simpan hasil
with open(output_file, "w") as f:
    for r in sorted(results):
        f.write(r + "\n")

elapsed = int(time.time() - start)
print(f"\n[✓] Scanning selesai dalam {elapsed} detik.")
print(f"[+] Hasil tersimpan di: {output_file}")
