---
title: VoidMail Temporary Mail Documentation
description: Temporary Mail Menggunakan Cloudflare Worker, D1, dan Email Routing
date: 2026-05-31 00:00:00 +0700
categories: [Web Development, Cloudflare]
tags: [cloudflare workers, cloudflare d1, email routing, temporary mail, privacy, cybersecurity]
---

# VoidMail

## Pengertian VoidMail

VoidMail adalah aplikasi temporary mail berbasis privasi yang digunakan untuk membuat alamat email sementara tanpa registrasi.

Aplikasi ini berjalan menggunakan Cloudflare Worker sebagai backend, Cloudflare D1 sebagai database, dan Cloudflare Email Routing untuk menerima email masuk.

VoidMail dibuat sebagai tools cybersecurity sederhana untuk melindungi identitas digital — inbox asli tidak perlu diserahkan ke layanan yang tidak dipercaya.

Secara sederhana, VoidMail digunakan untuk:

1. Membuat mailbox random tanpa daftar
2. Menerima email dari domain sendiri
3. Menampilkan pesan masuk di inbox web
4. Menghapus inbox ketika sudah tidak digunakan
5. Melindungi email asli dari spam, phishing, dan data broker

Project ini berjalan tanpa VPS dan tanpa framework berat.

## Teknologi yang Digunakan

| Teknologi | Fungsi |
|---|---|
| Cloudflare Worker | Backend, API, email handler, dan SSR UI dalam satu file |
| Cloudflare D1 | Database SQLite edge untuk menyimpan pesan |
| Cloudflare Email Routing | Menerima email masuk dan meneruskan ke Worker |
| HTML + Tailwind CDN | UI frontend |
| Vanilla JavaScript | Logika frontend tanpa framework |

## Cara Kerja VoidMail

Alur kerja VoidMail:

1. User membuka website VoidMail
2. User generate mailbox random (atau ketik sendiri)
3. User mendapatkan alamat seperti `random@mail.devsec.my.id`
4. Email dikirim ke alamat tersebut
5. Cloudflare Email Routing menerima email via catch-all
6. Email Routing meneruskan pesan ke Worker
7. Worker membaca alamat tujuan, subject, sender, dan body email
8. Worker melakukan parsing MIME (multipart, quoted-printable, base64)
9. Worker menyimpan data ke D1
10. Frontend polling API inbox setiap 15 detik
11. Pesan tampil di halaman mailbox

Diagram alur:

```text
Sender Email
    |
    v
Cloudflare Email Routing (catch-all)
    |
    v
Cloudflare Worker — email() handler
    |
    v
MIME Parser (multipart / QP / base64)
    |
    v
Cloudflare D1
    |
    v
VoidMail Inbox UI
```

## Struktur Project

```text
Void-Mails/
├── public/
│   ├── index.html       ← Static frontend (local dev / file://)
│   ├── app.js           ← Logika frontend
│   └── styles.css
├── worker/
│   ├── src/
│   │   └── index.ts     ← Worker utama (SSR + API + email handler)
│   ├── migrations/
│   │   └── 0001_initial.sql
│   └── wrangler.toml
├── docs/
│   └── *.md
├── wrangler.jsonc
└── package.json
```

Penjelasan:

- `worker/src/index.ts` — satu file berisi semua: SSR HTML, REST API, MIME parser, dan email handler
- `public/` — static fallback untuk development lokal via `file://` atau `127.0.0.1`
- `wrangler.jsonc` — konfigurasi deploy Cloudflare

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
  body_format TEXT NOT NULL DEFAULT 'text',
  received_at TEXT NOT NULL,
  expires_at TEXT NOT NULL
);
```

Kolom `body_format` menyimpan nilai `"html"` atau `"text"` — menentukan cara body ditampilkan di frontend.

Index yang digunakan:

```sql
CREATE INDEX IF NOT EXISTS messages_mailbox_idx ON messages (mailbox);
CREATE INDEX IF NOT EXISTS messages_expires_idx ON messages (expires_at);
```

- `messages_mailbox_idx` — mempercepat query inbox berdasarkan mailbox
- `messages_expires_idx` — mempercepat cleanup pesan expired

Pesan otomatis dihapus setelah **90 hari** (TTL = `90 * 24 * 60 * 60` detik).

Setiap mailbox dibatasi maksimal **100 pesan**. Pesan terlama dihapus otomatis jika melebihi batas.

## Menjalankan Project Secara Lokal

Install dependency:

```bash
npm install
```

Apply migration D1 lokal:

```bash
npx wrangler d1 migrations apply void-mails --local
```

Jalankan Worker:

```bash
npm run dev
```

Buka `http://127.0.0.1:8787` di browser.

Untuk testing email masuk secara lokal, gunakan endpoint dev seed:

```bash
curl -X POST http://127.0.0.1:8787/api/dev/inbox/testmailbox \
  -H "Content-Type: application/json" \
  -d '{"sender":"test@example.com","subject":"Hello","body":"Test message"}'
```

Endpoint ini hanya aktif di `localhost` atau jika `ENABLE_DEV_SEED=true`.

## Deploy ke Cloudflare

Apply migration D1 remote:

```bash
npx wrangler d1 migrations apply void-mails --remote
```

Deploy Worker:

```bash
npm run deploy
```

## Setup Email Routing

Bagian ini penting karena temporary mail random tidak akan jalan kalau Email Routing hanya menerima alamat tertentu.

Untuk VoidMail, Cloudflare Email Routing harus menggunakan **catch-all**.

Langkah setup:

1. Masuk ke Cloudflare Dashboard
2. Pilih domain `devsec.my.id`
3. Masuk ke menu **Email → Email Routing**
4. Aktifkan Email Routing
5. Pastikan MX record sudah diarahkan ke Cloudflare
6. Buat **Catch-all address**
7. Pilih action: **Send to Worker**
8. Pilih Worker `void-mai`
9. Save

Dengan catch-all, alamat random seperti `abc123@mail.devsec.my.id` tetap diterima dan diteruskan ke Worker.

Jika catch-all tidak aktif, email akan bounce:

```text
550 5.1.1 Address does not exist
```

## Endpoint API

### Health Check

```http
GET /health
```

Response:

```json
{ "ok": true }
```

### Melihat Inbox

```http
GET /api/inbox/{mailbox}
```

Response:

```json
{
  "mailbox": "abc123",
  "emailAddress": "abc123@mail.devsec.my.id",
  "count": 2,
  "messages": [
    {
      "id": "uuid",
      "mailbox": "abc123",
      "sender": "noreply@service.com",
      "subject": "Verify your email",
      "body": "...",
      "bodyFormat": "html",
      "receivedAt": "2026-05-31T08:00:00.000Z",
      "expiresAt": "2026-08-29T08:00:00.000Z"
    }
  ]
}
```

### Melihat Detail Pesan

```http
GET /api/message/{id}
```

Mengembalikan satu pesan lengkap dengan body penuh dan `bodyFormat`.

### Menghapus Inbox

```http
DELETE /api/inbox/{mailbox}
```

Menghapus semua pesan pada mailbox tertentu.

### Dev Seed (lokal only)

```http
POST /api/dev/inbox/{mailbox}
```

Body:

```json
{
  "sender": "test@example.com",
  "subject": "Test",
  "body": "Hello world"
}
```

Hanya aktif di `localhost` atau jika env `ENABLE_DEV_SEED=true`.

## Email Handler & MIME Parser

Worker memiliki handler khusus untuk email masuk:

```ts
async email(message, env, ctx) {
  await handleEmail(message, env);
}
```

Handler membaca:

1. Alamat tujuan (dari header `To` atau `message.to`)
2. Sender (dari header `From` atau `message.from`)
3. Subject (dari header `Subject`)
4. Body email (dari `message.raw` sebagai `ReadableStream`)

### Parsing MIME

Email modern menggunakan format MIME multipart. VoidMail memiliki parser sendiri (`parseMimeParts`) yang:

1. Membaca semua deklarasi `boundary=` dari header email
2. Memisahkan setiap MIME part berdasarkan boundary
3. Memilih part `text/html` (prioritas utama) atau `text/plain` sebagai fallback
4. Mendecode body sesuai `Content-Transfer-Encoding`:
   - `quoted-printable` — decode karakter seperti `=20`, `=3D`, soft line break `=\n`
   - `base64` — decode via `atob()`
   - `7bit` / `8bit` — pass-through
5. Menyimpan `bodyFormat: "html"` atau `"text"` ke database

Deteksi HTML juga mengenali `<!DOCTYPE html>` selain `<html>` dan `<body>`.

### Tampilan Body di Frontend

| `bodyFormat` | Cara tampil |
|---|---|
| `"html"` | Dirender dalam `<iframe sandbox>` — aman, tanpa script |
| `"text"` | Ditampilkan dalam `<pre>` dengan `.textContent` — aman dari XSS |

## UI & Layout

VoidMail menggunakan layout full-viewport tanpa page scroll:

```text
┌─ Header (fixed height) ──────────────────────────────┐
├─ Content (flex-1, overflow: hidden) ─────────────────┤
│  ┌─ Sidebar (w-80, scroll sendiri) ─┬─ Viewer ──────┐│
│  │  Mailbox info                    │  Subject       ││
│  │  Stats                           │  Metadata      ││
│  │  Inbox label                     ├────────────────┤│
│  │  Message list (overflow-y-auto)  │  Body          ││
│  │    ↕ scroll                      │  (overflow-y)  ││
│  └──────────────────────────────────┴────────────────┘│
└──────────────────────────────────────────────────────┘
```

- `html` dan `body` menggunakan `height: 100%; overflow: hidden` — tidak ada page scroll
- Sidebar kiri dan panel kanan masing-masing scroll secara independen
- Header memiliki tombol **"← New mailbox"** yang muncul saat di mailbox view
- Klik logo VoidMail di header juga kembali ke home

### Home Page

Home page menampilkan:

1. **Hero** — headline dan deskripsi singkat tentang privasi
2. **Form mailbox** — input ID, preview alamat, tombol Generate dan Open
3. **Feature cards** — Instan, Anti-tracking, Auto-hapus

### Inbox List

Setiap item di inbox menampilkan:

- Nama pengirim (display name diekstrak dari format `"Name <email>"`)
- Waktu terima
- Subject (truncated)

Body preview tidak ditampilkan di list — hanya muncul saat pesan dibuka.

### Message Viewer

Saat pesan dibuka:

- Subject sebagai heading utama
- Metadata (From, Received, Expires) dalam satu blok compact
- Body dirender sesuai `bodyFormat`
- Tab title browser diupdate ke subject pesan

## Troubleshooting

### Email Tidak Masuk ke Inbox

Penyebab paling umum:

1. Email Routing belum aktif
2. MX record belum benar
3. Catch-all belum diarahkan ke Worker
4. Worker yang dipilih bukan `void-mai`
5. Email dikirim ke domain yang salah

Jika muncul bounce:

```text
550 5.1.1 Address does not exist
```

Berarti catch-all belum aktif. Aktifkan catch-all ke Worker di Cloudflare Dashboard.

### Body Email Tampil Sebagai Raw HTML / Karakter `=20` `=3D`

Ini terjadi jika MIME parser gagal mendeteksi part yang benar.

Pastikan Worker sudah menggunakan versi terbaru yang memiliki `parseMimeParts()`. Versi lama menggunakan regex tunggal yang tidak menangani multipart boundary dengan benar.

### Inbox Error 500

Kemungkinan penyebab:

1. D1 binding belum benar di `wrangler.jsonc`
2. Migration belum dijalankan
3. Kolom `body_format` belum ada (jalankan migration)

Solusi:

```bash
npx wrangler d1 migrations apply void-mails --remote
```

### Email Bounce

Jika email bounce sebelum sampai Worker → masalah di Email Routing / MX record.

Jika email sudah sampai Worker tapi tidak tampil → cek API inbox dan D1.

## Kelebihan VoidMail

1. Tidak membutuhkan VPS — berjalan 100% di Cloudflare edge
2. UI, API, dan email handler dalam satu Worker file
3. MIME parser custom — mendukung multipart, quoted-printable, base64
4. Mailbox random dengan catch-all
5. Inbox auto-refresh setiap 15 detik
6. HTML email dirender dalam iframe sandbox — aman dari XSS
7. Pesan auto-expired setelah 90 hari
8. Layout full-viewport tanpa double scroll
9. Tanpa registrasi, tanpa tracking

## Kekurangan VoidMail

1. Belum ada attachment viewer
2. Belum ada sanitizer HTML custom selain sandbox iframe
3. Tidak ada autentikasi — siapa pun yang tahu mailbox ID bisa membaca isinya
4. Belum ada rate limit per mailbox
5. Tidak ada notifikasi real-time (hanya polling)

## Kesimpulan

VoidMail adalah temporary mail berbasis privasi yang berjalan di Cloudflare edge stack.

Project ini cocok sebagai tools cybersecurity sederhana untuk melindungi identitas digital, belajar alur email routing, Worker email handler, MIME parsing, dan D1 database.

Hal paling penting dalam project ini adalah **Email Routing catch-all** dan **MIME parser** yang benar.

Tanpa catch-all, mailbox random tidak akan pernah sampai ke Worker.
Tanpa MIME parser yang benar, body email akan tampil sebagai raw text atau karakter encoding yang tidak terbaca.

Alur lengkap:

```text
Random mailbox → Email Routing → Worker → MIME Parser → D1 → Inbox UI
```
