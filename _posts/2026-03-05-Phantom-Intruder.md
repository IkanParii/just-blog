---
title: "Bongkar Hantu Digital di Trafik Jaringan Lewat PCAP Forensic PicoCTF"
date: 2026-03-05 00:00:00 +0700
categories: [Blue Team, CTF, Forensik, Network Security]
authors: [fachri]
tags: [PicoCTF, IDN Networkers, PCAP Analysis, Wireshark, Base64, Network Forensic, Traffic Analysis]
toc: true
comments: false
description: "Walkthrough forensic Phantom Intruder PicoCTF: analisis PCAP, ekstraksi base64 dari traffic jaringan, dan teknik network forensic untuk mengungkap serangan."
media_subpath: /content/img/phantomintruder
---

# Hantu Digital di Jaringan: Forensic PCAP PicoCTF Phantom Intruder

![alt text](1.png)

Pernah dapet laporan "data ilang, gak tau caranya"? Ini skenario yang paling bikin pusing investigator. Gak ada malware yang kelihatan, gak ada log aneh di server. Tapi datanya bocor. Solusinya? Balik ke dasar: liat traffic jaringannya.

Di challenge PicoCTF Phantom Intruder ini, lo dikasih file PCAP dan harus cari tau gimana "hantu digital" ini nyolong data. Nama challengenya dramatis, tapi tekniknya straightforward: analisis packet, kenali pola encoding, dan kumpulin flag yang tercecer di traffic.

## Deskripsi Soal

A digital ghost has breached my defenses, and my sensitive data has been stolen! Your mission is to uncover how this phantom intruder infiltrated my system and retrieve the hidden flag.

To solve this challenge, you'll need to analyze the provided PCAP file and track down the attack method. The attacker has cleverly concealed his moves in well timed manner. Dive into the network traffic, apply the right filters and show off your forensic prowess and unmask the digital intruder!

## Tahap Pengerjaan

Buka file PCAP pake Wireshark. Langkah pertama, liat dulu summary packetnya:

![alt text](2.png)

Yang langsung keliatan: ada beberapa packet yang isinya string aneh. Wireshark bisa nampilin langsung di kolom Info kalo packet tersebut readable.

Coba buka salah satu packet:

![alt text](3.png)

Ada string yang berakhiran `==`. Ini signature base64. Kalo lo udah familiar sama encoding, lo bakal langsung ngeh: kombinasi huruf besar-kecil, angka, ditutup `=` atau `==` buat padding.

Decode pake [CyberChef](https://gchq.github.io/CyberChef/):

![alt text](4.png)

Satu potongan flag dapet. Tapi flag-nya masih belum utuh. Berarti ada potongan lain di packet lain.

Cara lebih cepet: pake command `strings` di Linux buat extract semua readable string dari file PCAP:

```bash
strings [file.pcap] | grep "=="
```

![alt text](5.png)

Ini nampilin semua string base64 dalam file. Tinggal decode satu-satu pake command `base64 -d`:

```bash
echo "string_base64" | base64 -d
```

![alt text](6.png)
_Sebelum di decode_

![alt text](7.png)
_Sesudah di decode_

Gabungin semua potongan flag yang udah dapet:

```
Flag : picoCTF{1t_w4snt_th4t_34sy_tbh_4r_af160980}
```

## Kesimpulan

Challenge Phantom Intruder ini simpel tapi ngajarin kebiasaan penting. Attacker nyembunyiin data di dalam packet dengan encoding base64, tapi kalo lo tau pola yang dicari, jejak mereka gampang diikuti. Ini bedanya attacker pemula sama yang professional: encoding itu bukan enkripsi. Base64 gampang dibalik kalo lo tau cara bacanya.

Yang bikin challenge ini relatable: di dunia nyata, banyak attacker pake encoding buat nyamarin data exfiltration. Mereka ngira cukup pake base64 terus data aman. Tapi buat investigator yang tau cara liat packet dan decode, ini cuma halangan kecil.

### Takeaway Teknis

1. **Strings command** adalah tools cepat buat extract semua teks dari file biner termasuk PCAP. Gabung pake grep buat filter pola tertentu.
2. **Base64 punya signature jelas** (`[A-Za-z0-9+/]+={0,2}`). Di Wireshark, ini langsung kelihatan di kolom Info kalo packetnya gak dienkripsi.
3. **CyberChef** adalah tools online multifungsi buat encoding, decoding, dan data manipulation. Wajib ada di bookmark browser lo.
4. **PCAP analysis fundamental**: liat paket satu-satu, trus generalisasi pake tools kayak strings pas polanya udah ketemu.
