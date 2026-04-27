#!/bin/bash
# ══════════════════════════════════════════════════════════════════
# server-init.sh — Setup pertama kali di server Ubuntu 22.04/24.04
# Jalankan sebagai root atau user dengan sudo
# ══════════════════════════════════════════════════════════════════
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }
info() { echo -e "${BLUE}[→]${NC} $1"; }

echo ""
echo "🦞 OpenClaw + MiniMax — Server Init (Ubuntu 22.04/24.04)"
echo "══════════════════════════════════════════════════════════"
echo ""

# ── Cek root ─────────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
  err "Jalankan script ini sebagai root: sudo bash scripts/server-init.sh"
fi

# ── Cek .env ─────────────────────────────────────────────────────
if [ ! -f .env ]; then
  warn "File .env belum ada."
  cp .env.example .env
  err "Isi file .env terlebih dahulu:\n  nano .env\nLalu jalankan lagi."
fi

set -a; source .env; set +a

[ -z "$MINIMAX_API_KEY" ] || [ "$MINIMAX_API_KEY" = "sk-your-minimax-api-key-here" ] && \
  err "MINIMAX_API_KEY belum diisi di .env!"
[ -z "$SERVER_DOMAIN" ] || [ "$SERVER_DOMAIN" = "your-server-ip-or-domain" ] && \
  err "SERVER_DOMAIN belum diisi di .env!"
[ -z "$CERTBOT_EMAIL" ] || [ "$CERTBOT_EMAIL" = "your@email.com" ] && \
  err "CERTBOT_EMAIL belum diisi di .env!"

log "Validasi .env selesai"

# ── 1. Update sistem ─────────────────────────────────────────────
info "Update sistem..."
apt-get update -qq
apt-get upgrade -y -qq
apt-get install -y -qq curl git ufw fail2ban
log "Sistem diupdate"

# ── 2. Install Docker ────────────────────────────────────────────
if ! command -v docker &> /dev/null; then
  info "Menginstall Docker..."
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker
  systemctl start docker
  log "Docker terinstall"
else
  log "Docker sudah ada: $(docker --version)"
fi

# ── 3. Konfigurasi Firewall (UFW) ────────────────────────────────
info "Mengkonfigurasi firewall..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh           # port 22
ufw allow 80/tcp        # HTTP (untuk certbot)
ufw allow 443/tcp       # HTTPS
ufw --force enable
log "Firewall aktif — port 22, 80, 443 dibuka"

# ── 4. Konfigurasi Fail2Ban ──────────────────────────────────────
info "Mengkonfigurasi Fail2Ban..."
cat > /etc/fail2ban/jail.local << 'F2B'
[DEFAULT]
bantime  = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port    = ssh
logpath = /var/log/auth.log
F2B
systemctl enable fail2ban
systemctl restart fail2ban
log "Fail2Ban aktif"

# ── 5. Buat direktori ────────────────────────────────────────────
info "Membuat direktori..."
mkdir -p workspace logs/openclaw logs/nginx
chmod 755 workspace logs
log "Direktori dibuat"

# ── 6. Onboarding OpenClaw + MiniMax ────────────────────────────
info "Menjalankan onboarding OpenClaw MiniMax..."
docker compose pull
docker compose run --rm --no-deps \
  --entrypoint node \
  -e MINIMAX_API_KEY="${MINIMAX_API_KEY}" \
  openclaw-gateway \
  dist/index.js onboard --auth-choice minimax-global-api
log "Onboarding selesai"

# ── 7. Start semua service ───────────────────────────────────────
info "Menjalankan semua service..."
docker compose up -d openclaw-gateway watchtower
log "Service berjalan"

# ── 8. Setup systemd service ────────────────────────────────────
info "Membuat systemd service untuk auto-start..."
cat > /etc/systemd/system/openclaw.service << EOF
[Unit]
Description=OpenClaw AI Assistant
Requires=docker.service
After=docker.service network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$(pwd)
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose stop
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable openclaw.service
log "Systemd service aktif (auto-start saat reboot)"

# ── Selesai ───────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║       ✅  Server OpenClaw siap digunakan!            ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Dashboard  : https://${SERVER_DOMAIN}"
echo "📋 Cek status : bash scripts/status.sh"
echo "📊 Lihat log  : make logs"
echo ""
echo "⚠️  Langkah selanjutnya:"
echo "  1. Tambah channel Telegram  : make telegram"
echo "  2. Ambil dashboard URL      : make dashboard"
echo "  3. Cek model MiniMax        : make models"