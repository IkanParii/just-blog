---
title: "Firewall Documentation"
date: 2026-03-10 00:00:00 +0700
categories: [Blue Team,Firewall]
authors: [fachri]
tags: [UFW, Firewall, Linux Security, Iptables, Networking]
toc: true
comments: false
description: Dokumentasi lengkap UFW (Uncomplicated Firewall) di Linux — pengertian, cara kerja, command dasar, logging, dan konfigurasi firewall.
media_subpath: /content/img/firewall
---

# UFW

## Pengertian UFW

UFW (Uncomplicated Firewall) adalah alat manajemen firewall pada sistem operasi Linux yang dirancang untuk mempermudah konfigurasi firewall berbasis iptables. UFW menyediakan antarmuka yang lebih sederhana sehingga administrator dapat mengelola aturan firewall tanpa harus menulis aturan iptables yang kompleks.

Firewall sendiri berfungsi untuk mengontrol lalu lintas jaringan yang masuk (incoming) dan keluar (outgoing) berdasarkan aturan tertentu. Dengan menggunakan UFW, administrator dapat menentukan layanan mana yang boleh diakses dan mana yang harus diblokir.

UFW biasanya tersedia secara default pada beberapa distribusi Linux seperti:

1. Ubuntu
2. Debian
3. Linux Mint

Beberapa distribusi turunan lainnya

### Tujuan utama UFW adalah:

1. Menyederhanakan konfigurasi firewall
2. Mengamankan server dari akses tidak sah
3. Mengontrol port dan layanan jaringan

## Cara Kerja UFW

UFW bekerja dengan mengelola aturan firewall yang sebenarnya dijalankan oleh iptables atau nftables di tingkat kernel Linux.

Alur kerjanya secara sederhana:

1. Administrator membuat aturan menggunakan perintah UFW.
2. UFW menerjemahkan aturan tersebut menjadi aturan iptables.
3. Kernel Linux menerapkan aturan tersebut pada lalu lintas jaringan.

### Contoh penggunaan:

1. Mengizinkan akses SSH
2. Memblokir port tertentu
3. Membatasi akses dari alamat IP tertentu

## Command UFW yang Umum Digunakan

### Mengecek Status UFW

```bash
sudo ufw status
sudo ufw status numbered
```

Menampilkan apakah firewall aktif atau tidak serta daftar aturan yang sedang berlaku

Untuk informasi yang lebih lengkap:

```bash
sudo ufw status verbose
```
### Mengaktifkan UFW

```bash
sudo ufw enable
```

Perintah ini digunakan untuk mengaktifkan firewall UFW.

### Menonaktifkan UFW

```bash
sudo ufw disable
```

Digunakan untuk mematikan firewall.

### Mengatur Kebijakan Default (Default Policy)
Default policy menentukan bagaimana firewall memperlakukan semua koneksi yang tidak memiliki aturan khusus

```bash
sudo ufw default deny incoming # Tolak semua incoming traffic
sudo ufw default allow outgoing # Izinkan semua outgoing traffic
```

### Mengizinkan Akses Port

```bash
sudo ufw allow 80/tcp
sudo ufw allow 22
```

Mengizinkan akses ke port 80 (HTTP).

Contoh lain:

```bash
sudo ufw allow 53/tcp comment 'DNS TCP'
```
Mengizinkan akses SSH.

### Memblokir Akses Port

```bash
sudo ufw deny 21
```
Memblokir akses ke port 21 (FTP).

### Menghapus Aturan Firewall

Untuk menghapus aturan:

```bash
sudo ufw delete (Nomor Rules)
```

### Mengizinkan Akses dari IP Tertentu

Contoh mengizinkan IP tertentu mengakses server:
```bash
sudo ufw allow from 192.168.1.10
```

Atau ke port tertentu:
```bash
sudo ufw allow from 192.168.1.10 to any port 22
sudo ufw allow from 192.168.1.10 to any port 22 proto tcp
```

### Menolak Akses dari IP Tertentu

```bash
sudo ufw deny from 192.168.1.50 to any
```
Digunakan untuk memblokir IP tertentu.
### Reset Konfigurasi UFW

```bash
sudo ufw reset
```

## Logging pada UFW

UFW menyediakan fitur logging untuk mencatat aktivitas firewall, seperti koneksi yang ditolak atau diizinkan.

Logging ini berguna untuk:

1. Monitoring keamanan

2. Analisis serangan

3. Troubleshooting jaringan

Mengaktifkan Logging

```bash
sudo ufw logging on
```

Level Logging

UFW menyediakan beberapa tingkat logging:

| Level | Penjelasan |
| -------- | -------- |
| off| Logging dimatikan |
| low | Mencatat aktivitas dasar firewall |
| medium | Mencatat lebih banyak informasi |
| high | Logging lebih detail |
| full | Mencatat semua aktivitas jaringan |

### Lokasi File Log

Log UFW biasanya disimpan pada:
```bash
/var/log/ufw.log
```
Untuk melihat isi log:
```bash
sudo less /var/log/ufw.log
```
Atau secara realtime:
```bash
sudo tail -f /var/log/ufw.log
```

## Kelebihan UFW

Beberapa kelebihan menggunakan UFW:

1. Mudah digunakan dibanding iptables

2. Sintaks sederhana

3. Mendukung IPv4 dan IPv6

4. Terintegrasi dengan banyak distribusi Linux

## Kesimpulan

UFW merupakan firewall sederhana yang mempermudah administrator Linux dalam mengelola keamanan jaringan. Dengan menggunakan perintah yang mudah dipahami, administrator dapat mengontrol akses jaringan, mengizinkan layanan tertentu, serta memonitor aktivitas firewall melalui fitur logging.