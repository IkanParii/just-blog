---
title: VoidMail Temporary Mail Documentation
description: Temporary Mail Menggunakan Cloudflare Worker, D1, dan Email Routing
date: 2026-05-31 00:00:00 +0700
categories: [Web Development, Cloudflare]
tags: [cloudflare workers, cloudflare d1, email routing, temporary mail]
---

# VoidMail

## Pengertian VoidMail

VoidMail adalah aplikasi temporary mail sederhana yang digunakan untuk membuat alamat email sementara.

Aplikasi ini berjalan menggunakan Cloudflare Worker sebagai backend, Cloudflare D1 sebagai database, dan Cloudflare Email Routing untuk menerima email masuk.

Secara sederhana, VoidMail digunakan untuk:

1. Membuat mailbox random
2. Menerima email dari domain sendiri
3. Menampilkan pesan masuk di inbox web
4. Menghapus inbox ketika sudah tidak digunakan

Project ini dibuat supaya temporary mail bisa berjalan tanpa server VPS dan tanpa framework berat.

## Teknologi yang Digunakan

Beberapa teknologi utama yang digunakan:

1. Cloudflare Worker
2. Cloudflare D1
3. Cloudflare Email Routing
4. HTML
5. Tailwind CDN
6. Vanilla JavaScript

Cloudflare Worker digunakan untuk menjalankan UI, API, dan email handler dalam satu tempat.

Cloudflare D1 digunakan untuk menyimpan pesan email yang masuk.

Cloudflare Email Routing digunakan untuk menangkap email dari domain dan meneruskannya ke Worker.

## Cara Kerja VoidMail

Alur kerja VoidMail:

1. User membuka website VoidMail
2. User generate mailbox random
3. User mendapatkan alamat seperti `random@mail.devsec.my.id`
4. Email dikirim ke alamat tersebut
5. Cloudflare Email Routing menerima email
6. Email Routing meneruskan pesan ke Worker
7. Worker membaca alamat tujuan, subject, sender, dan body email
8. Worker menyimpan data ke D1
9. Frontend mengambil data dari API inbox
10. Pesan tampil di halaman mailbox

Alurnya bisa diringkas seperti ini:

```text
Sender Email
    |
    v
Cloudflare Email Routing
    |
    v
Cloudflare Worker email()
    |
    v
Cloudflare D1
    |
    v
VoidMail Inbox UI
```

## Struktur Project

Struktur utama project:

```text
Void-Mails/
├── public/
│   ├── index.html
│   ├── app.js
│   └── styles.css
├── worker/
│   ├── src/
│   │   └── index.ts
│   ├── migrations/
│   │   └── 0001_initial.sql
│   └── wrangler.toml
├── wrangler.jsonc
├── package.json
└── README.md
```

Penjelasan:

1. `worker/src/index.ts` berisi Worker utama
2. `worker/migrations/` berisi schema D1
3. `wrangler.jsonc` berisi konfigurasi deploy Cloudflare
4. `public/` berisi static frontend fallback

## Konfigurasi Wrangler

Worker menggunakan nama:

```text
void-mai
```

Database D1 menggunakan binding:

```text
DB
```

Domain email yang digunakan:

```text
mail.devsec.my.id
```

Contoh konfigurasi pada `wrangler.jsonc`:

```json
{
  "name": "void-mai",
  "main": "worker/src/index.ts",
  "compatibility_date": "2026-05-31",
  "d1_databases": [
    {
      "binding": "DB",
      "database_name": "void-mails",
      "database_id": "DATABASE_ID",
      "migrations_dir": "worker/migrations"
    }
  ],
  "vars": {
    "MAIL_DOMAIN": "mail.devsec.my.id"
  }
}
```

## Schema Database

VoidMail menyimpan email masuk pada tabel `messages`.

Schema tabel:

```sql
CREATE TABLE IF NOT EXISTS messages (
  id TEXT PRIMARY KEY,
  mailbox TEXT NOT NULL,
  sender TEXT NOT NULL,
  subject TEXT NOT NULL,
  body TEXT NOT NULL,
  received_at TEXT NOT NULL,
  expires_at TEXT NOT NULL
);
```

Index yang digunakan:

```sql
CREATE INDEX IF NOT EXISTS messages_mailbox_idx ON messages (mailbox);
CREATE INDEX IF NOT EXISTS messages_expires_idx ON messages (expires_at);
```

Index `messages_mailbox_idx` digunakan agar query inbox berdasarkan mailbox lebih cepat.

Index `messages_expires_idx` digunakan untuk membersihkan email yang sudah expired.

## Menjalankan Project Secara Lokal

Install dependency:

```bash
npm install
```

Jalankan Worker:

```bash
npm run dev
```

Apply migration D1 lokal:

```bash
npx wrangler d1 migrations apply void-mails --local
```

Setelah itu buka URL Worker lokal yang muncul dari Wrangler.

## Deploy ke Cloudflare

Deploy Worker:

```bash
npm run deploy
```

Apply migration D1 remote:

```bash
npx wrangler d1 migrations apply void-mails --remote
```

Walaupun Worker sudah memiliki auto schema initialization, migration tetap lebih rapi untuk production.

## Setup Email Routing

Bagian ini penting karena temporary mail random tidak akan jalan kalau Email Routing hanya menerima alamat tertentu.

Untuk VoidMail, Cloudflare Email Routing harus menggunakan catch-all.

Langkah setup:

1. Masuk ke Cloudflare Dashboard
2. Pilih domain `devsec.my.id`
3. Masuk ke menu Email Routing
4. Aktifkan Email Routing
5. Pastikan MX record sudah diarahkan ke Cloudflare
6. Buat Catch-all address
7. Pilih action ke Worker
8. Pilih Worker `void-mai`
9. Save

Dengan catch-all, alamat random seperti:

```text
abc123@mail.devsec.my.id
```

tetap akan diterima dan diteruskan ke Worker.

Jika catch-all tidak aktif, email akan bounce dengan error seperti:

```text
550 5.1.1 Address does not exist
```

Artinya email belum sampai ke Worker.

## Endpoint API

### Health Check

```http
GET /health
```

Response:

```json
{
  "ok": true
}
```

### Melihat Inbox

```http
GET /api/inbox/{mailbox}
```

Contoh:

```http
GET /api/inbox/zane
```

Response:

```json
{
  "mailbox": "zane",
  "emailAddress": "zane@mail.devsec.my.id",
  "count": 1,
  "messages": []
}
```

### Melihat Detail Pesan

```http
GET /api/message/{id}
```

Endpoint ini digunakan ketika user klik salah satu pesan di inbox.

### Menghapus Inbox

```http
DELETE /api/inbox/{mailbox}
```

Endpoint ini menghapus semua pesan pada mailbox tertentu.

## Email Handler

Worker memiliki handler khusus untuk email:

```ts
async email(message, env, ctx) {
  await handleEmail(message, env);
}
```

Handler ini membaca:

1. Alamat tujuan email
2. Sender
3. Subject
4. Body plain text

Setelah itu data disimpan ke D1.

VoidMail juga sudah mendukung format alamat email seperti:

```text
Name <mailbox@mail.devsec.my.id>
```

Ini penting karena email asli sering memakai format header seperti itu.

## Troubleshooting

### Email Tidak Masuk ke Inbox

Penyebab yang paling umum:

1. Email Routing belum aktif
2. MX record belum benar
3. Catch-all belum diarahkan ke Worker
4. Worker yang dipilih bukan `void-mai`
5. Email dikirim ke domain yang salah

Cek error bounce dari Gmail atau mail provider.

Jika muncul:

```text
550 5.1.1 Address does not exist
```

Berarti Cloudflare belum menerima alamat tersebut sebagai route valid.

Solusinya adalah mengaktifkan catch-all ke Worker.

### Inbox Error 500

Kemungkinan penyebab:

1. D1 binding belum benar
2. Migration belum dijalankan
3. Tabel `messages` belum ada
4. Worker deploy belum memakai config terbaru

Command yang bisa digunakan:

```bash
npx wrangler d1 migrations apply void-mails --remote
```

### Tombol Open Mailbox Seperti Refresh

Penyebabnya biasanya JavaScript gagal memasang event handler.

Pada versi sebelumnya, script menunggu element yang tidak ada, sehingga submit form kembali ke behavior default browser.

Solusinya adalah memastikan element optional tidak membuat initialization berhenti.

### Email Bounce

Jika email bounce, berarti email belum sampai ke Worker.

Jika email sudah sampai Worker tapi tidak tampil, baru cek API inbox dan D1.

## Kelebihan VoidMail

Beberapa kelebihan VoidMail:

1. Tidak membutuhkan VPS
2. UI, API, dan email handler berada dalam satu Worker
3. Database menggunakan Cloudflare D1
4. Bisa menerima mailbox random menggunakan catch-all
5. Inbox refresh otomatis
6. Pesan ditampilkan sebagai plain text agar lebih aman

## Kekurangan VoidMail

Beberapa hal yang masih bisa dikembangkan:

1. Belum ada attachment viewer
2. Body HTML email belum dirender
3. Tidak ada autentikasi admin
4. Belum ada rate limit per mailbox
5. Belum ada dashboard observability khusus

Untuk penggunaan sederhana, fitur saat ini sudah cukup.

## Kesimpulan

VoidMail adalah temporary mail sederhana berbasis Cloudflare Worker.

Project ini cocok digunakan untuk belajar alur email routing, Worker email handler, dan D1 database.

Hal paling penting dalam project ini adalah Email Routing catch-all.

Tanpa catch-all, mailbox random tidak akan pernah sampai ke Worker dan email akan bounce.

Dengan konfigurasi yang benar, alurnya menjadi sederhana:

```text
Random mailbox -> Email Routing -> Worker -> D1 -> Inbox UI
```

