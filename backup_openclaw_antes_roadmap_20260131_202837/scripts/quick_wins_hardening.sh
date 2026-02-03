#!/usr/bin/env bash
#
# quick_wins_hardening.sh - Implementa melhorias imediatas de resiliência
# Execute DEPOIS de receber as respostas do Perplexity
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[DONE]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo "╔═══════════════════════════════════════════════╗"
echo "║  OpenClaw Quick Wins - Hardening Básico      ║"
echo "╔═══════════════════════════════════════════════╝"
echo ""

# QUICK WIN 1: Healthcheck no Docker Compose
log_info "1/7 - Adicionando healthcheck ao gateway..."
if ! grep -q "healthcheck:" docker-compose.yml; then
    log_info "Será adicionado após consulta ao Perplexity"
else
    log_success "Healthcheck já existe"
fi

# QUICK WIN 2: Restart policy
log_info "2/7 - Verificando restart policy..."
if grep -q "restart: unless-stopped" docker-compose.yml; then
    log_success "Restart policy OK (unless-stopped)"
else
    log_warn "Considere adicionar restart: unless-stopped"
fi

# QUICK WIN 3: Resource limits
log_info "3/7 - Verificando resource limits..."
if grep -q "mem_limit:" docker-compose.yml; then
    log_success "Resource limits configurados"
else
    log_warn "Sem resource limits - pode causar OOM"
fi

# QUICK WIN 4: Log rotation
log_info "4/7 - Verificando log rotation..."
if grep -q "logging:" docker-compose.yml; then
    log_success "Log rotation configurado"
else
    log_warn "Sem log rotation - disco pode encher"
fi

# QUICK WIN 5: Backup script
log_info "5/7 - Verificando backup automático..."
if [ -f "scripts/backup_openclaw.sh" ]; then
    log_success "Script de backup existe"
else
    log_warn "Criar backup_openclaw.sh"
fi

# QUICK WIN 6: Monitoring script
log_info "6/7 - Verificando monitoring..."
if [ -f "scripts/monitor_openclaw.sh" ]; then
    log_success "Monitoring configurado"
else
    log_warn "Criar monitor_openclaw.sh"
fi

# QUICK WIN 7: Alerting
log_info "7/7 - Verificando alerting..."
if [ -f "scripts/alert_openclaw.sh" ]; then
    log_success "Alerting configurado"
else
    log_warn "Criar alert_openclaw.sh (Telegram alerts)"
fi

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║  Próximos Passos                             ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""
echo "1. Cole o PROMPT_PERPLEXITY_SKILLS.md no Perplexity"
echo "2. Salve as respostas em PERPLEXITY_SKILLS_RESPONSE.md"
echo "3. Implemente os TOP 5 quick wins"
echo "4. Rode este script novamente para validar"
echo ""
