#!/bin/bash
# Nama  : Fikri Alwaasi
# NIM   : 09011282530084
# Kelas : SKU3B
# Deskripsi: Script otomatis untuk pencarian, pengarsipan, verifikasi, dan pencatatan log backup.


# 2. Variabel direktori, file log, dan file list sementara di /tmp (path absolut)
NIM="09011282530084"
SRC_DIR="$HOME/data_$NIM"
DEST_DIR="$HOME/backup_$NIM"
LOG_FILE="$DEST_DIR/backup.log"
TEMP_LIST="/tmp/file_list_$NIM.txt"

# 3. Membuat direktori tujuan backup jika belum ada
mkdir -p "$DEST_DIR"

# 4 & 5. Masuk ke direktori sumber, cari file .txt, lalu arsipkan
cd "$SRC_DIR" || { echo "Direktori sumber tidak ditemukan: $SRC_DIR" >&2; exit 1; }
find . -type f -name "*.txt" > "$TEMP_LIST"

# Menghitung jumlah file .txt yang ditemukan
FILE_COUNT=$(wc -l < "$TEMP_LIST")

# Membentuk nama arsip berdasarkan waktu
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SEKARANG=$(date "+%Y-%m-%d %H:%M:%S")
ARCHIVE_NAME="backup_${NIM}_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$DEST_DIR/$ARCHIVE_NAME"

# Melakukan pengarsipan dan kompresi
tar -czvf "$ARCHIVE_PATH" -T "$TEMP_LIST"

ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | awk '{print $1}')

# 6. Verifikasi arsip tanpa mengekstraknya
echo "=== Verifikasi isi Arsip ($ARCHIVE_NAME) ==="
tar -tzvf "$ARCHIVE_PATH"

# 7. Menambahkan catatan log dengan format yang diminta
echo "$SEKARANG | $ARCHIVE_NAME | $FILE_COUNT | $ARCHIVE_SIZE" >> "$LOG_FILE"
