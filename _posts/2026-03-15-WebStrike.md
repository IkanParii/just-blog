---
title: "WebStrike"
date: 2026-03-15 00:00:00 +0700
categories: [Blue Team, CTF, Logs, Forensic]
authors: [fachri]
tags: [CyberDefenders, IDN Networkers, Web Shell, PCAP Analysis, Wireshark, RCE]
toc: true
comments: false
description: Walkthrough forensic WebStrike dari CyberDefenders — analisis PCAP serangan web shell upload, RCE, dan eksfiltrasi data via curl.
media_subpath: /content/img/webstrike
---

# Webstrike

![Screenshot 1](1.png)

## Deskripsi Soal

A suspicious file was identified on a company web server, raising alarms within the intranet. The Development team flagged the anomaly, suspecting potential malicious activity. To address the issue, the network team captured critical network traffic and prepared a PCAP file for review.
Your task is to analyze the provided PCAP file to uncover how the file appeared and determine the extent of any unauthorized activity.

### Soal 1

Identifying the geographical origin of the attack facilitates the implementation of geo-blocking measures and the analysis of threat intelligence. From which city did the attack originate?

#### Penjelasan

Setelah saya buka file PCAP nya disini terdapat IP yang mencoba untuk saling berkomunikasi Three Ways Handshake, IP yang pertama kali Request Syn adalah 117.11.88.124, Untuk mencari IP Geolocation kita bisa menggunakan beberapa website seperti https://ipgeolocation.io/ 

![Screenshot 2](2.png) _Network Logs_

![Screenshot 3](3.png) _IP Geolocation_

#### Jawaban 

Tianjin

### Soal 2

Knowing the attacker's User-Agent assists in creating robust filtering rules. What's the attacker's Full User-Agent?

#### Penjelasan

Untuk mengetahui User Agent dari perangkat kita harus membuka packet yang berprotokol HTTP atau HTTPS, User Agent sendiri adalah sebuah string teks (karakter) yang dikirimkan oleh browser atau aplikasi ke server web dalam setiap permintaan HTTP, Fungsinya untuk mengidentifikasi perangkat lunak, versi browser dan sistem operasi pengguna

Untuk itu kita bisa pilih packet yang berprotokol http di wireshark
![Screenshot 4](4.png)

Selanjutnya kita bisa follow packet tersebut untuk melihat komunikasinya lebih detail
![Screenshot 5](5.png)
#### Jawaban 

Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0

### Soal 3

We need to determine if any vulnerabilities were exploited. What is the name of the malicious web shell that was successfully uploaded?

#### Penjelasan

Untuk mencari webshell yang berhasil terupload ke server, Kita bisa analisa Packet yang berprotokol HTTP sama seperti soal sebelumnya. Namun, untuk mempermudah mana yang berhasil, kita bisa mencari packet yang bermethod POST, Method POST digunakan untuk mengirimkan data secara tersembunyi melalui permintaan HTTP.

Di Wireshark, kita bisa memfilter packet dengan command http.request.method
![Screenshot 6](6.png)

Jika di lihat, terdapat 2 method POST, Namun memiliki respon server yang berbeda,Dikarenakan method pertama di tolak dikarenakan berekstensi .php namun method kedua, Webshell berhasil terupload ke server dikarenakan di samarkan menggunakan extension jpg atau image

![Screenshot 7](7.png)

#### Jawaban
Image.jpg.php

### Soal 4

Identifying the directory where uploaded files are stored is crucial for locating the vulnerable page and removing any malicious files. Which directory is used by the website to store the uploaded files?

#### Penjelasan

Setelah Menaruh WebShell, Penyerang harus membuka webshell yang sudah terupload di server, Oleh karena itu, penyerang harus mencari direktori tempat file tersebut di upload, setelah mencari direktorinya di dapat bahwa File tersebut masuk ke direktori /reviews/uploads/image.jpg.php

![Screenshot 8](8.png)

#### Jawaban 
/reviews/uploads/
### Soal 5

Which port, opened on the attacker's machine, was targeted by the malicious web shell for establishing unauthorized outbound communication?

#### Penjelasan

Ketika Webshell sudah berhasil di akses oleh penyerang, maka penyerang dapat mengakses server menggunakan webshell tersebut, dan alur komunikasinya dalam protocol TCP sehingga penyerang dapat mengirimkan atau mengeksekusi perintah di dalam server tersebut

Disini Setelah Webshell di akses, Server mengirimkan pesan bahwa penyerang sudah memiliki akses remote atau RCE ke server. Server mengirimkan dari port 54448 ke port 8080 milik penyerang

![Screenshot 9](9.png)

Dan jika kita follow untuk melihat lebih detail maka akan terlihat penyerang melakukan remote code execution di dalam sebuah server

![Screenshot 10](10.png)

#### Jawaban 
8080
### Soal 6
Recognizing the significance of compromised data helps prioritize incident response actions. Which file was the attacker attempting to exfiltrate?
#### Penjelasan
Setelah mendapatkan akses ke server, Disini penyerang mencoba untuk mengirim file /etc/passwd ke server penyerang menggunakan curl

File /etc/passwd adalah file yang berisi daftar akun pengguna yang ada di sistem Linux.
![Screenshot 11](11.png)
#### Jawaban 
/etc/passwd