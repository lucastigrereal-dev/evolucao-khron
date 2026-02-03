#!/bin/bash
set -e

# ============================================================
# 🦞 OPENCLAW INSTALLER - JARVIS CONFIG
# Stack: Sonnet + Haiku + GPT Embeddings + Ollama Fallback
# RAM: 8GB | Canal: Telegram
# ============================================================

echo "========================================"
echo "🦞 OPENCLAW INSTALLER - INICIANDO"
echo "========================================"

# --- VARIÁVEIS ---
OPENCLAW_DIR="/mnt/c/Users/lucas/Desktop/openclaw-main"
CONFIG_DIR="$HOME/.openclaw"
WORKSPACE_DIR="$CONFIG_DIR/workspace"

# --- CHAVES API ---
ANTHROPIC_KEY="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"
OPENAI_KEY="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"
TELEGRAM_TOKEN="CONFIGURE_DEPOIS_VIA_CLI"

# Gera token do gateway
GATEWAY_TOKEN=$(openssl rand -hex 32)

echo "📁 Criando estrutura de diretórios..."
mkdir -p "$CONFIG_DIR"
mkdir -p "$WORKSPACE_DIR"
mkdir -p "$WORKSPACE_DIR/memory"

# ============================================================
# ARQUIVO 1: .env (na pasta do projeto)
# ============================================================
echo "📝 Criando .env..."
cat > "$OPENCLAW_DIR/.env" << EOF
# === OPENCLAW ENV CONFIG ===
# Gerado em: $(date)

# Anthropic (Sonnet + Haiku)
ANTHROPIC_API_KEY=$ANTHROPIC_KEY

# OpenAI (Embeddings)
OPENAI_API_KEY=$OPENAI_KEY

# Telegram (configure depois via CLI)
TELEGRAM_BOT_TOKEN=$TELEGRAM_TOKEN

# Gateway
OPENCLAW_GATEWAY_TOKEN=$GATEWAY_TOKEN

# Timezone
TZ=America/Sao_Paulo

# Node
NODE_ENV=production
EOF

# ============================================================
# ARQUIVO 2: openclaw.json (config principal)
# ============================================================
echo "📝 Criando openclaw.json..."
cat > "$CONFIG_DIR/openclaw.json" << 'EOF'
{
  "model": "anthropic/claude-sonnet-4-5-20250929",
  "heartbeat": {
    "model": "anthropic/claude-haiku-4-5-20251001",
    "every": "30m",
    "activeHours": "08:00-22:00",
    "target": "last"
  },
  "memory": {
    "provider": "openai",
    "model": "text-embedding-3-small",
    "vectorWeight": 0.7,
    "textWeight": 0.3
  },
  "fallback": {
    "provider": "ollama",
    "model": "llama3.2:1b",
    "baseUrl": "http://localhost:11434"
  },
  "channels": {
    "telegram": {
      "enabled": true
    },
    "dmPolicy": "pairing"
  },
  "gateway": {
    "bind": "lan",
    "port": 18789,
    "auth": "token"
  },
  "agents": {
    "defaults": {
      "sandbox": {
        "mode": "non-main",
        "scope": "session",
        "workspaceAccess": "ro",
        "network": "none"
      }
    }
  },
  "tools": {
    "exec": {
      "backgroundMs": 10000,
      "timeoutSec": 300
    },
    "elevated": {
      "disabled": true
    }
  },
  "browser": {
    "enabled": true,
    "headless": true
  }
}
EOF

# ============================================================
# ARQUIVO 3: SOUL.md (persona do agente)
# ============================================================
echo "📝 Criando SOUL.md..."
cat > "$WORKSPACE_DIR/SOUL.md" << 'EOF'
# JARVIS - Assistente Pessoal

## Identidade
Você é JARVIS, assistente pessoal do Lucas (Diretor Comercial do Instituto Rodovanski).

## Hierarquia de Modelos
- **Haiku 4.5**: Heartbeats, verificações rápidas, tarefas simples
- **Sonnet 4.5**: Automações, análises, tarefas complexas
- **Ollama llama3.2:1b**: Fallback offline (quando APIs indisponíveis)

## Regras de Segurança
### PROIBIDO (nunca fazer)
- Expor credenciais ou tokens
- Executar comandos destrutivos (rm -rf, drop, delete em massa)
- Modificar arquivos de sistema
- Acessar dados sensíveis sem autorização

### REQUER CONFIRMAÇÃO
- Deletar arquivos do usuário
- Modificar configurações importantes
- Enviar mensagens em nome do usuário
- Fazer compras ou transações

### PERMITIDO
- Ler/escrever no workspace
- Buscar na web
- Executar scripts aprovados
- Organizar tarefas e projetos

## Tom de Comunicação
- Profissional mas amigável
- Direto ao ponto
- Português brasileiro
- Foco em monetização e eficiência
EOF

# ============================================================
# ARQUIVO 4: HEARTBEAT.md (checklist de saúde)
# ============================================================
echo "📝 Criando HEARTBEAT.md..."
cat > "$WORKSPACE_DIR/HEARTBEAT.md" << 'EOF'
# Checklist de Heartbeat

## Crítico (falha = alerta imediato)
- [ ] Gateway respondendo na porta 18789
- [ ] Telegram conectado (se configurado)
- [ ] Sem erros FATAL nos logs

## Importante (verificar diariamente)
- [ ] Backup executado nas últimas 24h
- [ ] Disco com >20% livre
- [ ] Memória <80% uso

## Formato de Resposta
Se tudo OK: "HEARTBEAT_OK: [timestamp]"
Se problema: Detalhar o que está errado e ação sugerida
EOF

# ============================================================
# ARQUIVO 5: USER.md (contexto do usuário)
# ============================================================
echo "📝 Criando USER.md..."
cat > "$WORKSPACE_DIR/USER.md" << 'EOF'
# Perfil do Usuário

## Dados
- **Nome**: Lucas
- **Cargo**: Diretor Comercial e Sócio
- **Empresa**: Instituto Rodovanski
- **Timezone**: America/Sao_Paulo
- **Horário ativo**: 08:00 - 22:00

## Contexto
- Não é desenvolvedor (usa IAs para código)
- Foco em monetização, marketing e vendas
- Usa: Notion, n8n, automações, integrações
- Projetos: Instagram, softwares, apps enterprise

## Preferências
- Respostas diretas e objetivas
- Sempre mostrar alternativas
- Priorizar economia de recursos
- Validar antes de executar
EOF

# ============================================================
# ARQUIVO 6: MEMORY.md (memória persistente)
# ============================================================
echo "📝 Criando MEMORY.md..."
cat > "$WORKSPACE_DIR/memory/MEMORY.md" << 'EOF'
# Memória do Agente

## Decisões Importantes
- [2025-01-31] Instalação via Docker escolhida
- [2025-01-31] Stack: Sonnet + Haiku + GPT embeddings + Ollama fallback
- [2025-01-31] Canal inicial: Telegram

## Projetos Ativos
- OpenClaw/Moltbot JARVIS setup

## Notas
(Adicionar conforme conversas acontecem)
EOF

# ============================================================
# VERIFICAÇÕES
# ============================================================
echo ""
echo "✅ Verificando arquivos criados..."
echo ""

echo "📁 Config dir: $CONFIG_DIR"
ls -la "$CONFIG_DIR"
echo ""

echo "📁 Workspace dir: $WORKSPACE_DIR"
ls -la "$WORKSPACE_DIR"
echo ""

echo "📁 Projeto dir: $OPENCLAW_DIR"
ls -la "$OPENCLAW_DIR/.env" 2>/dev/null && echo "✅ .env criado" || echo "❌ .env não encontrado"

# ============================================================
# PRÓXIMOS PASSOS
# ============================================================
echo ""
echo "========================================"
echo "✅ CONFIGURAÇÃO COMPLETA!"
echo "========================================"
echo ""
echo "🔐 Seu token do Gateway (SALVE ISSO):"
echo "   $GATEWAY_TOKEN"
echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo ""
echo "1) Entre no diretório do projeto:"
echo "   cd $OPENCLAW_DIR"
echo ""
echo "2) Execute o setup do Docker:"
echo "   chmod +x docker-setup.sh"
echo "   ./docker-setup.sh"
echo ""
echo "3) Durante o onboarding, escolha:"
echo "   - Gateway bind: lan"
echo "   - Gateway auth: token"
echo "   - Gateway token: (cole o token acima)"
echo "   - Tailscale: Off"
echo "   - Install daemon: No"
echo ""
echo "4) Depois de subir, acesse:"
echo "   http://127.0.0.1:18789/?token=$GATEWAY_TOKEN"
echo ""
echo "5) Para configurar Telegram depois:"
echo "   docker compose run --rm openclaw-cli channels add --channel telegram --token \"SEU_BOT_TOKEN\""
echo ""
echo "========================================"
echo "🦞 BOA SORTE! O JARVIS ESTÁ QUASE VIVO!"
echo "========================================"
