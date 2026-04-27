# 🦞 OpenClaw + MiniMax — Server Production

OpenClaw dengan MiniMax M2.7, siap deploy di server Ubuntu dengan HTTPS, Telegram, auto-restart, dan monitoring.

---

## 🏗️ Arsitektur

```
Internet
   │
   ▼
[UFW Firewall]  ← hanya port 22, 80, 443
   │
   ▼
[Nginx]  ← HTTPS + rate limiting + SSL termination
   │        (port 443 publik → port 18789 internal)
   ▼
[OpenClaw Gateway]  ← tidak expose ke publik langsung
   │
   ├── MiniMax M2.7 API
   └── Telegram Bot
   
[Watchtower]  ← auto-update image harian
[Healthcheck Cron]  ← monitor + alert Telegram tiap 5 menit
[Fail2Ban]  ← proteksi brute force SSH
```

---

## 📋 Prasyarat

| Item | Keterangan |
|------|-----------|
| Server | Ubuntu 22.04 / 24.04, min 1 vCPU, 2GB RAM, 20GB disk |
| Akses | SSH dengan sudo/root |
| IP Publik | IP statis dari provider VPS |
| MiniMax API Key | [platform.minimax.io](https://platform.minimax.io) |
| Telegram Bot Token | Dari [@BotFather](https://t.me/BotFather) |

> **Catatan untuk IP Publik:** Karena menggunakan IP langsung (bukan domain), SSL dari Let's Encrypt **tidak bisa** digunakan (Let's Encrypt tidak support IP). Nginx akan berjalan di HTTP saja, atau gunakan self-signed cert. Untuk HTTPS penuh, disarankan beli domain murah (mulai Rp 15.000/tahun).

---

## 🚀 Deploy ke Server

### 1. Upload ke server

```bash
# Di laptop lokal — clone repo
git clone https://github.com/<username>/openclaw-server.git

# Upload ke server
scp -r openclaw-server user@IP_SERVER:/home/user/
ssh user@IP_SERVER
cd openclaw-server
```

### 2. Isi konfigurasi

```bash
cp .env.example .env
nano .env
```

Isi semua nilai yang diperlukan:

```env
MINIMAX_API_KEY=sk-xxxxxxxx
SERVER_DOMAIN=123.456.789.0    # IP publik server kamu
CERTBOT_EMAIL=your@email.com
TELEGRAM_BOT_TOKEN=            # opsional, isi setelah buat bot
```

### 3. Jalankan setup

```bash
sudo make init
```

Script otomatis akan:
- ✅ Update sistem Ubuntu
- ✅ Install Docker
- ✅ Konfigurasi UFW firewall
- ✅ Setup Fail2Ban
- ✅ Onboarding OpenClaw + MiniMax
- ✅ Start gateway, Nginx, Watchtower
- ✅ Request SSL certificate
- ✅ Setup systemd (auto-start saat reboot)

### 4. Setup Telegram

```bash
make telegram
# ikuti instruksi, lalu:
make pair-telegram
```

### 5. Setup monitoring alert

```bash
# Tambah TELEGRAM_CHAT_ID ke .env dulu
# (kirim pesan ke @userinfobot untuk dapat chat ID)
nano .env   # isi TELEGRAM_CHAT_ID

make monitoring
```

---

## 📌 Perintah Sehari-hari

```bash
make status        # cek status semua service
make logs          # log gateway real-time
make logs-nginx    # log nginx real-time
make restart       # restart service
make update        # update OpenClaw
make models        # cek model MiniMax
make dashboard     # URL dashboard + token
make shell         # masuk container
```

---

## 🔒 Keamanan yang Sudah Diterapkan

| Layer | Mekanisme |
|-------|-----------|
| Firewall | UFW — hanya port 22, 80, 443 |
| Brute Force | Fail2Ban — ban IP setelah 5x gagal |
| Gateway | Tidak expose ke publik (internal only) |
| Proxy | Nginx dengan rate limiting (30 req/menit) |
| SSL | Let's Encrypt via Certbot (auto-renew) |
| Container | Network isolation (internal bridge) |
| Secrets | `.env` di `.gitignore`, tidak pernah di-commit |
| Logs | Rotasi otomatis (max 10MB per file) |

---

## 🛠️ Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Gateway down | `make logs` → cek error, lalu `make restart` |
| SSL gagal | Pastikan port 80 terbuka: `ufw status` |
| Nginx 502 | Gateway belum ready, tunggu 30 detik |
| Telegram tidak reply | Cek pairing: `make pair-telegram` |
| Disk penuh | `docker system prune -f` |
| Port 443 tidak bisa diakses | `ufw allow 443/tcp && ufw reload` |

---

## 📁 Struktur File

```
openclaw-server/
├── .github/workflows/check.yml    # GitHub Actions daily check
├── config/openclaw.json           # Konfigurasi MiniMax
├── monitoring/
│   └── healthcheck.sh             # Cron monitor + Telegram alert
├── nginx/
│   ├── nginx.conf                 # Config utama Nginx
│   └── conf.d/openclaw.conf       # Proxy + SSL config
├── scripts/
│   ├── server-init.sh             # Setup pertama kali (jalankan sekali)
│   ├── setup-telegram.sh          # Setup integrasi Telegram
│   ├── pair-telegram.sh           # Pair akun Telegram
│   ├── status.sh                  # Cek status semua service
│   ├── update.sh                  # Update image
│   └── renew-ssl.sh               # Renew SSL manual
├── workspace/                     # File kerja agent
├── logs/                          # Log gateway & nginx
├── docker-compose.yml             # Semua service
├── Makefile                       # Shortcut perintah
├── .env.example                   # Template (aman di-commit)
├── .env                           # Secrets (JANGAN di-commit!)
└── README.md
```

---

## 🔄 Update OpenClaw

```bash
make update
```

Watchtower juga otomatis cek update setiap 24 jam. Jika ada versi baru, container akan di-update dan notifikasi dikirim ke Telegram (jika dikonfigurasi).

---

## 📚 Referensi

- [OpenClaw Docs](https://docs.openclaw.ai)
- [OpenClaw MiniMax Provider](https://docs.openclaw.ai/providers/minimax)
- [MiniMax Platform](https://platform.minimax.io)