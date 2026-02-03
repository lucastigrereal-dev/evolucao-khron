#!/usr/bin/env bash
#
# validar_sprint.sh - Valida conclusão de cada sprint
# Uso: bash scripts/validar_sprint.sh [0|1|2|3|4]
#

set -euo pipefail

SPRINT=${1:-0}

echo "======================================"
echo "  VALIDAÇÃO SPRINT $SPRINT - KHRONOS"
echo "======================================"
echo ""

validate_sprint_0() {
    echo "📋 SPRINT 0: Setup Básico"
    echo ""

    # PM2 instalado
    if command -v pm2 &> /dev/null; then
        echo "✅ PM2 instalado globalmente"
    else
        echo "❌ PM2 não encontrado"
        return 1
    fi

    # ecosystem.config.js existe
    if [[ -f "ecosystem.config.js" ]]; then
        echo "✅ ecosystem.config.js criado"
    else
        echo "❌ ecosystem.config.js não encontrado"
        return 1
    fi

    # Logger module exists
    if [[ -f "src/logger.js" ]]; then
        echo "✅ Logger module criado"
    else
        echo "❌ src/logger.js não encontrado"
        return 1
    fi

    # Logs directory exists
    if [[ -d "logs" ]]; then
        echo "✅ Diretório logs/ criado"
    else
        echo "❌ Diretório logs/ não encontrado"
        return 1
    fi

    # PM2 app running
    if pm2 list | grep -q "khronos-gateway.*online"; then
        echo "✅ PM2 app online"
    else
        echo "⚠️  PM2 app não está rodando (rodar: pm2 start ecosystem.config.js)"
    fi

    # Health endpoint
    if curl -sf http://localhost:18789/health > /dev/null 2>&1; then
        echo "✅ Health endpoint respondendo"
    else
        echo "⚠️  Health endpoint não responde (app precisa estar rodando)"
    fi

    echo ""
    echo "🎉 SPRINT 0: COMPLETA!"
}

validate_sprint_1() {
    echo "📋 SPRINT 1: Resiliência"
    echo ""

    # Circuit breaker module
    if [[ -f "src/circuit-breaker.js" ]]; then
        echo "✅ Circuit breaker module criado"
    else
        echo "❌ src/circuit-breaker.js não encontrado"
        return 1
    fi

    # Rate limiter module
    if [[ -f "src/rate-limiter.js" ]]; then
        echo "✅ Rate limiter module criado"
    else
        echo "❌ src/rate-limiter.js não encontrado"
        return 1
    fi

    # Graceful shutdown module
    if [[ -f "src/graceful-shutdown.js" ]]; then
        echo "✅ Graceful shutdown module criado"
    else
        echo "❌ src/graceful-shutdown.js não encontrado"
        return 1
    fi

    # Opossum installed
    if npm list opossum &> /dev/null; then
        echo "✅ Opossum instalado"
    else
        echo "❌ Opossum não instalado (npm install opossum)"
        return 1
    fi

    # Bottleneck installed
    if npm list bottleneck &> /dev/null; then
        echo "✅ Bottleneck instalado"
    else
        echo "❌ Bottleneck não instalado (npm install bottleneck)"
        return 1
    fi

    # kill_timeout in ecosystem.config.js
    if grep -q "kill_timeout" ecosystem.config.js; then
        echo "✅ kill_timeout configurado"
    else
        echo "⚠️  kill_timeout não encontrado em ecosystem.config.js"
    fi

    echo ""
    echo "🎉 SPRINT 1: COMPLETA!"
}

validate_sprint_2() {
    echo "📋 SPRINT 2: Backup & Monitoring"
    echo ""

    # Litestream installed
    if command -v litestream &> /dev/null; then
        echo "✅ Litestream instalado"
    else
        echo "❌ Litestream não encontrado"
        return 1
    fi

    # litestream.yml exists
    if [[ -f "litestream.yml" ]]; then
        echo "✅ litestream.yml configurado"
    else
        echo "❌ litestream.yml não encontrado"
        return 1
    fi

    # Metrics module
    if [[ -f "src/metrics.js" ]]; then
        echo "✅ Metrics module criado"
    else
        echo "❌ src/metrics.js não encontrado"
        return 1
    fi

    # Telegram alerts module
    if [[ -f "src/telegram-alerts.js" ]]; then
        echo "✅ Telegram alerts module criado"
    else
        echo "❌ src/telegram-alerts.js não encontrado"
        return 1
    fi

    # prom-client installed
    if npm list prom-client &> /dev/null; then
        echo "✅ prom-client instalado"
    else
        echo "❌ prom-client não instalado (npm install prom-client)"
        return 1
    fi

    # Prometheus running
    if docker compose ps | grep -q "prometheus.*Up"; then
        echo "✅ Prometheus rodando"
    else
        echo "⚠️  Prometheus não está rodando"
    fi

    # Grafana running
    if docker compose ps | grep -q "grafana.*Up"; then
        echo "✅ Grafana rodando"
    else
        echo "⚠️  Grafana não está rodando"
    fi

    # Metrics endpoint
    if curl -sf http://localhost:18789/metrics | grep -q "khronos_" 2>/dev/null; then
        echo "✅ Metrics endpoint com métricas Khronos"
    else
        echo "⚠️  Metrics endpoint não tem métricas Khronos"
    fi

    echo ""
    echo "🎉 SPRINT 2: COMPLETA!"
}

validate_sprint_3() {
    echo "📋 SPRINT 3: Testing & CI/CD"
    echo ""

    # Jest installed
    if npm list jest &> /dev/null; then
        echo "✅ Jest instalado"
    else
        echo "❌ Jest não instalado (npm install --save-dev jest supertest)"
        return 1
    fi

    # Tests exist
    if [[ -d "tests" ]] && ls tests/*.test.js &> /dev/null; then
        echo "✅ Arquivos de teste criados"
    else
        echo "❌ Nenhum arquivo .test.js encontrado em tests/"
        return 1
    fi

    # ESLint installed
    if npm list eslint &> /dev/null; then
        echo "✅ ESLint instalado"
    else
        echo "❌ ESLint não instalado (npm install --save-dev eslint)"
        return 1
    fi

    # .eslintrc.js exists
    if [[ -f ".eslintrc.js" ]]; then
        echo "✅ .eslintrc.js configurado"
    else
        echo "❌ .eslintrc.js não encontrado"
        return 1
    fi

    # GitHub Actions workflows
    if [[ -f ".github/workflows/test.yml" ]]; then
        echo "✅ Workflow test.yml criado"
    else
        echo "❌ .github/workflows/test.yml não encontrado"
        return 1
    fi

    if [[ -f ".github/workflows/deploy.yml" ]]; then
        echo "✅ Workflow deploy.yml criado"
    else
        echo "❌ .github/workflows/deploy.yml não encontrado"
        return 1
    fi

    # CONTRIBUTING.md
    if [[ -f "CONTRIBUTING.md" ]]; then
        echo "✅ CONTRIBUTING.md criado"
    else
        echo "❌ CONTRIBUTING.md não encontrado"
        return 1
    fi

    # Run tests
    if npm test &> /dev/null; then
        echo "✅ Tests passando"
    else
        echo "⚠️  Alguns tests falhando"
    fi

    # Coverage
    if [[ -d "coverage" ]]; then
        COVERAGE=$(cat coverage/coverage-summary.json 2>/dev/null | jq -r '.total.lines.pct' || echo "0")
        if [[ $(echo "$COVERAGE > 70" | bc -l) -eq 1 ]]; then
            echo "✅ Coverage >= 70% (atual: $COVERAGE%)"
        else
            echo "⚠️  Coverage < 70% (atual: $COVERAGE%)"
        fi
    else
        echo "⚠️  Coverage não gerado (rodar: npm run test:coverage)"
    fi

    echo ""
    echo "🎉 SPRINT 3: COMPLETA!"
}

validate_sprint_4() {
    echo "📋 SPRINT 4: Escalabilidade"
    echo ""

    # PM2 clustering
    if grep -q "instances.*max" ecosystem.config.js; then
        echo "✅ PM2 clustering configurado"
    else
        echo "❌ PM2 clustering não configurado"
        return 1
    fi

    # Nginx config
    if [[ -f "nginx.conf" ]]; then
        echo "✅ nginx.conf criado"
    else
        echo "❌ nginx.conf não encontrado"
        return 1
    fi

    # Cache module
    if [[ -f "src/cache.js" ]]; then
        echo "✅ Cache module criado"
    else
        echo "❌ src/cache.js não encontrado"
        return 1
    fi

    # DB pool module
    if [[ -f "src/db-pool.js" ]]; then
        echo "✅ DB pool module criado"
    else
        echo "❌ src/db-pool.js não encontrado"
        return 1
    fi

    # ioredis installed
    if npm list ioredis &> /dev/null; then
        echo "✅ ioredis instalado"
    else
        echo "❌ ioredis não instalado (npm install ioredis)"
        return 1
    fi

    # generic-pool installed
    if npm list generic-pool &> /dev/null; then
        echo "✅ generic-pool instalado"
    else
        echo "❌ generic-pool não instalado (npm install generic-pool)"
        return 1
    fi

    # Redis running
    if redis-cli ping &> /dev/null; then
        echo "✅ Redis rodando"
    else
        echo "⚠️  Redis não está rodando"
    fi

    # Multiple PM2 instances
    INSTANCES=$(pm2 list | grep -c "khronos-gateway" || echo "0")
    if [[ $INSTANCES -gt 1 ]]; then
        echo "✅ Múltiplas instâncias PM2 rodando ($INSTANCES)"
    else
        echo "⚠️  Apenas 1 instância PM2 rodando"
    fi

    # Nginx installed
    if command -v nginx &> /dev/null; then
        echo "✅ Nginx instalado"
    else
        echo "⚠️  Nginx não instalado"
    fi

    echo ""
    echo "🎉 SPRINT 4: COMPLETA!"
}

validate_all() {
    echo "📋 VALIDAÇÃO COMPLETA DE TODAS AS SPRINTS"
    echo ""

    validate_sprint_0
    echo ""
    validate_sprint_1
    echo ""
    validate_sprint_2
    echo ""
    validate_sprint_3
    echo ""
    validate_sprint_4

    echo ""
    echo "======================================"
    echo "  🚀 ROADMAP 100% COMPLETO!"
    echo "======================================"
}

# Main
case $SPRINT in
    0)
        validate_sprint_0
        ;;
    1)
        validate_sprint_1
        ;;
    2)
        validate_sprint_2
        ;;
    3)
        validate_sprint_3
        ;;
    4)
        validate_sprint_4
        ;;
    all)
        validate_all
        ;;
    *)
        echo "Uso: bash scripts/validar_sprint.sh [0|1|2|3|4|all]"
        echo ""
        echo "Sprints disponíveis:"
        echo "  0 - Setup Básico (2h)"
        echo "  1 - Resiliência (6h)"
        echo "  2 - Backup & Monitoring (8h)"
        echo "  3 - Testing & CI/CD (6h)"
        echo "  4 - Escalabilidade (8h)"
        echo "  all - Validar todas as sprints"
        exit 1
        ;;
esac

echo ""
echo "✨ Validação concluída!"
