#!/bin/bash
# ══════════════════════════════════════════════════════════════════
# pair-telegram.sh — Pair akun Telegram dengan OpenClaw
# ══════════════════════════════════════════════════════════════════
set -e

echo ""
echo "🔗 Pairing Akun Telegram"
echo "════════════════════════"
echo ""
echo "Cek pesan dari bot di Telegram kamu, lalu masukkan kode pairing:"
read -rp "Kode pairing: " CODE

if [ -z "$CODE" ]; then
  echo "❌ Kode tidak boleh kosong!"
  exit 1
fi

docker compose run --rm --profile cli openclaw-cli \
  pairing approve telegram "$CODE"

echo ""
echo "✅ Pairing berhasil! Kamu sekarang bisa chat langsung dengan OpenClaw via Telegram."