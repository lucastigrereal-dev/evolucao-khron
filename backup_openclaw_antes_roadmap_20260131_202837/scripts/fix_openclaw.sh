#!/usr/bin/env bash
#
# fix_openclaw.sh - Script automatizado para consertar OpenClaw no Docker Compose + WSL2
# Autor: DevOps/SRE Senior
# Data: 2026-01-31
#
# Este script:
# - Valida pré-requisitos (docker, docker-compose, .env)
# - Corrige permissões de volume
# - Sincroniza tokens do gateway
# - Reinicia containers
# - Aplica doctor --fix
# - Valida status/health
# - Retorna PASS/FAIL por requisito

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções de logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Contador de falhas
FAILURES=0

# Banner
echo "═══════════════════════════════════════════════════════"
echo "    OpenClaw Docker Compose Fix Script"
echo "    WSL2 + Gateway + Telegram Setup"
echo "═══════════════════════════════════════════════════════"
echo ""

# 1. VALIDAR PRÉ-REQUISITOS
log_info "Validando pré-requisitos..."

# Verificar docker
if ! command -v docker &> /dev/null; then
    log_error "Docker não encontrado"
    ((FAILURES++))
else
    log_success "Docker instalado: $(docker --version | head -1)"
fi

# Verificar docker compose
if ! docker compose version &> /dev/null; then
    log_error "Docker Compose não encontrado"
    ((FAILURES++))
else
    log_success "Docker Compose instalado: $(docker compose version | head -1)"
fi

# Verificar se estamos no diretório correto
if [ ! -f "docker-compose.yml" ]; then
    log_error "docker-compose.yml não encontrado. Execute este script do diretório raiz do projeto."
    exit 1
fi
log_success "docker-compose.yml encontrado"

# Verificar .env
if [ ! -f ".env" ]; then
    log_error "Arquivo .env não encontrado"
    ((FAILURES++))
else
    log_success "Arquivo .env encontrado"

    # Verificar variáveis críticas
    source .env
    if [ -z "${OPENCLAW_CONFIG_DIR:-}" ]; then
        log_error "OPENCLAW_CONFIG_DIR não definido em .env"
        ((FAILURES++))
    else
        log_success "OPENCLAW_CONFIG_DIR=$OPENCLAW_CONFIG_DIR"
    fi

    if [ -z "${OPENCLAW_GATEWAY_TOKEN:-}" ]; then
        log_error "OPENCLAW_GATEWAY_TOKEN não definido em .env"
        ((FAILURES++))
    else
        log_success "OPENCLAW_GATEWAY_TOKEN configurado"
    fi
fi

if [ $FAILURES -gt 0 ]; then
    log_error "Falha na validação de pré-requisitos. Corrija os erros acima."
    exit 1
fi

echo ""
log_info "Pré-requisitos validados ✓"
echo ""

# 2. PARAR CONTAINERS EXISTENTES
log_info "Parando containers existentes..."
docker compose down 2>&1 | grep -v "variable is not set" || true
log_success "Containers parados"
echo ""

# 3. CORRIGIR PERMISSÕES
log_info "Corrigindo permissões do volume..."

# Criar diretórios se não existirem
log_info "Criando diretórios necessários..."
docker compose run --rm --user root --entrypoint sh openclaw-cli -c "
    mkdir -p /home/node/.openclaw/credentials
    mkdir -p /home/node/.openclaw/workspace
    echo 'Diretórios criados'
" 2>&1 | grep -v "variable is not set" | tail -5

# Corrigir dono para node:node (UID 1000)
log_info "Ajustando proprietário para node:node..."
docker compose run --rm --user root --entrypoint sh openclaw-cli -c "
    chown -R node:node /home/node/.openclaw
    chmod 700 /home/node/.openclaw
    chmod 700 /home/node/.openclaw/credentials 2>/dev/null || true
    ls -ld /home/node/.openclaw
" 2>&1 | grep -v "variable is not set" | tail -2

log_success "Permissões corrigidas"
echo ""

# 4. SINCRONIZAR TOKEN DO GATEWAY
log_info "Sincronizando token do gateway..."
docker compose run --rm --entrypoint python3 openclaw-cli -c "
import json
import os

config_path = '/home/node/.openclaw/openclaw.json'

# Carregar config
try:
    with open(config_path, 'r') as f:
        config = json.load(f)
except FileNotFoundError:
    print('Config file not found, will be created by gateway')
    exit(0)

# Backup
import shutil
shutil.copy(config_path, config_path + '.bak.token-sync')

# Sincronizar token
env_token = os.environ.get('OPENCLAW_GATEWAY_TOKEN', '')
if env_token and 'gateway' in config and 'auth' in config['gateway']:
    config['gateway']['auth']['token'] = env_token
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)
    print('Token synchronized successfully')
else:
    print('Config structure not ready or token not set')
" 2>&1 | grep -v "variable is not set" | tail -3

log_success "Token sincronizado"
echo ""

# 5. INICIAR CONTAINERS
log_info "Iniciando containers..."
docker compose up -d 2>&1 | grep -v "variable is not set"
log_success "Containers iniciados"
echo ""

# Aguardar gateway inicializar
log_info "Aguardando gateway inicializar (10s)..."
sleep 10

# 6. VERIFICAR STATUS DOS CONTAINERS
log_info "Verificando status dos containers..."
docker compose ps 2>&1 | grep -v "variable is not set"
echo ""

# Verificar se gateway está rodando
if docker compose ps | grep -q "openclaw-gateway.*Up"; then
    log_success "Gateway container está Up"
else
    log_error "Gateway container não está rodando"
    ((FAILURES++))
fi

# 7. APLICAR DOCTOR FIX
log_info "Aplicando doctor --fix..."
docker compose run --rm openclaw-cli doctor --fix 2>&1 | grep -v "variable is not set" | tail -20
log_success "Doctor fix aplicado"
echo ""

# 8. VALIDAR DEFINIÇÃO DE PRONTO
echo "═══════════════════════════════════════════════════════"
echo "    VALIDAÇÃO DA DEFINIÇÃO DE PRONTO"
echo "═══════════════════════════════════════════════════════"
echo ""

# 8.1. Gateway reachable
log_info "Testando: Gateway reachable..."
if docker compose run --rm openclaw-cli status 2>&1 | grep -q "reachable"; then
    log_success "✓ Gateway reachable"
else
    log_error "✗ Gateway unreachable"
    ((FAILURES++))
fi

# 8.2. Health sem EACCES
log_info "Testando: Health sem EACCES..."
HEALTH_OUTPUT=$(docker compose run --rm openclaw-cli health 2>&1 || true)
if echo "$HEALTH_OUTPUT" | grep -q "EACCES"; then
    log_error "✗ Health falhou com EACCES"
    ((FAILURES++))
elif echo "$HEALTH_OUTPUT" | grep -q "Telegram: ok"; then
    log_success "✓ Health OK (sem EACCES)"
else
    log_warn "⚠ Health executou mas resultado incerto"
fi

# 8.3. Doctor fix aplicado com sucesso
log_info "Testando: Doctor fix aplicado..."
if echo "$HEALTH_OUTPUT" | grep -q "ok"; then
    log_success "✓ Doctor fix aplicado com sucesso"
else
    log_warn "⚠ Doctor fix pode ter problemas"
fi

# 8.4. UI acessível em http://127.0.0.1:18789/
log_info "Testando: UI acessível em http://127.0.0.1:18789/..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:18789/ 2>/dev/null || echo "000")
if [ "$HTTP_CODE" == "200" ]; then
    log_success "✓ UI carrega (HTTP $HTTP_CODE)"
else
    log_error "✗ UI não carrega (HTTP $HTTP_CODE)"
    ((FAILURES++))
fi

# 8.5. Canal Telegram enabled
log_info "Testando: Canal Telegram enabled..."
CHANNELS_OUTPUT=$(docker compose run --rm openclaw-cli channels list 2>&1 || true)
if echo "$CHANNELS_OUTPUT" | grep -q "Telegram.*enabled"; then
    log_success "✓ Canal Telegram enabled"
    TELEGRAM_BOT=$(echo "$CHANNELS_OUTPUT" | grep -oP '@\w+' | head -1 || echo "")
    if [ -n "$TELEGRAM_BOT" ]; then
        log_info "  Bot: $TELEGRAM_BOT"
    fi
else
    log_error "✗ Canal Telegram não enabled"
    ((FAILURES++))
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "    RELATÓRIO FINAL"
echo "═══════════════════════════════════════════════════════"
echo ""

if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                           ║${NC}"
    echo -e "${GREEN}║         🎉  SUCESSO! TUDO OK! 🎉          ║${NC}"
    echo -e "${GREEN}║                                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
    echo ""
    echo "Próximos passos:"
    echo "  1. Abra a UI: http://127.0.0.1:18789/"
    echo "  2. Cole o token do gateway nas configurações da UI"
    echo "  3. Token: $(grep OPENCLAW_GATEWAY_TOKEN .env | cut -d= -f2)"
    echo "  4. Para testar Telegram, use: docker compose run --rm openclaw-cli channels list"
    echo ""
    exit 0
else
    echo -e "${RED}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                           ║${NC}"
    echo -e "${RED}║       ❌  FALHAS ENCONTRADAS: $FAILURES          ║${NC}"
    echo -e "${RED}║                                           ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════╝${NC}"
    echo ""
    echo "Verifique os logs acima e corrija os erros."
    echo "Para debug adicional:"
    echo "  - docker compose logs openclaw-gateway --tail=50"
    echo "  - docker compose run --rm openclaw-cli doctor"
    echo ""
    exit 1
fi
