#!/bin/bash
# Nama  : Fikri Alwaasi
# NIM   : 09011282530084
# Kelas : SKU3B
# Deskripsi: Script backup otomatis berulang di background dengan manajemen PID sleep agar berhenti dengan bersih

# 1. Menentukan interval jeda waktu bawaan (default: 60 detik)
INTERVAL=60

# Variabel untuk menyimpan PID proses sleep agar bisa di-kill secara presisi
SLEEP_PID=""

# 2. Menentukan lokasi absolut dari script/backup.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$SCRIPT_DIR/backup.sh"

# 3. Validasi keberadaan script backup dan arahkan error ke stderr
if [ ! -x "$BACKUP_SCRIPT" ]; then
    echo "[ERROR] Script $BACKUP_SCRIPT tidak ditemukan atau tidak memiliki izin eksekusi." >&2
    exit 1
fi

# 4. Trap menangkap sinyal (SIGINT/SIGTERM), mematikan proses sleep aktif, lalu keluar bersih
trap 'echo -e "\n[INFO] Loop backup dihentikan oleh pengguna."; kill "$SLEEP_PID" 2>/dev/null; exit 0' SIGINT SIGTERM

echo "=================================================="
echo "Memulai Loop Backup Otomatis (PID: $$)"
echo "Jeda Waktu (INTERVAL) : $INTERVAL detik"
echo "Script Target         : $BACKUP_SCRIPT"
echo "=================================================="

# 5. Perulangan utama
while true; do
    CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$CURRENT_TIME] Menjalankan proses backup..."

    # Menjalankan script backup.sh
    "$BACKUP_SCRIPT"

    COMPLETION_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$COMPLETION_TIME] Backup selesai. Menunggu $INTERVAL detik..."
    echo "--------------------------------------------------"

    # Menjalankan sleep di background dan menangkap PID-nya
    sleep "$INTERVAL" &
    SLEEP_PID=$!

    # Menunggu proses sleep selesai (atau terinterupsi oleh trap)
    wait "$SLEEP_PID"
done
