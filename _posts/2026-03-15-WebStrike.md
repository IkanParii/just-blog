---
title: "Webshell dan RCE Lewat PCAP Serangan Web Bareng CyberDefenders"
date: 2026-03-15 00:00:00 +0700
categories: [Blue Team, CTF, Forensik, Web Security]
authors: [fachri]
tags: [CyberDefenders, IDN Networkers, Web Shell, PCAP Analysis, Wireshark, RCE, Web Security, Incident Response]
toc: true
comments: false
description: "Walkthrough forensic WebStrike CyberDefenders: analisis PCAP serangan web shell upload, RCE, dan eksfiltrasi data via curl. Teknik network forensic."
media_subpath: /content/img/webstrike
---

# Webshell & RCE: Analisis PCAP Serangan Web dari CyberDefenders

![alt text](1.png)

Salah satu serangan web yang paling umum tapi bahaya: **file upload vulnerability**. Attacker upload file PHP yang disamarin jadi gambar, dapet akses ke server, dan tinggal jalanin perintah remote. Di challenge CyberDefenders WebStrike ini, lo bakal investigasi PCAP dari serangan yang exactly kayak gitu.

Dari file PCAP, lo bisa track seluruh lifecycle serangan: dari mana attacker berasal, gimana cara dia upload webshell, sampe data apa yang dicuri.

## Deskripsi Soal

A suspicious file was identified on a company web server, raising alarms within the intranet. The Development team flagged the anomaly, suspecting potential malicious activity. To address the issue, the network team captured critical network traffic and prepared a PCAP file for review.

Your task is to analyze the provided PCAP file to uncover how the file appeared and determine the extent of any unauthorized activity.

## Tahap Pengerjaan

### Soal 1: Lokasi Geografis Attacker

**Soal:** Identifying the geographical origin of the attack facilitates the implementation of geo-blocking measures and the analysis of threat intelligence. From which city did the attack originate?

**Penjelasan:**

Buka PCAP dan cari komunikasi pertama. IP yang initiate TCP handshake pertama adalah `117.11.88.124`. Ini IP attacker.

![alt text](2.png)

Cek geolocation IP pake [ipgeolocation.io](https://ipgeolocation.io/):

![alt text](3.png)

Attacker berasal dari **Tianjin**, China. Informasi ini berguna buat geo-blocking atau setidaknya jadi indikator buat monitoring.

**Jawaban:** `Tianjin`

### Soal 2: User-Agent Attacker

**Soal:** Knowing the attacker's User-Agent assists in creating robust filtering rules. What's the attacker's Full User-Agent?

**Penjelasan:**

Cari packet HTTP di Wireshark untuk liat User-Agent. Filter pake `http` atau langsung follow HTTP stream.

![alt text](4.png)

![alt text](5.png)

User-Agent:

```
Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0
```

Ini Firefox di Linux. Tapi inget, User-Agent gampang dipalsuin. Jangan terlalu percaya.

**Jawaban:** `Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0`

### Soal 3: Nama Webshell

**Soal:** We need to determine if any vulnerabilities were exploited. What is the name of the malicious web shell that was successfully uploaded?

**Penjelasan:**

Di case ini, webshell diupload lewat HTTP POST request. Filter pake `http.request.method == POST`:

![alt text](6.png)

Ada 2 POST request. Yang pertama ditolak, yang kedua berhasil.

Kenapa yang pertama gagal? File yang diupload berekstensi `.php`. Server punya filter extension. Tapi percobaan kedua pake nama `Image.jpg.php`. Server cuma ngecek extension pertama (.jpg) dan lolos.

![alt text](7.png)

Teknik ini namanya **double extension bypass**. Masih banyak dipake sampe sekarang.

**Jawaban:** `Image.jpg.php`

### Soal 4: Direktori Upload

**Soal:** Identifying the directory where uploaded files are stored is crucial for locating the vulnerable page and removing any malicious files. Which directory is used by the website to store the uploaded files?

**Penjelasan:**

Setelah upload berhasil, attacker harus ngakses file tersebut. Dari HTTP stream keliatan path lengkap file yang diupload:

![alt text](8.png)

Path: `/reviews/uploads/Image.jpg.php`

Direktori upload: `/reviews/uploads/`

**Jawaban:** `/reviews/uploads/`

### Soal 5: Port Attacker untuk RCE

**Soal:** Which port, opened on the attacker's machine, was targeted by the malicious web shell for establishing unauthorized outbound communication?

**Penjelasan:**

Setelah webshell terupload dan terakses, attacker punya RCE (Remote Code Execution) di server. Ini artinya server korban bisa ngirim data balik ke attacker.

Dari log keliatan server korban ngirim data dari port 54448 ke port **8080** milik attacker.

![alt text](9.png)

Follow TCP stream buat liat komunikasi selengkapnya:

![alt text](10.png)

Command yang dijalankan: download script, baca file, dan ngirim balik hasilnya.

**Jawaban:** `8080`

### Soal 6: File Target Ekfiltrasi

**Soal:** Recognizing the significance of compromised data helps prioritize incident response. Which file was the attacker attempting to exfiltrate?

**Penjelasan:**

Dari follow stream, keliatan attacker ngirim perintah buat baca `/etc/passwd` pake curl.

File `/etc/passwd` nyimpen daftar user di sistem Linux. Meskipun password hash sekarang disimpen di `/etc/shadow`, file ini tetep ngasih info username yang bisa dipake buat serangan lebih lanjut.

![alt text](11.png)

**Jawaban:** `/etc/passwd`

## Kesimpulan

Serangan ini nunjukin pola klasik: upload vulnerability + webshell = server compromised. Attacker dari China masuk lewat aplikasi web yang gak validasi file upload dengan bener, upload PHP shell yang disamarin jadi .jpg, dan dapet akses penuh ke server. Dalam hitungan menit, dia udah baca file sistem dan siap exfiltrate.

Yang bikin ini relevan: kasus kayak gini masih sering terjadi di production. Banyak developer masih underestimate soal file upload validation. Mereka pikir cukup cek extension doang, padahal attacker udah punya seribu cara buat bypass itu.

### Takeaway Teknis

1. **File upload validation harus multilayer.** Cek extension, MIME type, magic bytes, dan content. Jangan cuma ngandelin satu filter.
2. **Double extension bypass** (`file.jpg.php`) masih berhasil di banyak server. Konfigurasi web server harus mencegah eksekusi file di folder upload.
3. **Geo-blocking bisa jadi lapisan pertahanan tambahan.** Tapi jangan andelin doang, attacker bisa pake VPN atau proxy.
4. **PCAP analysis bisa ngungkap seluruh serangan.** Dari IP sumber, User-Agent, file yang diupload, sampe data yang dicuri.
5. **Cek traffic outbound yang mencurigakan.** Server korban yang tiba-tiba connect ke IP asing di port gak umum patut diwaspadai.
