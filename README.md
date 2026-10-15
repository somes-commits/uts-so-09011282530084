# UTS Sistem Operasi: Otomasi Backup dan Job Control

Repositori ini berisi tiga shell script Bash yang mencari file `.txt` di direktori sumber, mengarsipkannya menjadi satu file `.tar.gz` bernama tanggal dan jam, mencatat setiap proses backup ke file log, lalu menjalankannya berulang di background dengan job control.

```text
uts-so-09011282530084/
├── README.md
├── nim.txt
└── script/
    ├── backup.sh
    ├── backup_loop.sh
    └── alias.sh
```


## 1. Identitas

- **Nama:** Fikri Alwaasi
- **NIM:** 09011282530084
- **Kelas:** SKU3B


## 2. Deskripsi

Semua nama mengikuti ketentuan NIM:

| Komponen | Nama yang dipakai |
|---|---|
| File identitas | `nim.txt` |
| Direktori sumber | `~/data_09011282530084` |
| Direktori tujuan backup | `~/backup_09011282530084` |
| Nama arsip | `backup_09011282530084_TANGGAL_JAM.tar.gz` |
| File log | `~/backup_09011282530084/backup.log` |
| Alias | `bk084` |
| Repositori | `uts-so-09011282530084` |

### `script/backup.sh`

Script utama. Direktori sumber, direktori tujuan, dan nama file log disimpan dalam variabel di bagian atas script, sehingga lokasinya bisa diubah tanpa menyunting bagian lain. Alur kerjanya:

1. Membuat direktori tujuan dengan `mkdir -p` jika belum ada.
2. Pindah ke direktori sumber dengan `cd`. Jika direktori tidak ditemukan, script berhenti dengan pesan error.
3. Mencari semua file `.txt`, termasuk di subdirektori, dengan `find . -type f -name "*.txt"`, lalu menyimpan daftarnya ke file teks sementara di `/tmp`.
4. Menghitung jumlah file dari daftar itu dengan `wc -l`.
5. Membuat nama arsip `backup_NIM_TANGGAL_JAM.tar.gz`. Tanggal dan jam diambil dari `date +%Y%m%d_%H%M%S`.
6. Membuat arsip dengan `tar -czvf ... -T <daftar>`, sehingga arsip hanya berisi file `.txt`. Path di dalam arsip relatif, misalnya `./sub1/catatan1.txt`. Jika `tar` gagal, script berhenti.
7. Membaca ukuran arsip dengan `du -h`.
8. Menampilkan isi arsip dengan `tar -tzvf` tanpa mengekstraknya.
9. Menambahkan tepat satu baris ke file log dengan redirect `>>`, sehingga isi lama tidak tertimpa.
10. Menjalankan rotasi arsip (lihat bagian 4).
11. Menghapus file daftar sementara di `/tmp`.

Format satu baris log (dipisah spasi, garis tegak, spasi): tanggal dan jam, nama arsip, jumlah file, ukuran arsip. Contoh baris yang benar-benar dihasilkan script:

```text
2026-10-14 21:03:44 | backup_09011282530084_20261014_210344.tar.gz | 14 | 4.0K
```

### `script/backup_loop.sh`

Menjalankan `backup.sh` berulang di background.

- Jeda antar-backup disimpan di variabel `INTERVAL` dengan nilai bawaan 60 detik. Nilainya bisa diganti saat menjalankan, misalnya `INTERVAL=10 ./script/backup_loop.sh &`.
- Lokasi `backup.sh` dihitung dari lokasi script itu sendiri, sehingga `backup_loop.sh` bisa dijalankan dari direktori mana pun.
- Sebelum loop dimulai, script memeriksa bahwa `backup.sh` ada dan memiliki izin eksekusi. Jika tidak, script berhenti dengan pesan error.
- Loop utama memakai `while true`. Setiap putaran menjalankan `backup.sh`, mencetak penanda waktu, lalu menunggu sepanjang `INTERVAL` detik.
- `sleep` dijalankan di background lalu ditunggu dengan `wait`, supaya sinyal `kill` atau Ctrl+C langsung ditangani tanpa menunggu `sleep` selesai.
- Sinyal `SIGINT`, `SIGTERM`, dan `SIGHUP` ditangkap dengan `trap`. Fungsi penanganannya menghentikan `sleep` yang sedang aktif, mencetak pesan, lalu keluar dengan bersih.

### `script/alias.sh`

Mendefinisikan alias `bk084` (`bk` + 3 digit terakhir NIM) yang menjalankan `script/backup.sh`. Baris alias yang sama disalin ke `~/.bashrc`. Karena alias hanya hidup di shell yang memuatnya, file ini dipakai dengan `source`. Jika dijalankan langsung dengan `./alias.sh`, script menampilkan petunjuk tersebut.


## 3. Cara Menjalankan

Persiapankan sekali saja, dari folder repositori:

```bash
cd ~/uts-so-09011282530084
chmod +x script/*.sh
```

Direktori sumber `~/data_09011282530084` harus sudah berisi file `.txt` (termasuk di subdirektori) dan file berekstensi lain yang sengaja tidak ikut diarsipkan.

**`backup.sh`: backup satu kali**

```bash
./script/backup.sh
tail -n 1 ~/backup_09011282530084/backup.log    # lihat baris log terbaru
```

**`backup_loop.sh`: backup berulang di background**

```bash
./script/backup_loop.sh &                  # jeda bawaan 60 detik
INTERVAL=10 ./script/backup_loop.sh &      # jeda 10 detik

jobs -l                                    # lihat nomor job dan PID
kill %1                                    # hentikan job nomor 1 (atau: kill <PID>)
```

**`alias.sh`: alias `bk084`**

```bash
source script/alias.sh
bk084
```

Agar alias berlaku di setiap terminal baru, baris alias yang sama disalin ke `~/.bashrc` (cukup sekali):

```bash
echo "alias bk084='~/uts-so-09011282530084/script/backup.sh'" >> ~/.bashrc
source ~/.bashrc
```


## 4. Fitur Pengembangan

**Fitur yang dipilih: rotasi arsip.** Setelah backup dan pencatatan log selesai, `backup.sh` hanya menyimpan 5 arsip terbaru di `~/backup_09011282530084` dan menghapus arsip yang lebih lama. Perintah yang dipakai:

```bash
cd "$DEST_DIR" || exit 1
ls -t backup_${NIM}_*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm --
```

Cara kerjanya: `ls -t` mengurutkan arsip dari yang terbaru, `tail -n +6` mengambil arsip ke-6 dan seterusnya (yang lebih lama dari 5 terbaru), lalu `xargs -r rm --` menghapusnya. Hanya file yang cocok dengan pola `backup_NIM_*.tar.gz` yang disentuh, sehingga `backup.log` tidak ikut terhapus dan riwayat log tetap utuh.

**Cara mencobanya:** jalankan backup 7 kali dengan jeda 1 detik, lalu hitung arsip yang tersisa.

```bash
for i in 1 2 3 4 5 6 7; do ./script/backup.sh > /dev/null; sleep 1; done
ls ~/backup_09011282530084/*.tar.gz | wc -l
```

Hasil yang diharapkan: `5`. Jeda `sleep 1` diperlukan karena nama arsip hanya setelitian detik. Dua backup dalam detik yang sama akan menghasilkan nama yang sama dan jumlah arsip tidak bertambah.


## 5. Bukti Job Control

```text
fikr@fikr-VirtualBox:~/uts-so-09011282530084$ ./script/backup_loop.sh &
[1] 8366
fikr@fikr-VirtualBox:~/uts-so-09011282530084$ ==================================================
Memulai Loop Backup Otomatis (PID: 8366)
Jeda Waktu (INTERVAL) : 60 detik
Script Target         : /home/fikr/uts-so-09011282530084/script/backup.sh
==================================================
[2026-10-15 21:13:30] Menjalankan proses backup...
./file7.txt
./file1.txt
./file2.txt
./file8.txt
./file5.txt
./file6.txt
./file4.txt
./sub2/tugas2.txt
./sub2/tugas1.txt
./sub1/catatan2.txt
./sub1/catatan1.txt
./file10.txt
./file9.txt
./file3.txt
=== Verifikasi isi Arsip (backup_09011282530084_20261015_211330.tar.gz) ===
-rw-rw-r-- fikr/fikr         0 2026-10-14 20:08 ./file7.txt
-rw-rw-r-- fikr/fikr         0 2026-10-14 20:08 ./file1.txt
-rw-rw-r-- fikr/fikr         0 2026-10-14 20:08 ./file2.txt
-rw-rw-r-- fikr/fikr         0 2026-10-14 20:08 ./file8.txt
-rw-rw-r-- fikr/fikr         0 2026-10-14 20:08 ./file5.txt
-rw-rw-r-- fikr/fikr         0 2026-10-14 20:08 ./file6.txt
-rw-rw-r-- fikr/fikr         0 2026-10-14 20:08 ./file4.txt
-rw-rw-r-- fikr/fikr         0 2026-10-14 20:09 ./sub2/tugas2.txt
-rw-rw-r-- fikr/fikr         0 2026-10-14 20:09 ./sub2/tugas1.txt
-rw-rw-r-- fikr/fikr         0 2026-10-14 20:09 ./sub1/catatan2.txt
-rw-rw-r-- fikr/fikr         0 2026-10-14 20:09 ./sub1/catatan1.txt
-rw-rw-r-- fikr/fikr         0 2026-10-14 20:08 ./file10.txt
-rw-rw-r-- fikr/fikr         0 2026-10-14 20:08 ./file9.txt
-rw-rw-r-- fikr/fikr         0 2026-10-14 20:08 ./file3.txt
[2026-10-15 21:13:30] Backup selesai. Menunggu 60 detik...
--------------------------------------------------

fikr@fikr-VirtualBox:~/uts-so-09011282530084$ jobs -l
[1]+  8366 Running                    ./script/backup_loop.sh &
fikr@fikr-VirtualBox:~/uts-so-09011282530084$ fg
./script/backup_loop.sh
^Z
[1]+  Stopped                    ./script/backup_loop.sh
fikr@fikr-VirtualBox:~/uts-so-09011282530084$ bg
[1]+ ./script/backup_loop.sh &
fikr@fikr-VirtualBox:~/uts-so-09011282530084$ ps x
    PID TTY      STAT   TIME COMMAND
   6830 ?        Ss     0:00 /usr/lib/systemd/systemd --user
   6832 ?        S      0:00 (sd-pam)
   6852 ?        Ss     0:00 /usr/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activ
   6853 ?        S<sl   0:00 /usr/bin/pipewire
   6862 ?        SLsl   0:00 /usr/bin/gnome-keyring-daemon --foreground --components=pkcs11,secrets --control-direc
   6865 ?        Ss     0:00 /usr/bin/mpris-proxy
   6866 ?        S<sl   0:00 /usr/bin/wireplumber
   6867 ?        Ssl    0:00 /usr/bin/pipewire -c filter-chain.conf
   6870 ?        S<sl   0:00 /usr/bin/pipewire-pulse
   6920 tty2     Ssl+   0:00 /usr/libexec/gdm-wayland-session /usr/bin/gnome-session --session=ubuntu
   6944 tty2     Sl+    0:00 /usr/libexec/gnome-session-init-worker ubuntu
   7063 ?        Ssl    0:00 /usr/libexec/xdg-document-portal
   7074 ?        Ssl    0:00 /usr/libexec/gcr-ssh-agent --base-dir /run/user/1000/gcr
   7076 ?        Ssl    0:00 /usr/libexec/gnome-session-ctl --monitor
   7077 ?        Ss     0:00 /usr/bin/ssh-agent -D
   7080 ?        Ssl    0:00 /usr/libexec/xdg-permission-store
   7093 ?        Ssl    0:00 /usr/libexec/gvfsd
   7106 ?        Sl     0:00 /usr/libexec/gvfsd-fuse /run/user/1000/gvfs -f
   7112 ?        Ssl    0:00 /usr/libexec/gnome-session-service --session=ubuntu
   7143 ?        Ssl    0:07 /usr/bin/gnome-shell --mode=ubuntu
   7242 ?        Ssl    0:00 /usr/libexec/at-spi-bus-launcher
   7255 ?        S      0:00 /usr/bin/dbus-daemon --config-file=/usr/share/defaults/at-spi2/accessibility.conf --no
   7267 ?        Sl     0:00 /usr/libexec/at-spi2-registryd --use-gnome-session
   7282 ?        Sl     0:00 /usr/libexec/gnome-shell-calendar-server
   7290 ?        Ssl    0:00 /usr/libexec/evolution-source-registry
   7302 ?        Sl     0:00 /usr/bin/gjs -m /usr/share/gnome-shell/org.gnome.Shell.Notifications
   7315 ?        Ssl    0:00 /usr/bin/ibus-daemon --panel disable
   7319 ?        Ssl    0:00 /usr/libexec/gsd-a11y-settings
   7324 ?        Ssl    0:00 /usr/libexec/gsd-color
   7325 ?        Ssl    0:00 /usr/libexec/gsd-datetime
   7326 ?        Sl     0:00 /usr/libexec/goa-daemon
   7328 ?        Ssl    0:00 /usr/libexec/gsd-housekeeping
   7333 ?        Ssl    0:00 /usr/libexec/gsd-keyboard
   7334 ?        Ssl    0:00 /usr/libexec/gsd-media-keys
   7336 ?        Ssl    0:00 /usr/libexec/gsd-power
   7337 ?        Ssl    0:00 /usr/libexec/gsd-print-notifications
   7338 ?        Ssl    0:00 /usr/libexec/gsd-rfkill
   7339 ?        Ssl    0:00 /usr/libexec/gsd-screensaver-proxy
   7345 ?        Ssl    0:00 /usr/libexec/gsd-sharing
   7354 ?        Sl     0:00 /usr/libexec/gsd-disk-utility-notify
   7357 ?        Sl     0:00 /usr/libexec/evolution-data-server/evolution-alarm-notify
   7367 ?        Sl     0:00 /usr/bin/update-notifier
   7374 ?        Ssl    0:00 /usr/libexec/gsd-smartcard
   7378 ?        Ssl    0:00 /usr/libexec/gsd-sound
   7382 ?        Ssl    0:00 /usr/libexec/gsd-usb-protection
   7429 ?        Ssl    0:00 /usr/libexec/gsd-wwan
   7451 ?        S      0:00 /usr/bin/Xwayland :0 -rootless -noreset -accessx -core -auth /run/user/1000/.mutter-Xw
   7502 ?        Sl     0:00 /usr/libexec/ibus-dconf
   7503 ?        Sl     0:01 /usr/libexec/ibus-extension-gtk3
   7504 ?        Ssl    0:00 /usr/libexec/evolution-calendar-factory
   7512 ?        Sl     0:00 /usr/libexec/goa-identity-service
   7513 ?        Sl     0:00 /usr/libexec/ibus-portal
   7518 ?        Ssl    0:00 /usr/libexec/gvfs-udisks2-volume-monitor
   7541 ?        SNsl   0:00 /usr/libexec/localsearch-3
   7545 ?        Ssl    0:00 /usr/libexec/xdg-desktop-portal
   7554 ?        Sl     0:00 /usr/libexec/gsd-printer
   7560 ?        Ssl    0:00 /usr/libexec/gvfs-gphoto2-volume-monitor
   7573 ?        Ssl    0:00 /usr/libexec/xdg-desktop-portal-gnome
   7590 ?        Sl     0:00 /usr/bin/gjs -m /usr/share/gnome-shell/org.gnome.ScreenSaver
   7621 ?        Ssl    0:00 /usr/libexec/evolution-addressbook-factory
   7622 ?        Ssl    0:00 /usr/libexec/gvfs-mtp-volume-monitor
   7640 ?        Ssl    0:00 /usr/libexec/gvfs-afc-volume-monitor
   7653 ?        Ssl    0:00 /usr/libexec/gvfs-goa-volume-monitor
   7678 ?        Sl     0:00 /usr/libexec/ibus-engine-simple
   7701 ?        Sl     0:00 gjs /usr/share/gnome-shell/extensions/ding@rastersoft.com/app/ding.js -E -P /usr/share
   7772 ?        Ssl    0:00 /usr/libexec/gvfsd-metadata
   7825 ?        Ssl    0:00 /usr/libexec/dconf-service
   7847 ?        Sl     0:00 /usr/libexec/gvfsd-trash --spawner :1.20 /org/gtk/gvfs/exec_spaw/0
   7894 ?        Ssl    0:00 /usr/libexec/gsd-xsettings
   7924 ?        S      0:00 /usr/bin/VBoxClient --clipboard
   7926 ?        Sl     0:00 /usr/bin/VBoxClient --clipboard
   7928 ?        Sl     0:00 /usr/libexec/mutter-x11-frames
   7957 ?        S      0:00 /usr/bin/VBoxClient --vmsvga
   7958 ?        Sl     0:00 /usr/bin/VBoxClient --vmsvga
   7989 ?        Sl     0:00 /usr/libexec/ibus-x11
   8058 ?        Sl     0:01 /usr/bin/ptyxis --gapplication-service
   8070 ?        Ssl    0:00 /usr/libexec/xdg-desktop-portal-gtk
   8105 ?        Ssl    0:00 /usr/libexec/ptyxis-agent --socket-fd=3 --rlimit-nofile=1024
   8139 pts/0    Ss     0:00 /usr/bin/bash
   8170 ?        Ssl    0:00 /snap/snapd-desktop-integration/391/usr/bin/user-session-helper /snap/snapd-desktop-in
   8232 ?        Sl     0:00 /snap/snapd-desktop-integration/391/usr/bin/snapd-desktop-integration
   8366 pts/0    S      0:00 /bin/bash ./script/backup_loop.sh
   8395 pts/0    S      0:00 sleep 60
   8406 pts/0    R+     0:00 ps x
fikr@fikr-VirtualBox:~/uts-so-09011282530084$ kill %1

[INFO] Loop backup dihentikan.
[1]+  Done                       ./script/backup_loop.sh
```


## 6. Kendala dan Solusi

**Kendala 1: error `du: cannot access ... No such file or directory`**
- **Penyebab:** baris `du` untuk membaca ukuran arsip tertulis sebelum `tar` membuat arsip, sehingga file yang diukur belum ada. Akibatnya kolom ukuran pada baris log juga kosong.
- **Solusi:** memindahkan baris `ARCHIVE_SIZE=$(du ...)` ke bawah perintah `tar`. Hasilnya dicek dengan `./script/backup.sh` (tanpa pesan error) dan `tail -n 1 backup.log` (keempat kolom terisi).

**Kendala 2: format tanggal pada log salah**
- **Penyebab:** saat mengganti nama variabel waktu, format `date` salah ketik sehingga tanggal tercatat `20261014 20:56:46`, bukan `2026-10-14 20:56:46`.
- **Solusi:** memperbaiki format menjadi `date "+%Y-%m-%d %H:%M:%S"`, menjalankan ulang script, lalu memeriksa baris log terbaru dengan `tail -n 1`. Baris lama yang salah tetap ada karena log memakai `>>`, tetapi tidak memengaruhi baris baru.

**Kendala 3: path absolut pada isi arsip**
- **Penyebab:** versi awal script memakai `find "$SRC_DIR"`, sehingga daftar file berisi path absolut. `tar` menghapus tanda `/` di depan path dan menampilkan peringatan, yang awalnya saya bungkam dengan `2>/dev/null`. Cara itu juga menyembunyikan error yang sungguhan.
- **Solusi:** script pindah ke direktori sumber dengan `cd` lalu memakai `find .`, sehingga path relatif. Setelah itu `2>/dev/null` pada `tar` dihapus dan ditambahkan pengaman `|| { ...; exit 1; }`.
