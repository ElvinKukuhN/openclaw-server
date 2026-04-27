#!/bin/bash
# ══════════════════════════════════════════════════════════════════
# healthcheck.sh — Monitor kesehatan OpenClaw
# Jalankan via cron setiap 5 menit:
#   */5 * * * * cd /path/to/openclaw-server && bash monitoring/healthcheck.sh
# ══════════════════════════════════════════════════════════════════

LOGFILE="logs/healthcheck.log"
set -a; [ -f .env ] && source .env; set +a

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

send_telegram_alert() {
  local MSG="$1"
  if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
    curl -sf -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
      -d "chat_id=${TELEGRAM_CHAT_ID}" \
      -d "text=${MSG}" \
      -d "parse_mode=HTML" > /dev/null 2>&1 || true
  fi
}

# ── Cek Gateway ───────────────────────────────────────────────────
GATEWAY_STATUS=$(docker inspect --format='{{.State.Status}}' openclaw-gateway 2>/dev/null || echo "not_found")
GATEWAY_HEALTH=$(docker exec openclaw-gateway curl -sf http://localhost:18789/health 2>/dev/null && echo "ok" || echo "fail")

if [ "$GATEWAY_STATUS" != "running" ] || [ "$GATEWAY_HEALTH" != "ok" ]; then
  MSG="⚠️ <b>OpenClaw Alert</b>
🕐 $(timestamp)
📛 Gateway: status=$GATEWAY_STATUS, health=$GATEWAY_HEALTH
🔄 Mencoba restart..."

  echo "[$(timestamp)] ALERT: Gateway down — status=$GATEWAY_STATUS, health=$GATEWAY_HEALTH" >> "$LOGFILE"
  send_telegram_alert "$MSG"

  # Auto-restart
  docker compose up -d openclaw-gateway >> "$LOGFILE" 2>&1
  sleep 15

  # Cek lagi setelah restart
  RETRY=$(docker exec openclaw-gateway curl -sf http://localhost:18789/health 2>/dev/null && echo "ok" || echo "fail")
  if [ "$RETRY" = "ok" ]; then
    RECOVER_MSG="✅ <b>OpenClaw Recovered</b>
🕐 $(timestamp)
Gateway berhasil di-restart dan berjalan normal."
    echo "[$(timestamp)] RECOVERED: Gateway kembali normal setelah restart" >> "$LOGFILE"
    send_telegram_alert "$RECOVER_MSG"
  else
    FAIL_MSG="❌ <b>OpenClaw CRITICAL</b>
🕐 $(timestamp)
Gateway gagal restart! Perlu intervensi manual.
SSH ke server dan jalankan: <code>make logs</code>"
    echo "[$(timestamp)] CRITICAL: Gateway gagal restart" >> "$LOGFILE"
    send_telegram_alert "$FAIL_MSG"
  fi
else
  # Semua normal — log setiap jam saja (tidak setiap 5 menit)
  MINUTE=$(date +%M)
  if [ "$MINUTE" = "00" ]; then
    echo "[$(timestamp)] OK: Gateway running & healthy" >> "$LOGFILE"
  fi
fi

# ── Cek Nginx ─────────────────────────────────────────────────────
NGINX_STATUS=$(docker inspect --format='{{.State.Status}}' openclaw-nginx 2>/dev/null || echo "not_found")
if [ "$NGINX_STATUS" != "running" ]; then
  MSG="⚠️ <b>Nginx Alert</b>
🕐 $(timestamp)
Nginx container down, mencoba restart..."
  echo "[$(timestamp)] ALERT: Nginx down" >> "$LOGFILE"
  send_telegram_alert "$MSG"
  docker compose up -d nginx >> "$LOGFILE" 2>&1
fi

# ── Cek disk space ────────────────────────────────────────────────
DISK_PCT=$(df . | awk 'NR==2 {gsub(/%/,""); print $5}')
if [ "$DISK_PCT" -gt 85 ]; then
  MSG="💾 <b>Disk Alert</b>
🕐 $(timestamp)
Disk hampir penuh: ${DISK_PCT}% terpakai!
Jalankan: <code>docker image prune -f</code>"
  echo "[$(timestamp)] ALERT: Disk ${DISK_PCT}% full" >> "$LOGFILE"
  send_telegram_alert "$MSG"
fi

# ── Rotasi log (simpan max 1000 baris) ───────────────────────────
if [ -f "$LOGFILE" ]; then
  LINES=$(wc -l < "$LOGFILE")
  if [ "$LINES" -gt 1000 ]; then
    tail -500 "$LOGFILE" > "${LOGFILE}.tmp" && mv "${LOGFILE}.tmp" "$LOGFILE"
  fi
fi