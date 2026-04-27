.PHONY: help init start stop restart logs status update models shell \
        telegram pair-telegram dashboard ssl-renew monitoring

# ── Default ───────────────────────────────────────────────────────
help:
	@echo ""
	@echo "🦞 OpenClaw Server — Perintah"
	@echo "════════════════════════════════════════════"
	@echo ""
	@echo "  SETUP"
	@echo "  make init          → Setup awal server (jalankan sekali)"
	@echo ""
	@echo "  SERVICE"
	@echo "  make start         → Start semua service"
	@echo "  make stop          → Stop semua service"
	@echo "  make restart       → Restart semua service"
	@echo "  make logs          → Log gateway real-time"
	@echo "  make logs-nginx    → Log nginx real-time"
	@echo ""
	@echo "  MONITORING"
	@echo "  make status        → Cek status semua service"
	@echo "  make monitoring    → Setup cron healthcheck"
	@echo ""
	@echo "  TELEGRAM"
	@echo "  make telegram      → Setup integrasi Telegram"
	@echo "  make pair-telegram → Pair akun Telegram"
	@echo ""
	@echo "  MAINTENANCE"
	@echo "  make update        → Update OpenClaw ke versi terbaru"
	@echo "  make ssl-renew     → Renew SSL certificate manual"
	@echo "  make models        → Cek model MiniMax tersedia"
	@echo "  make shell         → Shell ke dalam container gateway"
	@echo "  make dashboard     → Tampilkan URL dashboard"
	@echo ""

# ── Setup ─────────────────────────────────────────────────────────
init:
	@sudo bash scripts/server-init.sh

# ── Service ───────────────────────────────────────────────────────
start:
	docker compose up -d openclaw-gateway nginx watchtower
	@echo "✅ Semua service berjalan"

stop:
	docker compose stop
	@echo "🛑 Semua service dihentikan"

restart:
	docker compose restart openclaw-gateway nginx
	@echo "🔄 Service di-restart"

logs:
	docker compose logs -f openclaw-gateway

logs-nginx:
	docker compose logs -f nginx

# ── Monitoring ────────────────────────────────────────────────────
status:
	@bash scripts/status.sh

monitoring:
	@echo "Setting up cron healthcheck setiap 5 menit..."
	@(crontab -l 2>/dev/null | grep -v healthcheck; \
	  echo "*/5 * * * * cd $(PWD) && bash monitoring/healthcheck.sh") | crontab -
	@echo "✅ Healthcheck cron aktif"

# ── Telegram ──────────────────────────────────────────────────────
telegram:
	@bash scripts/setup-telegram.sh

pair-telegram:
	@bash scripts/pair-telegram.sh

# ── Maintenance ───────────────────────────────────────────────────
update:
	@bash scripts/update.sh

ssl-renew:
	@bash scripts/renew-ssl.sh

models:
	docker compose run --rm --profile cli openclaw-cli models list --provider minimax

shell:
	docker exec -it openclaw-gateway bash

dashboard:
	docker compose run --rm --profile cli openclaw-cli dashboard --no-open