---
title: "IDN Week 4 Last Bos"
date: 2026-03-16 00-00-00 
categories: [Blue Team, Logs, Forensic, SIEM]
authors: [fachri]
tags: [Wazuh, IDN Networkers]
toc: true
comments: false
description: Tugas IDN Week 4 Analisis Log Menggunakan Wazuh
media_subpath: /content/img/idnweek4
---
<!-- Masukkan Image Atau Vid Ke /content
Untuk memanggil bisa ![Coba Image](/content/img/berdua.jpeg) _foto Beduaa_ 
Full Documentasi cara menulis bisa dilihat di https://chirpy.cotes.page/posts/write-a-new-post/
-->
# Analisis Log Di SIEM

## SIEM (System Information Event Management)

SIEM (Security Information and Event Management) adalah sistem yang digunakan untuk mengumpulkan, menyimpan, menganalisis, dan mendeteksi aktivitas mencurigakan dari berbagai sumber log dalam satu tempat. Disini SIEM yang Digunakan adalah Wazuh SIEM

### Wazuh
Wazuh adalah Sebuah Platform Open Source yang menggabungkan teknologi XDR dan juga SIEM dalam melindungi Cloud, Container Ataupun server. Fitur Fiturnya meliputi analisis data log, deteksi intrusi dan malware, pemantauan integritas file, penilaian konfigurasi, deteksi kerentanan, dan dukungan untuk kepatuhan regulasi.

### Soal 1

Periksa dan identifikasi nama agent yang terhubung dengan SIEM yang dideploy secara lokal.

#### Penjelasan
Setelah kita setting wazuh dan berhasil login kedalam Wazuh Dashboard Maka akan muncul tampilan home dari Wazuh Dashboard

![alt text](1.png) _Tampilan Home Wazuh Dashboard_

Setelahnya kita Pilih Option Wazuh Agent Untuk melihat Nama agent yang terdaftar di SIEM

![alt text](2.png)

Di Bagian menu Agent Terdapat keterangan agent yang terhubung ke SIEM, Dan disini agent yang terhubung adalah metasploitable

![alt text](3.png)

#### Jawaban
Metasploitable

### Soal 2
Identifikasi nama web server yang digunakan atau terhubung dengan SIEM lokal.

#### Penjelasan
Disini kita akan mencari nama web server apa yang digunakan agent metasploitable, di soal sebelumnya terdapat agent id yang dimana kita bisa gunakan di wazuh Discover sebagai filter

![alt text](17.png)

Jika kita membuka salah satu lognya, terdapat filter Location yang dimana field location digunakan untuk menunjukkan dari file log mana event tersebut berasal di agent

![alt text](18.png)

Di log tersebut terdapat kalimat
```
location: "/var/log/apache2/access.log"
```

Artinya log itu berasal dari access log web server milik Apache HTTP Server.

#### Jawaban

Apache Server

### Soal 3
Sebutkan nama index di Wazuh yang digunakan untuk menyimpan semua log mentah (RAW logs) yang dikumpulkan oleh SIEM lokal.

#### Penjelasan

![alt text](16.png)

Wazuh Archives adalah tempat penyimpanan semua log mentah (raw logs) yang dikirim oleh agent sebelum dianalisis atau diproses menjadi alert.

#### Jawaban

Wazuh-Archives

### Soal 4

Periksa jumlah total aktivitas SQL Injection (SQLI) yang terdeteksi selama menyelesaikan latihan SQL-Injection Activity Detected.

#### Penjelasan

Untuk mempermudah pencaharian kerentanan pada SQLI, kita bisa menggunakan filter data.url di wazuh dan memasukkan data.url yang berkaitan dengan SQLI 

![alt text](11.png)

Dan Hasilnya terdapat 4 Aktivitas SQLI yang terdeteksi

![alt text](12.png)
#### Jawaban

4 Aktivitas SQLI

### Soal 5

Identifikasi HTTP status code yang terkait dengan aktivitas Cross-Site Scripting (XSS).

#### Penjelasan

Sama Seperti soal sebelumnya, kita akan memfilter kerentanan XSS di Wazuh

![alt text](13.png)_Penerapan Filter XSS_

![alt text](14.png)_Hasil Filter_

Jika di lihat terdapat 3 Log yang terkait dengan XSS, Namun Hanya ada 1 Log yang menampilkan HTTP Status Code 200 yang menandakan XSS berhasil di jalankan

![alt text](15.png)

#### Jawaban

HTTP Status Code 200

### Soal 6

Identifikasi nama file yang terkait dengan aktivitas File Inclusion.

#### Penjelasan

Di Log ini Attacker mencoba untuk mengakses /etc/passwd melalui kerentanan LFI

LFI (Local File Inclusion) adalah kerentanan ketika aplikasi web mengizinkan user menentukan file yang akan di-load dari server lokal.
{: .prompt-info }

![alt text](6.png)

>file /etc/passwd adalah file sistem yang menyimpan informasi dasar semua user yang ada di sistem

#### Jawaban

/etc/passwd

### Soal 7

Tentukan port yang terkait dengan komunikasi jaringan mencurigakan pada latihan Remote File Inclusion Activity Detected.

#### Penjelasan

Untuk mencari Kerentanan RFI. Hal pertama yang kita lakukan adalah identifikasi apakah attacker menyisipkan file berbahaya ke dalam server, untuk itu kita akan analisis menggunakan Wireshark Dengan filter

```
http.request.method
```

![alt text](7.png)

Yang Selanjutnya kita cari metode POST yang dimana Metode POST Digunakan untuk mengirim data ke server.

Dan Kita analisa File yang dikirimkan ke dalam server

![alt text](8.png)

Jika kita Lihat attacker, mencoba berkomunikasi menggunakan IP 192.168.117.242 dengan Port 9001

Untuk memvalidasi hal tersebut kita bisa memfilter kembali dengan filter 

```
tcp.port == 9001
```
![alt text](9.png)

Dan Follow TCP Streamnya

![alt text](10.png)

#### Jawaban

9001

### Soal 8

Identifikasi source port (src port) yang terhubung dengan destination port 4444 pada file external.pcapng

#### Penjelasan

Dari Soal tersebut kita harus mencari Source Port yang terhubung dengan destination port 4444 di file external.pcapng, Disini saya menggunakan filter di wireshark dengan filter

```
tcp.dstport == 4444
```

![alt text](5.png)

Dan yap dari log tersebut terlihat Source port yang terhubung adalah 49816

#### Jawaban

port 49816

### Soal 9

Tentukan PID (Process ID) yang terkait dengan shell.exe pada file memory dump suspected.raw

#### Penjelasan

Untuk membuka Memory Dump, disini saya menggunakan Tools Volatility3 dengan tambahan Plugin `windows.pslist` 

Plugin ini membaca struktur EPROCESS di kernel Windows untuk mendapatkan proses yang sedang berjalan.

![alt text](19.png)

| Kolom Penting | Penjelasan |
| -------- | -------- |
| PID| Process ID |
| PPID | Parent Process ID |
| ImageFileName | Nama program yang berjalan |


#### Jawaban

PID 7396

### Soal 10

Tentukan URL yang terkait dengan aktivitas Local File Inclusion (LFI) yang terdeteksi pada SIEM lokal.

#### Penjelasan

Untuk melihat aktivitas Local File Inclusion Disini saya menerapkan filter Agent.id dan juga Data.protocol untuk mempermudah pencarian

![alt text](4.png)

Melalui Log tersebut Attacker menggunakan serangan LFI, dengan indikasi payload ../../../etc/passwd yang dimana attacker mencoba menjelajah file di dalam server

#### Jawaban

```
http://192.168.117.143/prod/vulnerabilities/fi/?page=file/../../../../../../etc/passwd
```