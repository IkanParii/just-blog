---
title: "Hardening VPS 2GB RAM biar Aman dari Bot dan Script Kiddie"
date: 2026-07-06 00-00-00 
categories: [SysAdmin, Hardening, Linux, Blue Team]
authors: [fachri]
tags: [VPS, Security, Hardening, Linux, UFW, Fail2Ban, SSH Security, SysAdmin, Server Hardening]
toc: true
comments: false
description: "Panduan hardening VPS 2GB RAM / 2 CPU dari awal: SSH hardening, UFW firewall, Fail2Ban, sysctl tuning, AIDE, dan performance tuning untuk server production."
media_subpath: /content/img/vps-hardening
---

# Hardening VPS 2GB RAM: Langkah Bertahan dari Script Kiddie

![Hardening](https://images.unsplash.com/photo-1558494949-ef010cbdcc31?q=80&w=1934&auto=format&fit=crop)

Beli VPS baru, langsung SSH sebagai root. Pertanyaan pertama: "Apa yang harus gw lakuin sekarang?" Banyak jawab "install panel" atau "setup web server". Padahal prioritas nomor satu: **hardening**. Soalnya, VPS baru itu kayak rumah baru tanpa kunci. Attacker pake bot yang scan internet 24/7 buat cari SSH di port 22. Lo connect 5 menit aja udah bisa kena brute force.

Ini urutan langkah hardening yang gw lakuin tiap kali beli VPS. Tinggal salin, tapi baca dulu tiap bagian biar lo paham apa yang terjadi.

> Butuh akses root atau sudo buat jalanin perintah di bawah.

---

## 1. Update System & Auto Update

Update dulu semua package. Lo gak mau server baru tapi pake package lawas yang ada vuln publik:

```bash
apt update && apt upgrade -y
apt install unattended-upgrades -y
dpkg-reconfigure --priority=low unattended-upgrades
```

Biar update jalan otomatis:

```bash
cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF
```

---

## 2. SSH Hardening

Ini bagian paling kritikal. Jangan biarin SSH di port 22 pake root login. Bot dan script kiddie bakal terus nyoba.

### 2.1 Ganti Port SSH (Wajib)

Pilih port antara 1024-65535. Jangan pake 2222 atau 8080, bot juga scan itu.

```bash
NEW_SSH_PORT=22022
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i "s/#Port 22/Port $NEW_SSH_PORT/" /etc/ssh/sshd_config
```

### 2.2 Disable Root Login & Password Auth (Wajib)

Sebelum jalanin ini, pastiin lo udah punya user non-root dengan SSH key. Kalo belum:

```bash
adduser zane
usermod -aG sudo zane
mkdir -p /home/zane/.ssh
cp ~/.ssh/authorized_keys /home/zane/.ssh/
chown -R zane:zane /home/zane/.ssh
chmod 700 /home/zane/.ssh
chmod 600 /home/zane/.ssh/authorized_keys
```

Baru disable root login dan password auth:

```bash
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 300/' /etc/ssh/sshd_config
sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 2/' /etc/ssh/sshd_config
sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding no/' /etc/ssh/sshd_config
sed -i 's/#X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config

systemctl restart sshd
```

**⚠️ JANGAN close sesi SSH lama sebelum test koneksi baru di terminal lain!**

### 2.3 Allow Hanya User Tertentu

```bash
echo "AllowUsers zane" >> /etc/ssh/sshd_config
systemctl restart sshd
```

---

## 3. Firewall (UFW)

UFW bikin aturan firewall simpel. Buat VPS murah, ini cukup tanpa perlu ribet iptables.

```bash
apt install ufw -y

ufw default deny incoming
ufw default allow outgoing

ufw allow 22022/tcp comment 'SSH custom port'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw limit 22022/tcp comment 'SSH rate limited'

ufw --force enable
ufw status numbered
```

Output yang bener:

```
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 22022/tcp (SSH)           ALLOW IN    Anywhere
[ 2] 80/tcp                    ALLOW IN    Anywhere
[ 3] 443/tcp                   ALLOW IN    Anywhere
[ 4] 22022/tcp                 LIMIT IN    Anywhere
```

---

## 4. Fail2Ban (Proteksi Brute Force)

Fail2Ban baca log, ban IP yang nyoba brute force. Temen sejati UFW.

```bash
apt install fail2ban -y
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

Konfigurasi custom:

```bash
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
ignoreip = 127.0.0.1/8 ::1

[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s

[recidive]
enabled = true
logpath = /var/log/fail2ban.log
banaction = ufw
bantime = 86400
findtime = 86400
maxretry = 3
EOF

systemctl enable fail2ban
systemctl restart fail2ban
fail2ban-client status
```

Cek status:

```bash
fail2ban-client status sshd
```

---

## 5. Kernel Hardening (sysctl)

Tweak kernel biar lebih aman dari network attack.

```bash
cat >> /etc/sysctl.d/99-hardening.conf << 'EOF'
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.core.netdev_max_backlog = 1000
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF

sysctl -p /etc/sysctl.d/99-hardening.conf
```

---

## 6. Matiin Service Gak Kepake

VPS murah, resource terbatas. Matiin yang gak perlu.

```bash
systemctl list-units --type=service --state=running

systemctl stop cups 2>/dev/null
systemctl disable cups 2>/dev/null
systemctl stop avahi-daemon 2>/dev/null
systemctl disable avahi-daemon 2>/dev/null
systemctl stop rpcbind 2>/dev/null
systemctl disable rpcbind 2>/dev/null
```

Cek port listening. Kalo ada port kebuka selain SSH/HTTP/HTTPS, ada service jalan:

```bash
ss -tulpn
```

Output ideal:

```
State    Recv-Q   Send-Q     Local Address:Port     Peer Address:Port   Process
LISTEN   0        128              0.0.0.0:22022          0.0.0.0:*       users:(("sshd",...))
LISTEN   0        511              0.0.0.0:80             0.0.0.0:*       users:(("nginx",...))
LISTEN   0        511              0.0.0.0:443            0.0.0.0:*       users:(("nginx",...))
```

---

## 7. LogWatch (Laporan Harian)

Biar tau aktivitas VPS tanpa buka log tiap hari.

```bash
apt install logwatch -y

cat > /etc/cron.d/00logwatch << 'EOF'
MAILTO=""
0 6 * * * root /usr/sbin/logwatch --output mail --mailto root --detail high
EOF
```

Kalo pengen liat langsung:

```bash
logwatch --detail high
```

---

## 8. AIDE (Integrity Check)

AIDE ngecek kalo ada file system yang diubah. Ngebantu detection kalo ada yang berhasil masuk.

```bash
apt install aide -y
aideinit
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

echo "0 5 * * * root /usr/bin/aide --check > /var/log/aide-check.log" > /etc/cron.d/aide
```

Kalo abis install package baru, update database:

```bash
aide --update
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
```

---

## 9. Swap & Performance Tuning (2GB RAM)

RAM 2GB cepet penuh. Swap bantuin biar gak mati mendadak.

```bash
swapon --show

fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

echo '/swapfile none swap sw 0 0' >> /etc/fstab
echo 'vm.swappiness=10' >> /etc/sysctl.d/99-hardening.conf
sysctl -p /etc/sysctl.d/99-hardening.conf
```

---

## 10. One-liner Hardening Summary

Buat lo yang males baca satu satu. Tapi baca dulu bagian SSH hardening dan pastiin udah punya user + SSH key. Kalo enggak, lo bakal terkunci.

```bash
#!/bin/bash
# VPS Hardening One-Shot -- jalanin sebagai root
# PASTIKAN UDAH SETUP SSH KEY USER SEBELUM JALANIN INI

NEW_SSH_PORT=${1:-22022}
YOUR_USER=${2:-zane}

echo "[+] Update system..."
apt update && apt upgrade -y
apt install unattended-upgrades ufw fail2ban logwatch aide -y

echo "[+] Auto updates..."
dpkg-reconfigure --priority=low unattended-upgrades -f noninteractive

echo "[+] SSH hardening on port $NEW_SSH_PORT..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i "s/#Port 22/Port $NEW_SSH_PORT/" /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-root/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config
sed -i 's/AllowAgentForwarding.*/AllowAgentForwarding no/' /etc/ssh/sshd_config
sed -i 's/X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
echo "AllowUsers $YOUR_USER" >> /etc/ssh/sshd_config

echo "[+] Firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow $NEW_SSH_PORT/tcp comment 'SSH'
ufw limit $NEW_SSH_PORT/tcp comment 'SSH rate-limit'
ufw --force enable

echo "[+] sysctl hardening..."
cat >> /etc/sysctl.d/99-hardening.conf << 'EOF'
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.default.arp_ignore = 1
EOF
sysctl -p /etc/sysctl.d/99-hardening.conf

echo "[+] Swap 2GB..."
if ! swapon --show | grep -q swapfile; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
  sysctl vm.swappiness=10
fi

echo "[+] Restart SSH (jangan close sesi ini)..."
systemctl restart sshd

echo ""
echo "=== DONE ==="
echo "Test SSH di terminal baru:"
echo "  ssh -p $NEW_SSH_PORT $YOUR_USER@<ip-vps>"
echo "Kalo berhasil, sesi ini bisa ditutup."
```

Simpan script ke `harden.sh`, jalanin:

```bash
chmod +x harden.sh
sudo ./harden.sh
```

---

## 11. Checklist Selesai?

- [ ] SSH key-based auth (password disabled)
- [ ] Port SSH bukan 22
- [ ] Root login disabled
- [ ] UFW aktif, cuma port perlu yang kebuka
- [ ] Fail2Ban jalan
- [ ] Unattended-upgrades aktif
- [ ] sysctl hardening kepasang
- [ ] Service gak perlu udah mati
- [ ] Swap 2GB terpasang
- [ ] AIDE database udah dibikin
- [ ] Koneksi SSH di port baru jalan lancar

## Kesimpulan

VPS murah bukan berarti lo bisa abaikan security. Langkah-langkah di atas bikin attacker males duluan buat nyentuh server lo. Bot yang nge-scan port 22 langsung dapet respon "connection refused" atau "connection timeout". Script kiddie yang nyoba brute force bakal kena ban sama Fail2Ban.

Gak ada sistem yang 100% aman, tapi lo udah bikin barrier yang cukup tinggi. Attacker bakal milih target yang lebih gampang daripada harus lawan UFW + Fail2Ban + SSH key-only + port acak.

### Takeaway Teknis

1. **SSH hardening adalah prioritas #1.** Ganti port, disable root login, key-only auth. Tanpa ini, server lo jadi target empuk bot brute force.
2. **Firewall berlapis:** UFW buat aturan dasar, Fail2Ban buat dynamic blocking. Kombinasi ini nge-cover serangan dari berbagai arah.
3. **Kernel hardening via sysctl** ngurangin attack surface di layer jaringan. Redirect, source routing, dan martian logging wajib diatur.
4. **Resource management** (swap, service minimal) penting buat VPS 2GB. Setiap MB berharga.
5. **Monitoring dan integrity check** (LogWatch + AIDE) ngasih visibilitas kalo ada yang aneh. Lo bakal tau kalo ada file system yang berubah tanpa izin.

Inget: keamanan itu proses, bukan sekali jalan. Cek log, update rutin, evaluasi apa yang jalan di VPS lo.

Referensi:
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
- [Ubuntu Security Documentation](https://ubuntu.com/security)
