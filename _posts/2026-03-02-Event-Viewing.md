---
title: "Bongkar Jejak Malware Lewat Windows Event Viewer Bareng PicoCTF"
date: 2026-03-02 00:00:00 +0700
categories: [Blue Team, CTF, Forensik, Windows]
authors: [fachri]
tags: [PicoCTF, IDN Networkers, Windows Forensic, Event Viewer, Base64, Windows Logs, Malware Analysis, Incident Response]
toc: true
comments: false
description: "Walkthrough forensic Event Viewing PicoCTF: analisis Windows Event Viewer untuk melacak instalasi malware, perubahan registry, dan shutdown paksa. Teknik IR dasar."
media_subpath: /content/img/eventviewing
---

# Malware di Event Viewer: Forensic PicoCTF Lewat Windows Logs

![alt text](1.png)

Bayangin lo kerja jadi SOC analyst level 1. Tiket masuk: "Employee laptop mati sendiri tiap habis login." User bilang dia abis install software dari internet, jalanin, trus laptopnya langsung restart loop. Gak ada yang bisa diakses. Yang lo punya cuma dump file Event Viewer.

Ini skenario dari challenge PicoCTF Event Viewing. Kedengerannya simpel, tapi ini menggambarkan skenario IR di dunia nyata: user gak ngerti apa yang dia install, dan lo harus reconstruct timeline dari log Windows untuk buktiin apa yang sebenernya terjadi.

## Deskripsi Soal

One of the employees at your company has had their computer infected by malware! Turns out every time they try to switch on the computer, it shuts down right after they log in. The story given by the employee is as follows:

1. They installed software using an installer they downloaded online
2. They ran the installed software but it seemed to do nothing
3. Now every time they bootup and login to their computer, a black command prompt screen quickly opens and closes and their computer shuts down instantly.

See if you can find evidence for each of these events and retrieve the flag (split into 3 pieces) from the correct logs!

## Tahap Pengerjaan

Buka file .evtx yang dikasih pake **Event Viewer** bawaan Windows. Dari deskripsi soal, flag terpecah jadi 3 bagian, masing-masing dari fase serangan yang berbeda.

### Bagian 1: Instalasi Software (Event ID 1033)

**Soal:** They installed software using an installer they downloaded online.

**Penjelasan:**

Lo perlu cari log instalasi software. Event ID yang relevan: **1033** (MsiInstaller). Kode ini nandain bahwa Windows Installer lagi nginstall atau ngonfigurasi ulang aplikasi.

Filter Event Viewer pake Event ID 1033:

![alt text](3.png)

Dari hasil filter, lo bakal liat beberapa log.

![alt text](4.png)

Tapi ada satu yang mencurigakan:

![alt text](5.png)

Sebuah string base64 nyempil di detail log. Ciri khasnya: kombinasi alfanumerik plus `=` di akhir.

![alt text](6.png)

Decode pake [CyberChef](https://gchq.github.io/CyberChef/):

![alt text](7.png)

Flag bagian 1: `picoCTF{Ev3nt_vi3wv3r_`

### Bagian 2: Eksekusi & Registry Change (Event ID 4657)

**Soal:** They ran the installed software but it seemed to do nothing.

**Penjelasan:**

Setelah instalasi, user ngejalanin softwarenya tapi gak ada yang keliatan. Kalo secara visual gak ada perubahan, biasanya malware ngubah registry.

Event ID yang relevan: **4657** (Security Log). Kode ini mencatat perubahan nilai registry: dibuat, dimodifikasi, atau dihapus.

![alt text](8.png)

Filter lagi, cari di antara log Security. Dan yap, pola yang sama muncul:

![alt text](9.png)

String base64 lain di detail log.

![alt text](10.png)

Flag bagian 2: `1s_a_pr3tty_us3ful_`

### Bagian 3: Shutdown Paksa (Event ID 1074)

**Soal:** Now every time they bootup and login to their computer, a black command prompt screen quickly opens and closes and their computer shuts down instantly.

**Penjelasan:**

Ini fase terakhir. Malware udah nginstall persistence dan sekarang tiap login langsung shutdown. Event ID **1074** dipake Windows buat catet shutdown atau restart, baik oleh user maupun aplikasi.

![alt text](11.png)

Filter Event ID 1074. Pola yang sama terulang:

![alt text](12.png)

Base64 lagi di deskripsi log.

![alt text](13.png)

Flag bagian 3: `t00l_81ba3fe9}`

### Flag Lengkap

Gabungin semua bagian:

```
Flag : picoCTF{Ev3nt_vi3wv3r_1s_a_pr3tty_us3ful_t00l_81ba3fe9}
```

## Kesimpulan

Challenge ini nunjukin gimana Event Viewer bisa jadi senjata utama buat incident response di Windows. Dari satu file .evtx, lo bisa reconstruct timeline serangan dari awal (instalasi) sampe dampak (shutdown). Yang bikin menarik: attacker gak perlu tools canggih, cukup social engineering korban buat install "software" dan malware jalan sendiri.

Di dunia nyata, kemampuan filter Event ID ini krusial. Enterprise network menghasilkan ribuan log tiap menit. Kalo lo gak tau Event ID mana yang relevan, lo bakal tenggelam.

### Takeaway Teknis

1. **Event ID 1033 (MsiInstaller)** adalah titik awal buat detect software installation. Berguna pas investigasi malware yang masuk lewat installer.
2. **Event ID 4657 (Registry Modified)** ngebantu lo liat perubahan registry yang dibuat malware. Banyak malware pake registry buat persistence atau nyimpen config.
3. **Event ID 1074 (Shutdown/Startup)** mencatat siapa atau apa yang ngerestart sistem. Di kasus ini, malware yang trigger shutdown.
4. **Base64 encoding** sering dipake buat nyembunyiin data di Windows logs. Biasain scan log untuk string dengan pola base64.
5. **Korelasi timeline** dari beberapa event ID ngasih lo gambaran utuh serangan. Satu log doang gak cukup, tapi rangkaian log yang nyambung jadi bukti.
