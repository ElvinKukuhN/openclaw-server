#!/bin/bash
# ══════════════════════════════════════════════════════════════════
# update.sh — Update OpenClaw ke versi terbaru (zero-downtime)
# ══════════════════════════════════════════════════════════════════
set -e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo ""
echo "🔄 Update OpenClaw ke versi terbaru..."
echo ""

# Simpan digest lama
OLD=$(docker inspect ghcr.io/openclaw/openclaw:latest \
  --format='{{index .RepoDigests 0}}' 2>/dev/null || echo "none")
echo "  Versi saat ini : ${OLD:0:60}..."

# Pull image baru
echo "  Pulling image terbaru..."
docker compose pull openclaw-gateway

NEW=$(docker inspect ghcr.io/openclaw/openclaw:latest \
  --format='{{index .RepoDigests 0}}' 2>/dev/null || echo "none")

if [ "$OLD" = "$NEW" ]; then
  echo -e "\n${GREEN}✅ Sudah versi terbaru. Tidak ada perubahan.${NC}"
else
  echo ""
  echo -e "${YELLOW}🆕 Versi baru ditemukan! Menerapkan update...${NC}"
  echo "  Versi baru : ${NEW:0:60}..."

  # Restart gateway dengan image baru
  docker compose up -d --no-deps openclaw-gateway

  # Tunggu sebentar lalu cek health
  echo "  Menunggu gateway ready..."
  sleep 10

  if docker exec openclaw-gateway curl -sf http://localhost:18789/health > /dev/null 2>&1; then
    echo -e "\n${GREEN}✅ Update berhasil! Gateway berjalan normal.${NC}"
  else
    echo ""
    echo "⚠️  Gateway belum merespons, tunggu sebentar..."
    echo "   Cek log: make logs"
  fi
fi

# Bersihkan image lama
echo ""
echo "🧹 Membersihkan image lama..."
docker image prune -f

echo ""
echo "✅ Selesai!"