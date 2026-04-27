#!/bin/bash
# ══════════════════════════════════════════════════════════════════
# status.sh — Cek status semua service OpenClaw
# ══════════════════════════════════════════════════════════════════

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
ok()   { echo -e "  ${GREEN}● RUNNING${NC}   $1"; }
fail() { echo -e "  ${RED}● DOWN${NC}      $1"; }
warn() { echo -e "  ${YELLOW}● DEGRADED${NC}  $1"; }

set -a; [ -f .env ] && source .env; set +a

echo ""
echo -e "${CYAN}🦞 OpenClaw Server Status${NC}"
echo "══════════════════════════════════════════════"
echo "  Waktu: $(date '+%Y-%m-%d %H:%M:%S')"
echo "  Server: ${SERVER_DOMAIN:-$(hostname)}"
echo "══════════════════════════════════════════════"
echo ""

# ── Container Status ─────────────────────────────────────────────
echo "📦 Containers:"
for svc in openclaw-gateway openclaw-nginx openclaw-watchtower; do
  STATUS=$(docker inspect --format='{{.State.Status}}' $svc 2>/dev/null)
  HEALTH=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}N/A{{end}}' $svc 2>/dev/null)

  if [ "$STATUS" = "running" ]; then
    if [ "$HEALTH" = "healthy" ] || [ "$HEALTH" = "N/A" ]; then
      ok "$svc ($HEALTH)"
    else
      warn "$svc (health: $HEALTH)"
    fi
  else
    fail "$svc (status: ${STATUS:-tidak ditemukan})"
  fi
done

echo ""

# ── HTTP Health Check ─────────────────────────────────────────────
echo "🌐 Endpoint:"
# HTTP redirect
HTTP=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://localhost/ 2>/dev/null)
if [ "$HTTP" = "301" ] || [ "$HTTP" = "302" ]; then
  ok "HTTP  → redirect ke HTTPS (${HTTP})"
else
  fail "HTTP  → tidak merespons (${HTTP})"
fi

# HTTPS dashboard
HTTPS=$(curl -sk -o /dev/null -w "%{http_code}" --connect-timeout 5 https://localhost/ 2>/dev/null)
if [ "$HTTPS" = "200" ] || [ "$HTTPS" = "302" ]; then
  ok "HTTPS → dashboard merespons (${HTTPS})"
else
  warn "HTTPS → status ${HTTPS}"
fi

# Gateway health langsung
GW=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://localhost:18789/health 2>/dev/null || echo "0")
# Gateway harusnya tidak accessible dari luar (internal only)
# Kita cek dari dalam container
GW_INTERNAL=$(docker exec openclaw-gateway curl -sf http://localhost:18789/health 2>/dev/null && echo "ok" || echo "fail")
if [ "$GW_INTERNAL" = "ok" ]; then
  ok "Gateway health (internal)"
else
  fail "Gateway health (internal)"
fi

echo ""

# ── SSL Certificate ───────────────────────────────────────────────
echo "🔒 SSL Certificate:"
if [ -n "$SERVER_DOMAIN" ]; then
  CERT_EXPIRY=$(echo | openssl s_client -servername "$SERVER_DOMAIN" -connect "$SERVER_DOMAIN:443" 2>/dev/null | \
    openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
  if [ -n "$CERT_EXPIRY" ]; then
    DAYS_LEFT=$(( ( $(date -d "$CERT_EXPIRY" +%s) - $(date +%s) ) / 86400 ))
    if [ "$DAYS_LEFT" -gt 14 ]; then
      ok "Berlaku hingga: $CERT_EXPIRY ($DAYS_LEFT hari lagi)"
    else
      warn "Akan kadaluarsa: $CERT_EXPIRY ($DAYS_LEFT hari lagi) — segera renew!"
    fi
  else
    warn "Tidak bisa cek SSL (domain belum resolve atau cert belum ada)"
  fi
fi

echo ""

# ── Resource Usage ───────────────────────────────────────────────
echo "💻 Resource:"
docker stats --no-stream --format \
  "  {{.Name}}\t CPU: {{.CPUPerc}}\t RAM: {{.MemUsage}}" \
  openclaw-gateway openclaw-nginx 2>/dev/null || true

echo ""

# ── Disk Usage ───────────────────────────────────────────────────
echo "💾 Disk:"
DISK_USED=$(df -h . | awk 'NR==2 {print $3}')
DISK_TOTAL=$(df -h . | awk 'NR==2 {print $2}')
DISK_PCT=$(df -h . | awk 'NR==2 {print $5}')
echo "  Terpakai: $DISK_USED / $DISK_TOTAL ($DISK_PCT)"

echo ""

# ── Log Errors (24 jam terakhir) ─────────────────────────────────
echo "⚠️  Error log 24 jam terakhir:"
ERR_COUNT=$(docker logs --since 24h openclaw-gateway 2>&1 | grep -ci "error\|exception\|fatal" || true)
if [ "$ERR_COUNT" -eq 0 ]; then
  echo -e "  ${GREEN}Tidak ada error${NC}"
else
  echo -e "  ${YELLOW}Ditemukan $ERR_COUNT baris error — cek: make logs${NC}"
fi

echo ""
echo "══════════════════════════════════════════════"
echo "  make logs       → lihat log real-time"
echo "  make restart    → restart semua service"
echo "══════════════════════════════════════════════"
echo ""