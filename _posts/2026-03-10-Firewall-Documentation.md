---
title: "Panduan Lengkap UFW buat Ngamankan Firewall Linux dari Dasar"
date: 2026-03-10 00:00:00 +0700
categories: [Blue Team, SysAdmin, Linux Security]
authors: [fachri]
tags: [UFW, Firewall, Linux Security, Iptables, Networking, SysAdmin, Ubuntu, Hardening]
toc: true
comments: false
description: "Panduan lengkap UFW (Uncomplicated Firewall) di Linux: pengertian, cara kerja, command dasar, logging, konfigurasi, dan best practices firewall untuk server."
media_subpath: /content/img/firewall
---

# UFW Handbook: Panduan Lengkap Firewall Linux dari Dasar

Beli VPS baru, langsung SSH masuk. Trus lo nanya: "Udah aman belom?" Jawaban pertama yang lo butuh: firewall. Tanpa firewall, server lo kayak rumah tanpa pintu. Semua orang bisa masuk lewat port mana aja.

UFW (Uncomplicated Firewall) adalah jawaban buat lo yang males ribet sama iptables. Sintaksnya gampang, cocok buat pemula, tapi dalemnya tetep pake iptables/nftables yang udah mature. Di sini gw catet semua yang lo butuh tau soal UFW, dari dasar sampe konfigurasi yang agak advance.

## Pengertian UFW

UFW adalah frontend buat iptables. Tujuan utamanya: bikin konfigurasi firewall gak perlu nulis aturan iptables yang panjang. Lo cukup pake perintah kayak `ufw allow 80/tcp`, dan UFW bakal nerjemahin itu ke aturan iptables di belakang layar.

Firewall itu sendiri fungsinya ngontrol traffic incoming dan outgoing berdasarkan aturan. Yang boleh lewat ya lewat, yang gak ya di-drop.

UFW default tersedia di distribusi Linux kayak:
1. **Ubuntu** (pre-installed di versi terbaru)
2. **Debian**
3. **Linux Mint**
4. Turunan Debian/Ubuntu lainnya

### Tujuan utama UFW:
1. Nyederhanain konfigurasi firewall
2. Ngamankan server dari akses gak sah
3. Ngontrol port dan service yang kebuka

## Cara Kerja UFW

UFW gak mengganti iptables. Dia cuma nulis aturan iptables buat lo. Alurnya:

1. Administrator ngetik perintah UFW
2. UFW nerjemahin ke aturan iptables/nftables
3. Kernel Linux nge-apply aturan ke traffic jaringan

Jadi kalo lo pernah liat aturan iptables yang kompleks, UFW itu shortcut-nya.

## Command UFW yang Umum Dipake

### Cek Status Firewall

```bash
sudo ufw status
sudo ufw status numbered
```

Buat liat detail lebih lengkap:

```bash
sudo ufw status verbose
```

### Aktifkan / Nonaktifkan

```bash
sudo ufw enable    # Aktifin firewall
sudo ufw disable   # Matiin firewall
```

**Catatan:** pas enable pertama kali, pastiin lo udah allow SSH. Kalo enggak, lo bakal ke lock out dari server.

### Default Policy

Ini aturan dasar: gimana firewall nyikapin traffic yang gak punya aturan spesifik.

```bash
sudo ufw default deny incoming   # Tolak semua incoming
sudo ufw default allow outgoing  # Izinkan semua outgoing
```

Pola ini yang paling standar: blocking incoming, allow outgoing. Lo nambahin aturan cuma buat port yang emang perlu kebuka.

### Allow / Deny Port

```bash
sudo ufw allow 80/tcp                  # Allow HTTP
sudo ufw allow 22                       # Allow SSH (default port)
sudo ufw allow 53/tcp comment 'DNS'    # Allow + deskripsi
sudo ufw deny 21                        # Block FTP
sudo ufw deny from 192.168.1.50         # Block IP tertentu
```

Opsi `comment` penting buat dokumentasi. Beberapa bulan lagi lo bakal lupa kenapa port 1337 kebuka.

### Hapus Aturan

Bisa pake nomor atau aturan:

```bash
sudo ufw delete 3             # Hapus aturan nomor 3
sudo ufw delete allow 80/tcp  # Hapus aturan spesifik
```

### Allow dari IP Tertentu

```bash
sudo ufw allow from 192.168.1.10
sudo ufw allow from 192.168.1.10 to any port 22
sudo ufw allow from 192.168.1.10 to any port 22 proto tcp
```

Ini berguna buat ngatasin akses cuma dari IP kantor atau VPN.

### Reset Konfigurasi

```bash
sudo ufw reset
```

## Logging di UFW

Logging super penting buat monitoring dan troubleshooting. UFW nyatet setiap koneksi yang ditolak atau diizinkan.

### Aktifin Logging

```bash
sudo ufw logging on
```

### Level Logging

Ada beberapa level, dari yang paling hemat sampe paling verbose:

| Level | Penjelasan |
|-------|------------|
| off | Logging mati |
| low | Catat aktivitas dasar |
| medium | Informasi lebih detail |
| high | Logging detail |
| full | Catat semua aktivitas |

### Lokasi Log

```bash
/var/log/ufw.log
```

Buat liat langsung:

```bash
sudo less /var/log/ufw.log
sudo tail -f /var/log/ufw.log  # realtime
```

## Kelebihan UFW

1. **Sintaks simpel** - Gampang diinget dan ditulis
2. **Default policy** - Lo bisa set mindef: deny incoming, allow outgoing
3. **Comment system** - Bisa nambahin deskripsi di setiap aturan
4. **Logging bawaan** - Gak perlu setup terpisah
5. **Integrasi distribusi** - Support di Ubuntu, Debian, dan turunannya

## Kesimpulan

UFW adalah tools yang tepat buat lo yang butuh firewall fungsional tanpa ribet iptables. Buat VPS murahan atau server production skala kecil, UFW udah lebih dari cukup. Kombinasikan sama Fail2Ban dan lo udah punya pertahanan dasar yang oke.

Inget: firewall cuma salah satu layer. Masih butuh hardening lain kayak SSH key-only, auto update, dan monitoring. Tapi kalo firewall aja lo gak punya, lo basically ngundang attacker masuk.

### Takeaway Teknis

1. **Default deny incoming, allow outgoing** adalah prinsip dasar firewall yang paling aman. Lo buka port cuma yang perlu doang.
2. **Selalu allow SSH sebelum enable UFW.** Kalo lupa, lo bakal terkunci dari server dan butuh akses console buat balikin.
3. **Gunakan comment di setiap aturan.** `ufw allow 22022/tcp comment 'SSH custom port'` biar gak bingung 6 bulan lagi.
4. **Cek log secara berkala.** `/var/log/ufw.log` ngasih tau lo siapa aja yang nyoba masuk dan port mana yang lagi di-scan.
5. **UFW itu lapisan dasar**, bukan solusi tunggal. Tetep perlu IDS, monitoring, dan backup.
