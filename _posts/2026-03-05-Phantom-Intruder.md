---
title: "Phantom Intruder"
date: 2026-03-05 00-00-00 
categories: [Blue Team]
authors: [fachri]
tags: [CTF,Forensic,Bootcamp,logs]   
toc: true
comments: false
description: Phantom Intruder By PicoCTF
media_subpath: /content/img/phantomintruder
---
<!-- Masukkan Image Atau Vid Ke /content
Untuk memanggil bisa ![Coba Image](/content/img/berdua.jpeg) _foto Beduaa_ 
Full Documentasi cara menulis bisa dilihat di https://chirpy.cotes.page/posts/write-a-new-post/
-->

# Phantom Intruder

![alt text](1.png)

## Deskripsi Soal

A digital ghost has breached my defenses, and my sensitive data has been stolen! 😱💻 Your mission is to uncover how this phantom intruder infiltrated my system and retrieve the hidden flag.
To solve this challenge, you'll need to analyze the provided PCAP file and track down the attack method. The attacker has cleverly concealed his moves in well timely manner. Dive into the network traffic, apply the right filters and show off your forensic prowess and unmask the digital intruder!
Find the PCAP file here Network Traffic PCAP file and try to get the flag.

## Tahap Pengerjaan

Setelah Mendownload File tersebut, Kita akan analisis menggunakan tools Wireshark

![alt text](2.png)

Disini kita akan coba membuka salah satu packetnya

![alt text](3.png)

Dan Yap terdapat string aneh di packetnya, Disini saya menduga bahwa ini merupakan encode base64 di karenakan ada (==) di akhir kalimat

Selanjutnya kita akan coba decode kode tersebut menggunakan Online tools [CyberChef](https://gchq.github.io/CyberChef/)

![alt text](4.png)

Dan yap, Kode tersebut merupakan kode base64 dan kita mendapatkan potongan flagnya

Untuk mempercepat pengerjaan kita akan menggunakan command strings di Linux agar mengekstrak kalimat yang bisa di baca user dari file PCAP

![alt text](5.png)

Selanjutnya kita bisa decode semua strings tersebut yang berakhiran (==) 

![alt text](6.png)
_Sebelum Di decode_

![alt text](7.png)
_Sesudah di decode_

Selanjutnya kita akan Menyusun kalimat tersebut supaya menjadi flag yang utuh 

Flag : picoCTF{1t_w4snt_th4t_34sy_tbh_4r_af160980}