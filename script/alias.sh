#!/bin/bash
# Nama  : Fikri Alwaasi
# NIM   : 09011282530084
# Kelas : SKU3B
# Deskripsi: Mendefinisikan alias bk084 (bk + 3 digit terakhir NIM) untuk menjalankan script/backup.sh.
#   Eksekusi dengan: source script/alias.sh   (alias hanya hidup di shell yang memuatnya)

# 1. Aktifkan ekspansi alias agar alias juga berfungsi di script non-interaktif
shopt -s expand_aliases

# 2. Definisi alias. Baris di bawah ini disalin persis ke ~/.bashrc
alias bk084='~/uts-so-09011282530084/script/backup.sh'

# 3. Bila dijalankan langsung (dengan perintah ./alias.sh), alias hilang saat script selesai, jadi diberi petunjuk
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    echo "[INFO] Alias hanya berlaku bila dimuat dengan: source script/alias.sh"
fi
