---
title: "Bikin Temporary Mail Sendiri di Cloudflare Edge Pake Workers dan D1"
description: "Build temporary mail service sendiri pake Cloudflare Workers, D1, dan Email Routing. Full guide termasuk MIME parser, setup, dan deployment."
date: 2026-05-31 00:00:00 +0700
categories: [Web Development, Cloudflare, DevOps]
tags: [Cloudflare Workers, Cloudflare D1, Email Routing, Temporary Mail, Privacy, Cybersecurity, Serverless, Edge Computing]
toc: true
comments: false
---

# Temporary Mail di Edge: VoidMail - Cloudflare Workers & D1 Guide

![VoidMail](https://images.unsplash.com/photo-1614064641938-3bbee52942c7?q=80&w=2070&auto=format&fit=crop)

Pernah daftar ke website trus inbox lo kebanjiran spam? Atau lebih parah: email lo tiba-tiba dipake buat daftar akun mencurigakan sampe lo dapet email ancaman? Gw pernah. Abis itu gw nyari solusi dan nemu ide ini: **temporary mail**. Gak perlu registrasi, gak perlu ngasih data, dapet inbox langsung. Kalo ada yang nyurigain, tinggal buang.

VoidMail adalah hasil learning gw bikin temporary mail pake **Cloudflare stack**. Yang bikin keren: semua jalan di edge network Cloudflare. No VPS, no server berat, gak perlu bayar server sendiri. Cuma modal domain + akun Cloudflare free tier.

## VoidMail Itu Apa?

VoidMail adalah aplikasi temporary mail. Lo dapet alamat email random tanpa registrasi, tanpa nyerahin inbox asli. Cocok buat cybersecurity enthusiasts yang sering daftar ke service mencurigakan. Daripada lo pake email asli trus kena spam flood atau phishing, mending pake temporary mailbox yang auto-expired.

### Filosofi

Banyak layanan online minta email lo cuma buat verifikasi doang. Tapi setelah itu? Spam, promo, kadang dibocorin ke data broker. VoidMail solusinya: **kasih alamat sementara, terima email yang lo perlukan, sisanya ilang otomatis 90 hari kemudian**.

### Yang Bisa Dilakukan VoidMail:
1. Buat mailbox random, tanpa registrasi, tanpa ngisi form
2. Terima email dari domain sendiri
3. Liat pesan masuk di web inbox
4. Hapus inbox kalo udah gak dipake
5. Lindungi email asli dari spam, phishing, data broker

---

## Tech Stack

| Teknologi | Fungsinya |
|-----------|-----------|
| Cloudflare Worker | Backend, API, email handler, SSR UI. Satu file doang |
| Cloudflare D1 | Database SQLite edge, nyimpen pesan |
| Cloudflare Email Routing | Nerima email masuk trus diterusin ke Worker |
| HTML + Tailwind CDN | Tampilan depan |
| Vanilla JavaScript | Logika frontend, tanpa framework |

## Cara Kerja VoidMail

Alurnya:

1. Lo buka website VoidMail
2. Lo generate mailbox random (bisa juga ketik manual)
3. Dapet alamat kayak `random@mail.devsec.my.id`
4. Orang kirim email ke alamat itu
5. **Cloudflare Email Routing** nerima email (catch-all)
6. Email Routing terusin pesan ke **Worker**
7. **Worker** baca alamat tujuan, sender, subject, body email
8. Worker parsing MIME: urusan multipart, quoted-printable, base64
9. Worker simpen data ke **D1** database
10. Frontend polling API inbox tiap 15 detik
11. Pesan muncul di halaman mailbox

Diagram:

```
Sender Email
    ↓
Cloudflare Email Routing (catch-all)
    ↓
Worker - email() handler
    ↓
MIME Parser (multipart / QP / base64)
    ↓
Cloudflare D1
    ↓
VoidMail Inbox UI
```

---

## Struktur Project

```
Void-Mails/
├── public/
│   ├── index.html       ← UI static (buat dev lokal)
│   ├── app.js           ← Logika frontend
│   └── styles.css
├── worker/
│   ├── src/
│   │   └── index.ts     ← Worker utama: SSR + API + email handler
│   ├── migrations/
│   │   └── 0001_initial.sql
│   └── wrangler.toml
├── docs/
│   └── *.md
├── wrangler.jsonc
└── package.json
```

Yang penting: `worker/src/index.ts` adalah satu file doang. Isinya SSR HTML, REST API, MIME parser, sama email handler. Gak perlu microservices aneh-aneh.

---

## Konfigurasi Wrangler

Worker pake nama: `void-mai`
Database D1 binding: `DB`
Domain email: `mail.devsec.my.id`

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

---

## Schema Database

Cuma satu tabel: `messages`

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

`body_format` bisa `"html"` atau `"text"`. Ini nentuin cara nampilin body di frontend.

Index:

```sql
CREATE INDEX IF NOT EXISTS messages_mailbox_idx ON messages (mailbox);
CREATE INDEX IF NOT EXISTS messages_expires_idx ON messages (expires_at);
```

- `mailbox_idx`: query inbox cepet
- `expires_idx`: cleanup pesan expired

**TTL**: 90 hari, auto cleanup.
**Batas**: 100 pesan per mailbox. Kalo lebih, pesan tertua auto-dihapus.

---

## Jalanin Project Lokal

```bash
npm install
npx wrangler d1 migrations apply void-mails --local
npm run dev
```

Buka `http://127.0.0.1:8787`.

Buat testing email lokal:

```bash
curl -X POST http://127.0.0.1:8787/api/dev/inbox/testmailbox \
  -H "Content-Type: application/json" \
  -d '{"sender":"test@example.com","subject":"Hello","body":"Test message"}'
```

---

## Deploy ke Cloudflare

```bash
npx wrangler d1 migrations apply void-mails --remote
npm run deploy
```

---

## Setup Email Routing (Bagian Paling Krusial)

Ini yang paling sering bikin VoidMail gak jalan. Kalo Email Routing cuma nerima alamat tertentu, mailbox random lo bakal bounce.

**Catch-all wajib diaktifin.**

Langkah:
1. Login Cloudflare Dashboard
2. Pilih domain `devsec.my.id`
3. Masuk ke **Email > Email Routing**
4. Aktifin Email Routing
5. Pastiin MX record udah ngarah ke Cloudflare
6. Buat **Catch-all address**
7. Action: **Send to Worker**
8. Pilih Worker `void-mai`
9. Save

Kalo catch-all gak aktif:

```
550 5.1.1 Address does not exist
```

Jebol. Email gak bakal sampe.

---

## Endpoint API

### Health Check

```http
GET /health
```

Response: `{ "ok": true }`

### Liat Inbox

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

### Detail Pesan

```http
GET /api/message/{id}
```

### Hapus Inbox

```http
DELETE /api/inbox/{mailbox}
```

---

## Email Handler & MIME Parser

Worker punya handler khusus:

```ts
async email(message, env, ctx) {
  await handleEmail(message, env);
}
```

Yang dibaca:
1. Alamat tujuan dari header `To`
2. Pengirim dari header `From`
3. Subject dari header `Subject`
4. Body email dari `message.raw` sebagai ReadableStream

### Parsing MIME, Yang Bikin Sakit Kepala

Email modern pake format MIME multipart. VoidMail punya parser sendiri (`parseMimeParts`) yang:

1. Baca semua deklarasi `boundary=` dari header email
2. Pisahin MIME part berdasarkan boundary
3. Pilih part `text/html` (prioritas) atau `text/plain` (fallback)
4. Decode body sesuai Content-Transfer-Encoding:
   - `quoted-printable`: decode karakter kayak `=20`, `=3D`, soft line break
   - `base64`: decode via `atob()`
   - `7bit` / `8bit`: langsung lewat
5. Simpen `bodyFormat` ke database

### Tampilan Body di Frontend

| bodyFormat | Cara nampilin |
|------------|---------------|
| `"html"` | Di-render dalam `<iframe sandbox>`, aman gak ada script jalan |
| `"text"` | Ditampilin dalam `<pre>` pake `.textContent`, XSS gak mempan |

---

## UI & Layout

Layout full-viewport, gak ada page scroll:

```
┌─ Header (fixed) ────────────────────────────────────┐
├─ Content (flex-1, overflow: hidden) ─────────────────┤
│  ┌─ Sidebar (w-80) ───────┬─ Viewer ───────────────┐│
│  │  Mailbox info          │  Subject                ││
│  │  Stats                 │  Metadata               ││
│  │  Label inbox           ├─────────────────────────┤│
│  │  Message list          │  Body (overflow-y)      ││
│  │    ↕ scroll            │                         ││
│  └────────────────────────┴─────────────────────────┘│
└──────────────────────────────────────────────────────┘
```

Detail:
- `html` dan `body` pake `height: 100%; overflow: hidden`
- Sidebar kiri dan panel kanan scroll sendiri-sendiri
- Header punya tombol "New mailbox" pas di mailbox view
- Klik logo VoidMail di header balik ke home

### Home Page
1. **Hero**: headline + deskripsi privasi
2. **Form mailbox**: input ID, preview alamat, tombol Generate + Open
3. **Feature cards**: Instan, Anti-tracking, Auto-hapus

---

## Troubleshooting

### Email Gak Masuk ke Inbox

Penyebab paling umum:
1. Email Routing belum aktif
2. MX record salah
3. Catch-all belum diarahkan ke Worker
4. Worker yang dipilih bukan `void-mai`
5. Email dikirim ke domain yang salah

### Body Tampil Raw HTML atau Karakter `=20` `=3D`

MIME parser gagal detect part yang bener. Pastiin Worker versi terbaru yang punya `parseMimeParts()`. Versi lama pake regex tunggal, jadi gak handle multipart boundary.

### Inbox Error 500

Kemungkinan:
1. D1 binding salah di `wrangler.jsonc`
2. Migration belum dijalankan
3. Kolom `body_format` belum ada

Solusi:

```bash
npx wrangler d1 migrations apply void-mails --remote
```

---

## Kelebihan & Kekurangan

### Kelebihan
1. **No VPS**, 100% Cloudflare edge, gak perlu bayar server
2. **Satu file doang**, UI, API, email handler semua di `index.ts`
3. **MIME parser custom**, handle multipart, quoted-printable, base64
4. **Catch-all**, mailbox random tanpa registrasi
5. **Auto-refresh**, inbox nge-refresh tiap 15 detik
6. **Sandbox iframe**, email HTML aman tanpa risiko XSS
7. **Auto-expired**, 90 hari, gak perlu cleanup manual
8. **Full-viewport**, UX mulus, gak ada double scroll
9. **No tracking**, gak perlu daftar, gak ada cookie jejak

### Kekurangan
1. Belum ada attachment viewer
2. Belum ada HTML sanitizer custom, masih ngandelin sandbox iframe
3. **No auth**, siapa pun yang tau mailbox ID bisa baca isinya
4. Belum ada rate limit per mailbox
5. Gak ada notifikasi real-time, masih polling doang

## Kesimpulan

VoidMail adalah temporary mail yang jalan di Cloudflare edge stack. Semua proses dari nerima email, parsing MIME, nyimpen ke database, sampe nampilin ke frontend terjadi di edge worker. Tanpa VPS. Tanpa server backend sendiri. Modal domain dan akun Cloudflare.

Yang paling penting di project ini: **Email Routing catch-all** dan **MIME parser**. Kalo dua hal itu udah bener, sisanya tinggal jalan. Kalo error, cek lagi catch-all sama MIME parsingnya.

### Takeaway Teknis

1. **Cloudflare Workers bisa handle full stack** termasuk email processing. Worker bisa nerima email dari Email Routing, parse, dan simpen ke D1.
2. **MIME parsing adalah bagian tersulit** dari email handling. Format multipart, quoted-printable, dan beragam encoding harus dihandle dengan bener.
3. **D1 (SQLite di edge)** cukup buat aplikasi skala kecil. Gak perlu setup database server sendiri.
4. **Catch-all Email Routing** adalah kunci utama. Tanpa ini, alamat email random gak bakal sampe ke worker.
5. **Serverless architecture** mengurangi biaya operasional. VoidMail jalan di free tier Cloudflare, cuma bayar domain doang per tahun.
