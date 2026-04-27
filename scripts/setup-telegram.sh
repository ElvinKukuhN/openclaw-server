#!/bin/bash
# ══════════════════════════════════════════════════════════════════
# setup-telegram.sh — Integrasi Telegram dengan OpenClaw
# ══════════════════════════════════════════════════════════════════
set -e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo ""
echo -e "${CYAN}🤖 Setup Integrasi Telegram${NC}"
echo "════════════════════════════════════"
echo ""

# ── Cek gateway berjalan ──────────────────────────────────────────
if ! docker ps --format '{{.Names}}' | grep -q "openclaw-gateway"; then
  echo -e "${YELLOW}⚠️  Gateway belum berjalan. Jalankan dulu: make start${NC}"
  exit 1
fi

# ── Cek token di .env ─────────────────────────────────────────────
set -a; [ -f .env ] && source .env; set +a

if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ "$TELEGRAM_BOT_TOKEN" != "your-telegram-bot-token" ]; then
  echo "✅ Token ditemukan di .env: ${TELEGRAM_BOT_TOKEN:0:10}..."
  TOKEN="$TELEGRAM_BOT_TOKEN"
else
  echo "Panduan membuat bot Telegram:"
  echo "  1. Buka Telegram → cari @BotFather"
  echo "  2. Ketik /newbot"
  echo "  3. Masukkan nama bot (contoh: MyClaw Bot)"
  echo "  4. Masukkan username bot (contoh: myclaw_bot)"
  echo "  5. Salin token yang diberikan"
  echo ""
  read -rp "Masukkan token bot Telegram: " TOKEN

  if [ -z "$TOKEN" ]; then
    echo "❌ Token tidak boleh kosong!"
    exit 1
  fi
fi

# ── Verifikasi token ke Telegram API ──────────────────────────────
echo ""
echo "🔍 Memverifikasi token..."
BOT_INFO=$(curl -sf "https://api.telegram.org/bot${TOKEN}/getMe" 2>/dev/null)

if echo "$BOT_INFO" | grep -q '"ok":true'; then
  BOT_NAME=$(echo "$BOT_INFO" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
  echo -e "${GREEN}✅ Token valid! Bot: @${BOT_NAME}${NC}"
else
  echo "❌ Token tidak valid! Cek kembali token dari @BotFather."
  exit 1
fi

# ── Daftarkan ke OpenClaw ─────────────────────────────────────────
echo ""
echo "📡 Mendaftarkan Telegram ke OpenClaw..."
docker compose run --rm --profile cli openclaw-cli \
  channels add --channel telegram --token "$TOKEN"

echo ""
echo -e "${GREEN}✅ Channel Telegram berhasil ditambahkan!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 Langkah selanjutnya:"
echo ""
echo "  1. Buka Telegram"
echo "  2. Cari bot @${BOT_NAME}"
echo "  3. Kirim pesan /start"
echo "  4. OpenClaw akan kirim kode pairing"
echo "  5. Jalankan perintah di bawah ini:"
echo ""
echo "     bash scripts/pair-telegram.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Simpan token ke .env jika belum ada
if ! grep -q "TELEGRAM_BOT_TOKEN=" .env 2>/dev/null || grep -q "TELEGRAM_BOT_TOKEN=$" .env 2>/dev/null; then
  sed -i "s/TELEGRAM_BOT_TOKEN=.*/TELEGRAM_BOT_TOKEN=${TOKEN}/" .env
  echo "✅ Token disimpan ke .env"
fi