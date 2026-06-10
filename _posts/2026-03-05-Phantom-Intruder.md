---
title: "Phantom Intruder"
date: 2026-03-05 00:00:00 +0700
categories: [Blue Team,CTF,Logs,Forensic]
authors: [fachri]
tags: [PicoCTF, IDN Networkers, PCAP Analysis, Wireshark, Base64, Network Forensic]
toc: true
comments: false
description: Walkthrough forensic Phantom Intruder dari PicoCTF — analisis PCAP untuk mengungkap serangan dan mengekstrak flag dari traffic jaringan.
media_subpath: /content/img/phantomintruder
---

# Phantom Intruder

![Screenshot 1](1.png)

## Deskripsi Soal

A digital ghost has breached my defenses, and my sensitive data has been stolen! 😱💻 Your mission is to uncover how this phantom intruder infiltrated my system and retrieve the hidden flag.
To solve this challenge, you'll need to analyze the provided PCAP file and track down the attack method. The attacker has cleverly concealed his moves in well timely manner. Dive into the network traffic, apply the right filters and show off your forensic prowess and unmask the digital intruder!
Find the PCAP file here Network Traffic PCAP file and try to get the flag.

## Tahap Pengerjaan

Setelah Mendownload File tersebut, Kita akan analisis menggunakan tools Wireshark

![Screenshot 2](2.png)

Disini kita akan coba membuka salah satu packetnya

![Screenshot 3](3.png)

Dan Yap terdapat string aneh di packetnya, Disini saya menduga bahwa ini merupakan encode base64 di karenakan ada (==) di akhir kalimat

Selanjutnya kita akan coba decode kode tersebut menggunakan Online tools [CyberChef](https://gchq.github.io/CyberChef/)

![Screenshot 4](4.png)

Dan yap, Kode tersebut merupakan kode base64 dan kita mendapatkan potongan flagnya

Untuk mempercepat pengerjaan kita akan menggunakan command strings di Linux agar mengekstrak kalimat yang bisa di baca user dari file PCAP

![Screenshot 5](5.png)

Selanjutnya kita bisa decode semua strings tersebut yang berakhiran (==) 

![Screenshot 6](6.png)
_Sebelum Di decode_

![Screenshot 7](7.png)
_Sesudah di decode_

Selanjutnya kita akan Menyusun kalimat tersebut supaya menjadi flag yang utuh 

Flag : picoCTF{1t_w4snt_th4t_34sy_tbh_4r_af160980}