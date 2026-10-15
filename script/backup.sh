#!/bin/bash
# Nama        : Fikri Alwaasi
# NIM         : 09011282530084
# Kelas       : SKU3B
# Deskripsi   : Script otomatis untuk pencarian, pengarsipan, verifikasi, pencatatan log, dan rotasi backup.

#  Variabel direktori, file log, dan file list sementara di /tmp (path absolut)
NIM="09011282530084"
SRC_DIR="$HOME/data_$NIM"
DEST_DIR="$HOME/backup_$NIM"
LOG_FILE="$DEST_DIR/backup.log"
TEMP_LIST="/tmp/file_list_$NIM.txt"

# Membuat direktori tujuan backup jika belum ada
mkdir -p "$DEST_DIR"

# Masuk ke direktori sumber dan cari file .txt
cd "$SRC_DIR" || { echo "Direktori sumber tidak ditemukan: $SRC_DIR" >&2; exit 1; }
find . -type f -name "*.txt" > "$TEMP_LIST"

#  Menghitung jumlah file .txt yang ditemukan
FILE_COUNT=$(wc -l < "$TEMP_LIST")

# Membentuk timestamp dan format waktu saat ini
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SEKARANG=$(date "+%Y-%m-%d %H:%M:%S") # Menyimpan stempel waktu saat proses backup dijalankan

# Menentukan nama dan path lengkap arsip backup
ARCHIVE_NAME="backup_${NIM}_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$DEST_DIR/$ARCHIVE_NAME"

# Melakukan pengarsipan dan kompresi dengan pengaman error
tar -czvf "$ARCHIVE_PATH" -T "$TEMP_LIST" || { echo "Gagal membuat arsip" >&2; exit 1; }

# Mengambil ukuran arsip yang telah berhasil dibuat
ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | awk '{print $1}') # Menyimpan informasi ukuran file arsip (human-readable)

# Verifikasi isi arsip tanpa mengekstraknya
echo "=== Verifikasi isi Arsip ($ARCHIVE_NAME) ==="
tar -tzvf "$ARCHIVE_PATH"

# Menambahkan catatan log dengan format yang diminta
echo "$SEKARANG | $ARCHIVE_NAME | $FILE_COUNT | $ARCHIVE_SIZE" >> "$LOG_FILE"

# Fitur Pengembangan: Rotasi arsip (menyimpan maksimal 5 arsip terbaru)
cd "$DEST_DIR" || exit 1
ls -t backup_${NIM}_*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm --

#  Membersihkan file list sementara di /tmp agar tidak menumpuk
rm -f "$TEMP_LIST"
