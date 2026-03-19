---
title: "Introduction To Digital Forensic : Lab 01"
date: 2026-03-18 00-00-00 
categories: [Blue Team, Logs, Forensic, Linux Command]
authors: [fachri]
tags: [IDN Networkers]
toc: true
comments: false
description: Introduction To Digital Forensic Lab 01
media_subpath: /content/img/ITDF01
---
<!-- Masukkan Image Atau Vid Ke /content
Untuk memanggil bisa ![Coba Image](/content/img/berdua.jpeg) _foto Beduaa_ 
Full Documentasi cara menulis bisa dilihat di https://chirpy.cotes.page/posts/write-a-new-post/
-->

# Introduction To Digital Forensic : Lab 01

Challenge Ini berasal dari Repository

```
https://github.com/vonderchild/digital-forensics-lab/tree/main/Lab%2001
```

Pada Github Tersebut menjelaskan mengenai Command Command dasar yang umum digunakan di Digital Forensic, Sebelum kita membahas commandnya.

## Apa Itu Digital Forensik?

__Digital Forensic__ adalah proses penggunaan teknologi untuk mengumpulkan bukti, menyelidiki bukti tersebut, dan menyajikan temuan dalam kasus hukum. Proses ini dapat mencakup pemeriksaan aktivitas jaringan, catatan akses, riwayat pencarian, dan media penyimpanan digital seperti hard disk dan perangkat seluler, serta analisis data tersebut untuk mengidentifikasi bukti kegiatan kriminal atau pelanggaran lainnya.

Di Kasus yang berbeda, Digital Forensic dapat digunakan untuk :

1. Penyelidikan serangan siber
2. Deteksi dan respons ancaman
3. Pemulihan data
4. Penyelidikan kriminal

## Bagian Pertanyaan

### Soal 1

Q1. If we wanted to list all the `.txt` files in the current directory, what command would we want to use?

### Jawaban

Untuk menampilkan list file yang berekstensi txt di direktori yang sedang di gunakan, kita bisa menggunakan Command berikut :

```bash
find . -type f -name "*.txt"
```

![alt text](1.png)

### Penjelasan :

- `find` → program untuk mencari file secara rekursif (menyusuri semua folder)
- `.` → mulai pencarian dari direktori sekarang
- `-type f` → hanya tampilkan file biasa, bukan folder
- `-name "*.txt"` → nama file harus berakhiran .txt

### Soal 2

Q2. What command can we use to read the contents of the file `/etc/passwd?`

### Jawaban

untuk membaca sebuah file, kita bisa menggunakan command Cat pada linux

```bash
cat /etc/passwd
```

![alt text](2.png)

### Penjelasan :

- `cat` → membaca dan menampilkan isi file ke layar
- `/etc/passwd` → file sistem yang menyimpan informasi identitas user

> File /etc/passwd adalah file yang berisi daftar akun pengguna yang ada di sistem Linux.

```
Setiap baris mewakili satu user, dengan format:

username:x:UID:GID:deskripsi:/home/user:/bin/bash

Artinya:
username → nama akun
UID → ID user (0 = root)
GID → grup utama
home directory → folder home user
shell → shell default saat login
```

### Soal 3

Q3. If we wanted to search for the string Error in all files in the /var/log directory, what would our command be?

### Jawaban

Untuk mencari kata atau kalimat di dalam sebuah File kita bisa menggunakan command grep ( Global Regular Expression Print )

```bash
grep -ri "Error" /var/log
```

### Penjelasan :
- `grep` → program untuk mencari teks di dalam file
- `-r` → cari secara rekursif (masuk semua subfolder)
- `-i` → tidak peduli huruf besar/kecil
- `"Error"` → kata yang ingin dicari
- `/var/log` → lokasi file yang ingin di car

### Soal 4

Q4. What would be the commands to calculate MD5 and SHA1 hashes of the file /etc/passwd?

### Jawaban

- Untuk MD5 Bisa menggunakan Command

```bash
md5sum /etc/passwd
```

![alt text](3.png)_MD5Hash_

Menghasilkan nilai hash MD5 dari file /etc/passwd

- Untuk SHA1 Bisa menggunakan Command

```bash
sha1sum /etc/passwd
```

![alt text](4.png)_SHA1Hash_

Menghasilkan nilai hash SHA1 dari file /etc/passwd

### Penjelasan :

Hal Ini bertujuan untuk memastikan apakah file sistem berubah dengan cara membandingkan sidik jari digital (hash) dari file tersebut.

### Soal 5

Q5. Use the `file` command to determine the type of the file `/usr/bin/cat` and explain the output in 2-3 sentences.

![alt text](5.png)

### Jawaban

```bash
file /usr/bin/cat
```

File `/usr/bin/cat` adalah program biner Linux berformat __ELF 64-bit__ untuk arsitektur x86-64 Status PIE executable dan dynamically linked berarti program tidak berdiri sendiri dan saling berhubungan serta membutuhkan library sistem saat dijalankan melalui loader `/lib64/ld-linux-x86-64.so.2`

### Soal 6

Q6. What command can we use to display all printable strings of length ≥ 8 in the file `/bin/bash`?

### Jawaban

Untuk menambilkan Teks yang panjangnya lebih dari 8 karakter kita bisa menggunakan command strings

```bash
strings -n 8 /bin/bash
```
![alt text](6.png)
### Penjelasan :

- `strings` → mengambil karakter printable dari file biner
- `-n 8` → hanya tampilkan string ≥ 8 karakter
- `/bin/bash` → program yang di tampilkan

### Soal 7

Q7. Given the following output of the `file` command, can you determine what’s wrong with this file?

```
$ file image.jpg
image.jpg: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=3ab23bf566f9a955769e5096dd98093eca750431, for GNU/Linux 3.2.0, not stripped
```
### Jawaban

Jika kita lihat, Extension file tersebut merupakan extension gambar, Namun ketika menggunakan command file hasilnya file tersebut merupakan ELF 64-bit LSB pie executable, yang dimana file ini adalah file binary executable di program linux, jadi seseorang mencoba menyamarkan file executable menjadi file gambar. Hal ini sangat berbahaya apabila di salah gunakan dikarenakan adanya potensi penyebaran malware ataupun hal lainnya

### Soal 8

Q8. If we wanted to look for files modified in the last 30 minutes in /home directory, what command would we want to use?

```
Hint: Explore how you can use find command to achieve this.
```

### Jawaban

Untuk File yang di modifikasi di 30 menit terakhir, kita bisa menggunakan command find di tambah dengan command `-mmin`

![alt text](7.png)

```bash
find /home -type f -mmin -30
```

### Penjelasan :
- `find` → perintah untuk mencari file atau direktori berdasarkan kriteria tertentu
- `/home` → direktori awal tempat pencarian dimulai (termasuk semua subdirektorinya)
- `-type f` → membatasi hasil hanya pada file biasa (regular file)
- `-mmin -30` → menampilkan file yang terakhir dimodifikasi kurang dari 30 menit yang lalu

### Soal 9

Q9. What command can we use to display information about all active TCP connections on the system?

### Jawaban

![alt text](8.png)

```
netstat -tna
```
### Penjelasan :

- `netstat` → menampilkan informasi koneksi jaringan pada sistem
- `-t` → hanya menampilkan koneksi TCP
- `-n` → alamat IP dan port ditampilkan dalam bentuk angka
- `-a` → menampilkan semua koneksi: yang aktif

### Soal 10

Q10. Given this corrupted image file, can you find a way to recover and view its contents?

```
Hint 1: A quick google search for "magic bytes" might help.
Hint 2: Explore how hexedit can help you here.
```

### Jawaban

Kita Download terlebih dahulu File yang akan kita kerjakan

![alt text](9.png)

Setelah kita download, Hal yang pertama kali kita lakukan adalah mengecek metadata dari file tersebut menggunakan tools exiftools

![alt text](10.png)

Dari hasil exiftool, Dapat kita ketahui bahwa File Format tersebut Error, Sehingga kita harus analisis lebih lanjut

Disini Saya menggunakan XXD untuk menampilkan nilai hex dari gambar, Dan Terdapat kesalahan pada header

![alt text](11.png)

Sebagai Referensi Saya menggunakan Web https://filesig.search.org/ Untuk mencari nilai Hex di setiap Header pada Format tertentu

![alt text](12.png)

Dapat di lihat bahwa Header pada file PNG harus berawal dari Hex

```
89 50 4E 47 0D 0A 1A 0A
```

Sedangkan pada File Challenge.png Bukan berawalan dari hex tersebut

Selanjutnya kita menggunakan Tools Hexedit untuk mengubah Nilai Hex pada gambar

![alt text](13.png)

![alt text](14.png)

Kita Ubah header sesuai dengan code Hex Formatnya, Dan jika sudah kita bisa membuka file tersebut menggunakan Command Display and Yap Flag di dapatkan

![alt text](15.png)

![alt text](16.png)
