# Content Rewrite & SEO Optimization Spec

**Date:** 2026-07-11
**Scope:** Rewrite all 13 blog posts — titles, narrative depth, conclusions, SEO
**Voice:** Zane/Fachri — casual Indo-tech ("lo/gw"), campur Inggris-Indonesia, teknis langsung ke inti

---

## 1. Title Formula

Bentuk: **[Hook :] [Teknik/Tools] [Platform]**

Aturan:
- Hook di depan — bikin penasaran atau kasi gambaran serangan
- Platform name (HTB, PicoCTF, CyberDefenders, IDN Networkers) tetap visible
- Max 70 karakter biar gak kepotong di SERP
- Include kata kunci teknis (forensic, analysis, walkthrough, dll)

**Title Mapping:**

| Old Title | New Title |
|-----------|-----------|
| Warm Up IDN : Forensic | Eksplorasi Metadata & Base64: Walkthrough Forensic PicoCTF (IDN Warm-Up) |
| Event Viewing | Malware di Event Viewer: Forensic PicoCTF Lewat Windows Logs |
| PSExec Hunt | Lateral Movement Terdeteksi: Analisis PCAP PsExec dari CyberDefenders |
| Brutus HTB | SSH Brute Force Terungkap: Walkthrough Forensic Brutus dari Hack The Box |
| Phantom Intruder | Hantu Digital di Jaringan: Forensic PCAP PicoCTF Phantom Intruder |
| Firewall Documentation | UFW Handbook: Panduan Lengkap Firewall Linux dari Dasar |
| WebStrike | Webshell & RCE: Analisis PCAP Serangan Web dari CyberDefenders |
| VPS Murah Hardening Guide | Hardening VPS 2GB RAM: Langkah Bertahan dari Script Kiddie |
| IDN Week 4 Last Bos | 10 Soal Forensic SIEM: Analisis Log dengan Wazuh (IDN Week 4) |
| Introduction To Digital Forensic : Lab 01 | Digital Forensic Lab: 10 Command Linux Dasar untuk Investigasi |
| AOTR 1 HTB | Email Phishing ke RCE: Investigasi AOTR Part 1 dari Hack The Box |
| AOTR 2 HTB | Forum Kriminal & Heist: OSINT Investigation AOTR Part 2 HTB |
| VoidMail Cloudflare | Temporary Mail di Edge: VoidMail - Cloudflare Workers & D1 Guide |

---

## 2. Content Structure (per post)

### Front Matter
- `title:` → new title (max 70 chars)
- `description:` → rewrite dengan keyword target, max 150 chars, include hook
- `tags:` → add missing keywords, minimal 4, relevan

### Body Format
```
# [Judul Baru]

[Gambar cover]

## Pembuka (Naratif Teknis)
2-3 paragraf cerita — "Bayangkan lo sebagai SOC analyst..."
Konteks serangan dari dunia nyata, relevansi skill yang dipelajari.

## Isi (Existing content enhanced)
- Keep step-by-step Q&A untuk CTF
- Tambah insight teknis: "kenapa ini penting", "what attacker did next"
- Voice: lo/gw, campur Inggris-Indonesia
- Command dan code block tetap sama
- Screenshot dan referensi gambar tetap

## Kesimpulan
### Naratif
Paragraf penutup — refleksi: dari serangan ini, apa yang lo bawa pulang?

### Takeaway Teknis
1. Poin 1 — insight teknis spesifik
2. Poin 2 — tools/teknik yang dipelajari
3. Poin 3 — relevansi ke real-world
4. Poin 4 — MITRE mapping kalo relevan
```

---

## 3. SEO Strategy

### Per Post
- **Primary keyword:** turunan dari platform + teknik (e.g., "HTB Brutus SSH forensic analysis")
- **Secondary keywords:** tools yang dipake (auth.log, wtmp, Wazuh, Volatility, etc.)
- **Description rewrite:** include primary keyword, action-oriented, <150 chars
- **Tags:** minimum 4, maximum 8

### Global
- Pastiin every post punya description non-kosong
- Tags konsisten antar post (e.g., "Hack The Box" bukan "HTB" dan "HackTheBox")
- Gunakan `alt text` deskriptif di semua gambar (existing masih pake "alt text")

---

## 4. Tone Guide

| Element | Style |
|---------|-------|
| Pronouns | gw, lo, kita |
| Technical terms | English (biar gak ambigu) |
| Explanations | Indonesia, straight to point |
| Emphasis | bold buat istilah penting |
| Warnings | `⚠️` atau `>` blockquote |
| Examples | "Misal..." atau "Contoh:" |
| Transition | "Next..." "Yang seremnya..." "Lo bisa bayangin..." |

---

## 5. Execution Order

1. Warm Up IDN (pilot — first to rewrite as sample)
2. Event Viewing
3. PSExec Hunt
4. Brutus HTB
5. Phantom Intruder
6. Firewall Documentation
7. WebStrike
8. VPS Hardening
9. LastBos IDN
10. IntroToForensic
11. AOTR1 HTB
12. AOTR2 HTB
13. VoidMail

Post-by-post. User review tiap 2-3 post.

---

## 6. Success Criteria

- [ ] All 13 titles changed — hooks active, platform names preserved
- [ ] Every post has narrative opening + technical conclusion
- [ ] Description rewritten with SEO keywords
- [ ] Tags optimized and consistent
- [ ] Voice consistent across all posts
- [ ] No broken links or images
