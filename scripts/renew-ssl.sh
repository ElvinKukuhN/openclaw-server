#!/bin/bash
# ══════════════════════════════════════════════════════════════════
# renew-ssl.sh — Renew SSL certificate Let's Encrypt
# Dijalankan otomatis via cron, atau manual
# ══════════════════════════════════════════════════════════════════
set -e

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Memulai SSL renewal..."

docker compose run --rm --profile ssl certbot renew --quiet

# Reload nginx untuk load cert baru
docker compose exec nginx nginx -s reload

echo "[$(date '+%Y-%m-%d %H:%M:%S')] SSL renewal selesai."