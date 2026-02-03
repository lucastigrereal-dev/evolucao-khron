#!/usr/bin/env bash
#
# monitor_openclaw.sh - Monitora e reinicia se necessário
# Execute: bash scripts/monitor_openclaw.sh
#

set -euo pipefail

LOG_FILE="/tmp/openclaw_monitor.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Verificar se gateway está respondendo
if ! curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:18789/ | grep -q "200"; then
    log "❌ Gateway não responde - Reiniciando..."
    docker compose restart openclaw-gateway
    sleep 10
    log "✅ Gateway reiniciado"
else
    log "✅ Gateway OK"
fi

# Verificar uso de memória
MEMORY_PERCENT=$(docker stats --no-stream --format "{{.MemPerc}}" openclaw-gateway | sed 's/%//')
if (( $(echo "$MEMORY_PERCENT > 80" | bc -l) )); then
    log "⚠️ Memória alta ($MEMORY_PERCENT%) - Reiniciando..."
    docker compose restart openclaw-gateway
    sleep 10
    log "✅ Gateway reiniciado por alto uso de memória"
fi

# Verificar Telegram
if docker compose run --rm openclaw-cli health 2>&1 | grep -q "Telegram: ok"; then
    log "✅ Telegram OK"
else
    log "❌ Telegram com problema"
fi
