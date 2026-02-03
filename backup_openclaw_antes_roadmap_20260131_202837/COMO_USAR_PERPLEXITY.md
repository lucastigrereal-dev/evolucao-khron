# 🚀 Como Usar o Prompt do Perplexity - Guia Rápido

## 📋 Passo a Passo

### 1️⃣ Copiar o Prompt
```bash
cat PROMPT_PERPLEXITY_SKILLS.md
```

Ou abra o arquivo `PROMPT_PERPLEXITY_SKILLS.md` e copie TODO o conteúdo.

---

### 2️⃣ Colar no Perplexity

1. Acesse: https://www.perplexity.ai/
2. Cole o prompt COMPLETO
3. Clique em "Search" ou pressione Enter
4. Aguarde a resposta (pode demorar 2-3 minutos)

---

### 3️⃣ Salvar a Resposta

Copie TODA a resposta do Perplexity e cole em:
```
PERPLEXITY_SKILLS_RESPONSE.md
```

---

### 4️⃣ Implementar Quick Wins

Após receber a resposta, implemente os **TOP 5 Quick Wins** que o Perplexity sugerir.

Para validar o que já está feito:
```bash
bash scripts/quick_wins_hardening.sh
```

---

## 🎯 O Que Esperar

O Perplexity vai retornar **30+ skills** organizadas em **10 categorias**:

### 🔥 Categorias Principais

1. **Resiliência & Auto-Healing** (TOP PRIORIDADE)
   - WebSocket reconnection automática
   - Circuit breakers
   - Health checks
   - Graceful shutdown

2. **Networking & Conectividade**
   - Keep-alive heartbeats
   - Retry logic inteligente
   - Docker network optimization

3. **Monitoramento & Observabilidade**
   - Prometheus + Grafana
   - Logs estruturados
   - Alertas via Telegram

4. **Backup & Disaster Recovery**
   - SQLite hot backup
   - Cloud sync
   - Auto-restore

5. **Segurança & Hardening**
   - Rate limiting
   - DDoS protection
   - Token rotation

6. **Performance & Escalabilidade**
   - Load balancing
   - Caching (Redis)
   - Clustering

7. **Skills Específicas OpenClaw**
   - Plugins populares
   - Best practices

8. **DevOps & Automação**
   - CI/CD
   - Blue-green deploy
   - Rollback automático

9. **Telegram-Specific**
   - Rate limit handling
   - Queue management
   - Webhook optimization

10. **Troubleshooting Tools**
    - Debug tools
    - Profiling
    - Network inspection

---

## ⚡ Implementação Imediata

Assim que receber a resposta, foque nos **TOP 5 Quick Wins**:

### Exemplo de Quick Wins Esperados:

1. **PM2 Process Manager** 🔥
   - Auto-restart on crash
   - Cluster mode
   - Zero downtime reload

2. **Docker Healthcheck** 🔥
   - Detect unhealthy containers
   - Auto-restart policy
   - Monitoring integration

3. **Litestream (SQLite Backup)** 🔥
   - Continuous backup to S3/B2
   - Point-in-time recovery
   - Zero config

4. **Winston + Structured Logging** ⚡
   - JSON logs
   - Log levels
   - Rotation automática

5. **Prometheus Node Exporter** ⚡
   - Métricas de sistema
   - Grafana dashboards
   - Alerting

---

## 📊 Formato da Resposta Esperada

Cada skill virá no formato:

```markdown
### 1. PM2 Process Manager

**Categoria:** Resiliência & Auto-Healing
**Problema que Resolve:** Crashes do Node.js, falta de auto-restart
**Popularidade:** 40k+ GitHub stars, 10M downloads/semana
**Status:** Production-ready (usado por 90% dos projetos Node.js em prod)

**Implementação:**
- Repo: https://github.com/Unitech/pm2
- Instalação: `npm install -g pm2`
- Config: `ecosystem.config.cjs` (já existe no projeto!)

**Prós:**
- Auto-restart on crash
- Cluster mode (multi-core)
- Zero downtime reload
- Log management
- Monitoring built-in

**Contras:**
- Overhead leve de memória
- Config inicial pode ser complexa

**Caso de Uso no OpenClaw:**
Substituir o `node dist/index.js` por `pm2 start ecosystem.config.cjs` no Docker.
Ganho imediato de resiliência com zero código extra.

**Prioridade:** 🔥 Crítica
```

---

## 🛠️ Próximos Passos Após Receber Resposta

### Semana 1 - Foundation
```bash
# 1. Implementar TOP 5 Quick Wins
bash scripts/implement_quick_wins.sh

# 2. Validar
bash scripts/quick_wins_hardening.sh

# 3. Testar
docker compose restart openclaw-gateway
docker compose run --rm openclaw-cli status
```

### Semana 2-3 - Observabilidade
- Adicionar Prometheus + Grafana
- Configurar alertas via Telegram
- Implementar backup automático

### Semana 4 - Hardening
- Implementar rate limiting
- Adicionar circuit breakers
- Configurar CI/CD

---

## 📁 Arquivos Criados

```
openclaw-main/
├── PROMPT_PERPLEXITY_SKILLS.md          # ← Cole no Perplexity
├── PERPLEXITY_SKILLS_RESPONSE.md        # ← Salve a resposta aqui
├── COMO_USAR_PERPLEXITY.md              # ← Este arquivo
├── scripts/
│   ├── quick_wins_hardening.sh          # ← Validador
│   └── fix_openclaw.sh                  # ← Fix atual (já funciona)
└── RELATORIO_FIX_OPENCLAW.md            # ← Relatório do fix anterior
```

---

## 🎯 Gargalos Identificados (Para Referência)

Problemas que o Perplexity vai ajudar a resolver:

1. ✅ **RESOLVIDO:** EACCES (permissões)
2. ✅ **RESOLVIDO:** Gateway unreachable
3. ✅ **RESOLVIDO:** Token mismatch
4. ✅ **RESOLVIDO:** Telegram pairing
5. ⚠️ **ATIVO:** Conexão caindo (WebSocket instável)
6. ⚠️ **ATIVO:** Falta auto-healing
7. ⚠️ **RISCO:** Sem backup automático
8. ⚠️ **RISCO:** Sem monitoramento proativo
9. ⚠️ **RISCO:** Sem rate limiting
10. ⚠️ **RISCO:** Sem alertas de falha

---

## 💡 Dicas

1. **Seja específico** ao implementar:
   - Copie os comandos exatos da resposta
   - Teste um skill por vez
   - Valide antes de prosseguir

2. **Documente tudo**:
   - Anote o que funcionou
   - Guarde configs que deram certo
   - Faça backup antes de grandes mudanças

3. **Peça ajuda se necessário**:
   - Cole erros no chat comigo
   - Posso debugar e ajustar

---

## 🚀 Comando Único

Para executar TUDO após receber a resposta:

```bash
# 1. Cole a resposta do Perplexity em PERPLEXITY_SKILLS_RESPONSE.md
# 2. Execute:
bash scripts/quick_wins_hardening.sh
```

---

**OBJETIVO:** OpenClaw à prova de quedas, com auto-healing, backups 24/7 e monitoramento completo! 🛡️
