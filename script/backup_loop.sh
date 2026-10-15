#!/bin/bash
# Nama  : Fikri Alwaasi
# NIM   : 09011282530084
# Kelas : SKU3B
# Deskripsi: Menjalankan backup.sh berulang dengan jeda INTERVAL detik.
# Aman dijalankan di background (&) dan dihentikan dengan kill.

# 1. Variabel konfigurasi (ubah di sini tanpa menyunting bagian lain)
# INTERVAL bernilai bawaan 60 detik, bisa diganti saat menjalankan:
# INTERVAL=5 ./backup_loop.sh &
INTERVAL="${INTERVAL:-60}"
TIME_FORMAT='+%Y-%m-%d %H:%M:%S'
GARIS_TEBAL="=================================================="
GARIS_TIPIS="--------------------------------------------------"
SLEEP_PID=""  # PID proses sleep yang sedang aktif, dipakai oleh trap

# 2. Lokasi absolut backup.sh agar aman dijalankan dari direktori mana pun
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$SCRIPT_DIR/backup.sh"

# 3. Validasi: backup.sh harus ada dan dapat dieksekusi
if [ ! -x "$BACKUP_SCRIPT" ]; then
    echo "[ERROR] Script $BACKUP_SCRIPT tidak ditemukan atau tidak memiliki izin eksekusi." >&2
    exit 1
fi

# 4. Fungsi bantu: penanda waktu (format diatur oleh TIME_FORMAT)
timestamp() {
    date "$TIME_FORMAT"
}

# 5. Penghentian bersih: hentikan sleep yang aktif, lalu keluar
berhenti() {
    echo -e "\n[INFO] Loop backup dihentikan."
    [ -n "$SLEEP_PID" ] && kill "$SLEEP_PID" 2>/dev/null
    exit 0
}
trap berhenti SIGINT SIGTERM SIGHUP

# 6. Informasi awal
echo "$GARIS_TEBAL"
echo "Memulai Loop Backup Otomatis (PID: $$)"
echo "Jeda Waktu (INTERVAL) : $INTERVAL detik"
echo "Script Target         : $BACKUP_SCRIPT"
echo "$GARIS_TEBAL"

# 7. Perulangan utama
while true; do
    echo "[$(timestamp)] Menjalankan proses backup..."

    "$BACKUP_SCRIPT" || echo "[WARN] backup.sh keluar dengan status $?" >&2

    echo "[$(timestamp)] Backup selesai. Menunggu $INTERVAL detik..."
    echo "$GARIS_TIPIS"

    # sleep dijalankan di background + wait, supaya trap bisa langsung bereaksi
    sleep "$INTERVAL" &
    SLEEP_PID=$!
    wait "$SLEEP_PID"
    SLEEP_PID=""
done
