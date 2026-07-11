---
title: "10 Command Linux Dasar buat Investigasi Digital Forensic"
date: 2026-03-18 00:00:00 +0700
categories: [Blue Team, Forensik, Linux, Lab]
authors: [fachri]
tags: [IDN Networkers, Linux Command, Digital Forensic, File Recovery, Forensik Digital, CLI Tools, Incident Response]
toc: true
comments: false
description: "Walkthrough lab Digital Forensic: 10 command Linux dasar untuk forensic termasuk find, grep, strings, md5sum, file, netstat, dan hexedit. Teknik file recovery."
media_subpath: /content/img/ITDF01
---

# Digital Forensic Lab: 10 Command Linux Dasar untuk Investigasi

Forensic digital itu soal detail. Satu file yang salah extension, satu string yang nyempil di binary, satu hash yang gak cocok. Semua itu bisa jadi bukti kalo lo tau cara liatnya. Dan tools paling dasar buat semua itu? **Command line Linux.**

Lab ini dari [digital-forensics-lab](https://github.com/vonderchild/digital-forensics-lab/tree/main/Lab%2001) ngajarin 10 command fundamental yang harus lo kuasai sebelum nyentuh tools forensic canggih. Mungkin kedengerannya basic, tapi percaya deh, investigator senior pun balik ke command ini tiap hari.

## Apa Itu Digital Forensik?

Digital forensic adalah proses ngumpulin, nyimpen, dan menganalisis bukti digital buat kebutuhan investigasi. Bisa buat kasus kriminal, serangan siber, pelanggaran kebijakan, atau incident response.

Di kasus yang berbeda, digital forensic bisa dipake buat:
1. Penyelidikan serangan siber
2. Deteksi dan respons ancaman
3. Pemulihan data yang terhapus atau rusak
4. Penyelidikan kriminal (pembuktian di pengadilan)

---

## Soal 1: Find .txt Files

**Soal:** If we wanted to list all the `.txt` files in the current directory, what command would we use?

**Jawaban:**

```bash
find . -type f -name "*.txt"
```

![alt text](1.png)

**Penjelasan:**

- `find`: program buat nyari file secara rekursif
- `.`: mulai dari direktori sekarang
- `-type f`: cuma file biasa, bukan folder
- `-name "*.txt"`: nama file harus berakhiran .txt

Gunakan wildcard `*` biar cocok dengan nama file apapun yang diakhiri .txt.

---

## Soal 2: Read File Content

**Soal:** What command can we use to read the contents of the file `/etc/passwd`?

**Jawaban:**

```bash
cat /etc/passwd
```

![alt text](2.png)

**Penjelasan:**

`cat` (concatenate) nampilin isi file ke terminal. `/etc/passwd` nyimpen informasi user di Linux.

Format tiap baris:

```
username:x:UID:GID:deskripsi:/home/user:/bin/bash
```

| Field | Arti |
|-------|------|
| username | Nama akun |
| x | Password tersimpan di /etc/shadow |
| UID | User ID (0 = root) |
| GID | Group ID utama |
| deskripsi | Informasi tambahan (opsional) |
| /home/user | Home directory |
| /bin/bash | Shell default |

---

## Soal 3: Grep Error Logs

**Soal:** If we wanted to search for the string "Error" in all files in the `/var/log` directory, what would our command be?

**Jawaban:**

```bash
grep -ri "Error" /var/log
```

**Penjelasan:**

- `grep`: program buat nyari teks di dalam file
- `-r`: rekursif (masuk semua subfolder)
- `-i`: case insensitive, gak peduli huruf besar-kecil
- `"Error"`: string yang dicari
- `/var/log`: direktori target

Grep adalah tools paling vital di forensic. Mau nyari IP attacker, string mencurigakan, atau pola tertentu di ribuan baris log? Grep jawabannya.

---

## Soal 4: MD5 dan SHA1 Hash

**Soal:** What would be the commands to calculate MD5 and SHA1 hashes of the file `/etc/passwd`?

**Jawaban:**

```bash
md5sum /etc/passwd
sha1sum /etc/passwd
```

![alt text](3.png)
![alt text](4.png)

**Penjelasan:**

Hash digunakan buat verifikasi integritas file. Kalo hash file berubah, berarti file sudah dimodifikasi. Ini penting di forensic buat ngecek apakah file sistem sudah diubah sama attacker.

| Jenis Hash | Panjang | Kegunaan |
|------------|--------|----------|
| MD5 | 128 bit (32 karakter hex) | Cek cepat, tapi rawan collision |
| SHA1 | 160 bit (40 karakter hex) | Lebih aman dari MD5 |

---

## Soal 5: File Type Detection

**Soal:** Use the `file` command to determine the type of the file `/usr/bin/cat` and explain the output.

**Jawaban:**

```bash
file /usr/bin/cat
```

![alt text](5.png)

File `/usr/bin/cat` adalah **ELF 64-bit LSB pie executable** untuk arsitektur x86-64. Status PIE (Position Independent Executable) dan dynamically linked, artinya program ini butuh library sistem external yang di-load lewat `/lib64/ld-linux-x86-64.so.2`.

Command `file` berguna buat ngecek apakah extension file cocok sama isi sebenarnya. Salah satu teknik dasar forensic.

---

## Soal 6: Strings Extraction

**Soal:** What command can we use to display all printable strings of length >= 8 in the file `/bin/bash`?

**Jawaban:**

```bash
strings -n 8 /bin/bash
```

![alt text](6.png)

**Penjelasan:**

- `strings`: extract karakter printable dari file biner
- `-n 8`: minimal panjang string 8 karakter
- `/bin/bash`: target file

Strings berguna buat cari IP address, URL, atau command yang nyempil di file biner atau memory dump.

---

## Soal 7: Corrupted File Detection

**Soal:** Given the following output of the `file` command, can you determine what's wrong with this file?

```
$ file image.jpg
image.jpg: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=3ab23bf566f9a955769e5096dd98093eca750431, for GNU/Linux 3.2.0, not stripped
```

**Jawaban:**

Ekstensi file `.jpg` (gambar), tapi hasil `file` nunjukin ini **ELF 64-bit executable**. Artinya seseorang nyamar-in file executable jadi gambar. Ini teknik umum buat nyebulin malware: ganti extension, kasih icon mirip gambar, dan korban bakal klik.

> Di dunia forensic, jangan pernah percaya extension. Selalu cek pake `file` command atau magic bytes.

---

## Soal 8: Find Modified Files

**Soal:** If we wanted to look for files modified in the last 30 minutes in `/home` directory, what command would we want to use?

**Jawaban:**

```bash
find /home -type f -mmin -30
```

![alt text](7.png)

**Penjelasan:**

- `-mmin -30`: file yang dimodifikasi kurang dari 30 menit yang lalu

Ini berguna pas incident response: lo bisa cari file yang baru berubah selama atau setelah serangan. Attacker biasanya ngunduh atau ngubah file dalam jendela waktu tertentu.

---

## Soal 9: Active TCP Connections

**Soal:** What command can we use to display information about all active TCP connections on the system?

**Jawaban:**

```bash
netstat -tna
```

![alt text](8.png)

**Penjelasan:**

- `netstat`: nampilin koneksi jaringan
- `-t`: cuma TCP
- `-n`: nomor IP dan port (tanpa DNS lookup)
- `-a`: semua koneksi (listening dan established)

Buat yang lebih modern, lo bisa pake `ss -tna` (dari package iproute2). Fungsinya sama, tapi `ss` lebih cepat.

Pas incident response, command ini lo jalanin pertama kali buat liat apakah ada koneksi mencurigakan ke IP asing.

---

## Soal 10: File Recovery dengan Hexedit

**Soal:** Given this corrupted image file, can you find a way to recover and view its contents?

**Hint:** A quick google search for "magic bytes" might help.
**Hint:** Explore how hexedit can help you here.

**Jawaban:**

Download file challenge:

![alt text](9.png)

Cek metadata pake exiftool:

![alt text](10.png)

File format error. Berarti ada yang salah sama headernya.

Cek pake `xxd` buat nampilin hex dump:

![alt text](11.png)

Header file gak sesuai sama format yang seharusnya. Referensi magic bytes dari [filesig.search.org](https://filesig.search.org/):

![alt text](12.png)

PNG header harusnya:

```
89 50 4E 47 0D 0A 1A 0A
```

Tapi file ini pake header yang salah. Fix pake `hexedit`:

![alt text](13.png)
![alt text](14.png)

Ubah header sesuai magic bytes PNG, simpan, buka:

![alt text](15.png)
![alt text](16.png)

Flag dapet.

---

## Kesimpulan

10 command ini mungkin keliatan basic, tapi ini fondasi yang lo pake setiap hari di dunia forensic. Dari cari file, baca konten, hash, sampe recover file rusak. Tools mahal dan software fancy gak bakal nolong kalo lo gak ngerti dasar-dasarnya.

Yang paling penting: **jangan percaya sama extension.** Attacker bisa ngasih nama `image.jpg` tapi isinya ELF binary. Selalu verifikasi pake command kayak `file` dan `xxd`.

### Takeaway Teknis

1. **Find + Grep** adalah senjata utama buat nyari bukti di ribuan file. Kuasai opsi rekursif dan filter.
2. **Hash verification (md5sum/sha1sum)** buat ngecek integritas file. Catet hash file sistem pas awal, bandingin kalo ada insiden.
3. **Strings command** bisa extract IP, domain, atau command dari file biner. Berguna buat malware analysis.
4. **file command** ngecek tipe file sebenarnya berdasarkan magic bytes, bukan extension.
5. **Hexedit** ngebantu lo recovery file yang rusak atau sengaja dirusak attacker dengan cara ngebenerin header.
