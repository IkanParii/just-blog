---
title: "Event Viewing"
date: 2026-03-02 00-00-00 
categories: [Blue Team]
authors: [fachri]
tags: [CTF,Forensic,Bootcamp,logs]   
toc: true
comments: false
description: Event Viewing By PicoCTF
---
<!-- Masukkan Image Atau Vid Ke /content
Untuk memanggil bisa ![Coba Image](/content/img/berdua.jpeg) _foto Beduaa_ 
Full Documentasi cara menulis bisa dilihat di https://chirpy.cotes.page/posts/write-a-new-post/
-->

# Event Viewing 

![alt text](/content/img/eventviewing/1.png)

## Deskripsi Soal

One of the employees at your company has their computer infected by malware! Turns out every time they try to switch on the computer, it shuts down right after they log in. The story given by the employee is as follows:

1.They installed software using an installer they downloaded online
2.They ran the installed software but it seemed to do nothing
3.Now every time they bootup and login to their computer, a black command prompt screen quickly opens and closes and their computer shuts down instantly.

See if you can find evidence for the each of these events and retrieve the flag (split into 3 pieces) from the correct logs!

## Tahap Pengerjaan
Buka File yang sudah di unduh tadi menggunakan event viewer 
![alt text](/content/img/eventviewing/2.png)

Jika kita membaca deskripsi soal, Flag terpisah menjadi 3 bagian

### Bagian 1

#### Soal
1.They installed software using an installer they downloaded online

#### Penjelasan
Disini Kita harus mencari Log dimana penyerang menginstall sebuah software yang baru di unduh

Kita bisa menggunakan filter log untuk mempermudah pencaharian
![alt text](/content/img/eventviewing/3.png)

Kita masukkan Event ID 1033
![alt text](/content/img/eventviewing/4.png)

> Kode 1033 (MsiInstaller) Menandakan bahwa Windows Installer menginstal/mengonfigurasi ulang/memperbarui aplikasi.

Setelah di filter, kita bisa cek log yang menggunakan event id yang sesuai dan cari kejanggalan di logs tersebut

![alt text](/content/img/eventviewing/5.png)

Disini terdapat kejanggalan pada logs yang dimana terdapat kode base64 di logs tersebut

![alt text](/content/img/eventviewing/6.png)

kita bisa decode kode base64 tersebut menggunakan online tools, Disini saya menggunakan tools [CyberChef](https://gchq.github.io/CyberChef/)

![alt text](/content/img/eventviewing/7.png)

Flag Bagian 1 : picoCTF{Ev3nt_vi3wv3r_

### Bagian 2

#### Soal

2.They ran the installed software but it seemed to do nothing

#### Penjelasan
Di soal mengatakan bahwa setelah dia menjalankan software nya, tidak ada perubahan yang terlihat, Oleh karena itu kita bisa cek registry apakah ada file yang terubah atau tidak

Sama seperti sebelumnya kita menggunakan log filter bawaan dari event Viewer

![alt text](/content/img/eventviewing/8.png)

> Kode Event ID 4657 adalah log keamanan (security log) di Windows yang menandakan bahwa sebuah nilai registri (registry value) telah diubah, dibuat, atau dihapus

Dan lagi lagi, Di salah satu log terdapat Kode base64 

![alt text](/content/img/eventviewing/9.png)

Dan kita coba decode kode tersebut

![alt text](/content/img/eventviewing/10.png)

Flag Bagian 2 : 1s_a_pr3tty_us3ful_

### Bagian 3

#### Soal

3.Now every time they bootup and login to their computer, a black command prompt screen quickly opens and closes and their computer shuts down instantly.

#### Penjelasan

Selanjutnya, Ketika User Boot Up dan Login ke computernya, Command prompt tampil dan tertutup dengan sangat cepat, Untuk itu kita harus mencari event ID yang menunjukan inisiasi shutdown program tertentu

![alt text](/content/img/eventviewing/11.png)

> Kode Event ID 1074 di Windows adalah log peristiwa yang mencatat tindakan pematian (shutdown) atau menghidupkan ulang (restart) sistem secara terencana, baik oleh pengguna maupun aplikasi

Dan Yap, Pola yang sama dimana di salah satu logs terdapat kode base64

![alt text](/content/img/eventviewing/12.png)

Dan kita coba decode kode tersebut 

![alt text](/content/img/eventviewing/13.png)

Flag Bagian 3 : t00l_81ba3fe9}

## Kesimpulan

Dan yap Bagian bagian Flag sudah di dapatkan dan apabila di satukan menjadi 

Flag : picoCTF{Ev3nt_vi3wv3r_1s_a_pr3tty_us3ful_t00l_81ba3fe9}