---
title: "Analisis Log dan Forensic SIEM Pake Wazuh dari IDN Week 4"
date: 2026-03-16 00:00:00 +0700
categories: [Blue Team, Forensik, SIEM, Log Analysis]
authors: [fachri]
tags: [Wazuh, IDN Networkers, SIEM, Log Analysis, SQL Injection, XSS, LFI, Wireshark, Volatility, Incident Response]
toc: true
comments: false
description: "Tugas IDN Week 4: analisis log menggunakan Wazuh SIEM. SQL injection, XSS, LFI detection, PCAP analysis, dan memory forensic dengan Volatility."
media_subpath: /content/img/idnweek4
---

# 10 Soal Forensic SIEM: Analisis Log dengan Wazuh (IDN Week 4)

Bayangin lo jadi SOC analyst yang tugasnya mantau puluhan server dari satu dashboard. Ada ribuan log masuk tiap detik. Di antara semua noise itu, lo harus bisa bedain mana traffic normal dan mana serangan. Ini kerjaan sehari-hari SIEM (Security Information and Event Management).

Di tugas IDN Week 4 ini, gw pake **Wazuh** sebagai SIEM platform buat analisis log dari berbagai sumber. Mulai dari deteksi SQL Injection, XSS, LFI, sampe analisis memory dump pake Volatility. Semua dari satu dashboard.

## SIEM & Wazuh

**SIEM (Security Information and Event Management)** adalah sistem yang ngumpulin, nyimpen, dan menganalisis log dari berbagai sumber buat deteksi ancaman secara real-time.

**Wazuh** adalah platform open source yang menggabungkan XDR dan SIEM. Fiturnya meliputi analisis data log, deteksi intrusi, pemantauan integritas file (FIM), penilaian konfigurasi, deteksi kerentanan, dan compliance monitoring. Cocok buat organisasi yang butuh SIEM tapi budget terbatas.

### Soal 1: Identifikasi Agent

**Soal:** Periksa dan identifikasi nama agent yang terhubung dengan SIEM yang dideploy secara lokal.

**Penjelasan:**

Login ke Wazuh Dashboard, langsung muncul tampilan home:

![alt text](1.png)

Masuk ke menu **Agent** buat liat daftar agent yang terdaftar:

![alt text](2.png)

![alt text](3.png)

Agent yang terhubung: **metasploitable**. Iya, targetnya Metasploitable, VM sengaja dibuat rentan buat latihan.

**Jawaban:** `Metasploitable`

### Soal 2: Web Server

**Soal:** Identifikasi nama web server yang digunakan atau terhubung dengan SIEM lokal.

**Penjelasan:**

Gunakan agent ID dari soal sebelumnya sebagai filter di Wazuh Discover. Terus cek field **location** di salah satu log:

![alt text](17.png)

![alt text](18.png)

Dari location:

```
location: "/var/log/apache2/access.log"
```

Web server yang dipake: **Apache HTTP Server**.

**Jawaban:** `Apache Server`

### Soal 3: Index Wazuh Archives

**Soal:** Sebutkan nama index di Wazuh yang digunakan untuk menyimpan semua log mentah (RAW logs) yang dikumpulkan oleh SIEM lokal.

**Penjelasan:**

Wazuh punya index khusus buat nyimpen data mentah sebelum diproses jadi alert:

![alt text](16.png)

**Wazuh Archives** adalah tempat penyimpanan semua raw logs. Penting buat forensic: data mentah ini bisa lo query kapan aja tanpa terpengaruh sama aturan alert yang berubah.

**Jawaban:** `Wazuh-Archives`

### Soal 4: Deteksi SQL Injection

**Soal:** Periksa jumlah total aktivitas SQL Injection (SQLI) yang terdeteksi selama menyelesaikan latihan SQL-Injection Activity Detected.

**Penjelasan:**

SQL Injection detection di Wazuh bisa pake filter `data.url`. Cari URL yang mengandung pola query SQL:

![alt text](11.png)

Hasil filter: **5 aktivitas SQLI** terdeteksi.

![alt text](12.png)

**Jawaban:** `5 Aktivitas SQLI`

### Soal 5: HTTP Status Code XSS

**Soal:** Identifikasi HTTP status code yang terkait dengan aktivitas Cross-Site Scripting (XSS).

**Penjelasan:**

Filter yang sama buat XSS:

![alt text](13.png)

![alt text](14.png)

Dari 3 log XSS yang terdeteksi, cuma 1 yang punya **HTTP Status Code 200** (berhasil). Dua lainnya mungkin dicegat sama filter atau validasi server.

![alt text](15.png)

**Jawaban:** `HTTP Status Code 200`

### Soal 6: LFI Target File

**Soal:** Identifikasi nama file yang terkait dengan aktivitas File Inclusion.

**Penjelasan:**

Attacker nyoba akses `/etc/passwd` lewat kerentanan LFI (Local File Inclusion). Dari log:

![alt text](6.png)

> LFI adalah kerentanan web yang ngizinin attacker baca file dari server lokal lewat parameter yang gak divalidasi.

File `/etc/passwd` nyimpen daftar semua user di sistem Linux. Attacker pake ini buat enumerasi akun.

**Jawaban:** `/etc/passwd`

### Soal 7: Port RFI

**Soal:** Tentukan port yang terkait dengan komunikasi jaringan mencurigakan pada latihan Remote File Inclusion Activity Detected.

**Penjelasan:**

RFI (Remote File Inclusion) beda sama LFI. Kalo LFI baca file lokal, RFI nge-load file dari server remote. Ini yang lebih bahaya soalnya attacker bisa dapet RCE.

Untuk investigasi, butuh korelasi antara Wazuh dan Wireshark. Filter HTTP di PCAP:

```
http.request.method
```

![alt text](7.png)

Cari method POST:

![alt text](8.png)

Dari analisis keliatan attacker komunikasi pake IP `192.168.117.242` lewat **port 9001**.

Validasi pake filter:

```
tcp.port == 9001
```

![alt text](9.png)

Follow TCP Stream:

![alt text](10.png)

**Jawaban:** `9001`

### Soal 8: Source Port Connection

**Soal:** Identifikasi source port (src port) yang terhubung dengan destination port 4444 pada file external.pcapng.

**Penjelasan:**

Port 4444 biasanya identik sama **Meterpreter** (Metasploit). Kalo lo liat traffic ke port ini tanpa konteks yang jelas, curigain.

Filter di Wireshark:

```
tcp.dstport == 4444
```

![alt text](5.png)

Source port yang connect: **49816**.

**Jawaban:** `port 49816`

### Soal 9: PID shell.exe (Memory Forensic)

**Soal:** Tentukan PID (Process ID) yang terkait dengan shell.exe pada file memory dump suspected.raw.

**Penjelasan:**

Ini pindah dari network forensic ke memory forensic. File `suspected.raw` adalah memory dump dari sistem Windows yang kena kompromi.

Tools: **Volatility3** dengan plugin `windows.pslist`. Plugin ini baca struktur EPROCESS di kernel Windows buat ngelist proses yang sedang jalan.

```bash
volatility3 -f suspected.raw windows.pslist
```

![alt text](19.png)

shell.exe punya PID **7396**.

| Kolom Penting | Penjelasan |
|---------------|------------|
| PID | Process ID |
| PPID | Parent Process ID |
| ImageFileName | Nama program yang berjalan |

**Jawaban:** `PID 7396`

### Soal 10: URL LFI

**Soal:** Tentukan URL yang terkait dengan aktivitas Local File Inclusion (LFI) yang terdeteksi pada SIEM lokal.

**Penjelasan:**

Filter pake kombinasi agent ID dan protocol di Wazuh:

![alt text](4.png)

URL yang terdeteksi:

```
http://192.168.117.143/prod/vulnerabilities/fi/?page=file/../../../../../../etc/passwd
```

Pola `../../../` adalah path traversal. Attacker nyoba keluar dari direktori web root buat akses file sistem. Ini LFI klasik yang masih sering ditemukan di aplikasi web kodingan amatir.

**Jawaban:** `http://192.168.117.143/prod/vulnerabilities/fi/?page=file/../../../../../../etc/passwd`

## Kesimpulan

Tugas ini nunjukin gimana SIEM kayak Wazuh bisa jadi pusat komando buat incident response. Dari satu dashboard, lo bisa deteksi SQL Injection, XSS, LFI, sampe RFI. Ditambah tools pendukung kayak Wireshark buat network analysis dan Volatility buat memory forensic, lo punya visibility hampir penuh dari serangan.

Yang bikin Wazuh menarik: open source, fiturnya lengkap, dan komunitasnya aktif. Buat organisasi dengan budget terbatas, ini alternatif serius dibanding SIEM komersial kayak Splunk atau QRadar.

### Takeaway Teknis

1. **Wazuh sebagai SIEM sentral** ngumpulin log dari berbagai source. Agent-based architecture, support Windows, Linux, macOS.
2. **Filter query di Wazuh** penting buat narrowing down ribuan log. Pake field kayak `data.url`, `agent.id`, `location` buat pinpoint serangan.
3. **Korelasi multi-tools**: Wazuh buat deteksi, Wireshark buat network deep-dive, Volatility buat memory analysis. Satu tools jarang cukup.
4. **SQL Injection dan XSS** masih jadi serangan web paling umum. Wazuh bisa detect lewat signature-based rules di log.
5. **Memory forensic dengan Volatility** ngasih visibility ke proses yang jalan di sistem. shell.exe di port 4444? Almost certainly Meterpreter.
