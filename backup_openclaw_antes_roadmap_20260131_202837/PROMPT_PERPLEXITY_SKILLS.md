# Prompt para Perplexity - OpenClaw Production-Grade Skills

## Contexto do Sistema

Estou rodando **OpenClaw** (multi-channel AI bot framework) em produção via Docker Compose no WSL2, com os seguintes componentes:

**Stack Técnica:**
- OpenClaw Gateway (Node.js 22, WebSocket server)
- Docker Compose (multi-container)
- WSL2 Ubuntu
- Canais: Telegram, WhatsApp Web (planejado)
- Modelos IA: Claude Sonnet 3.7 (Anthropic API)
- Persistência: SQLite + file-based state
- Rede: Bridge network, porta 18789 (gateway)

**Problemas Recorrentes Identificados:**
1. ✅ RESOLVIDO: EACCES (permissões de volume)
2. ✅ RESOLVIDO: Gateway unreachable (network mode)
3. ✅ RESOLVIDO: Token mismatch (sincronização)
4. ⚠️ **ATIVO:** Conexão caindo frequentemente (WebSocket instável)
5. ⚠️ **ATIVO:** Falta de auto-recuperação (manual restart necessário)
6. ⚠️ **RISCO:** Sem backup automático do estado
7. ⚠️ **RISCO:** Sem monitoramento proativo
8. ⚠️ **RISCO:** Sem rate limiting/proteção DDoS
9. ⚠️ **RISCO:** Sem alertas de falha

---

## Prompt para Perplexity

**Busque e liste 30+ skills/plugins/extensões/hacks VALIDADOS E TESTADOS (com código/repos) para fortalecer um OpenClaw bot framework em produção, focando em:**

### 🛡️ CATEGORIA 1: Resiliência & Auto-Healing (Prioridade MÁXIMA)
Procure por skills/práticas que:
- Detectam quedas de WebSocket e reconectam automaticamente (exponential backoff)
- Implementam circuit breakers para APIs externas (Anthropic, Telegram)
- Fazem health checks periódicos e auto-restart em caso de falha
- Implementam graceful shutdown e state persistence
- Lidam com memory leaks (Node.js heap monitoring)
- Previnem crashes por unhandled rejections/exceptions

**Palavras-chave:** `websocket reconnection`, `nodejs circuit breaker`, `auto-healing nodejs`, `graceful shutdown docker`, `process manager pm2 docker`

---

### 🔄 CATEGORIA 2: Networking & Conectividade Estável
Procure por skills/configs que:
- Estabilizam conexões WebSocket em ambientes containerizados
- Implementam keep-alive heartbeats para evitar timeouts
- Lidam com network partitioning e split-brain
- Otimizam Docker networking (bridge vs host vs overlay)
- Implementam retry logic com jitter para APIs
- Previnem ECONNREFUSED/ETIMEDOUT em WSL2

**Palavras-chave:** `websocket heartbeat nodejs`, `docker network stability`, `wsl2 networking issues`, `nodejs connection pooling`, `tcp keepalive docker`

---

### 📊 CATEGORIA 3: Monitoramento & Observabilidade
Procure por skills/ferramentas que:
- Monitoram métricas de gateway (req/s, latency, errors)
- Exportam logs estruturados (JSON) para análise
- Implementam distributed tracing (OpenTelemetry)
- Alertam via Telegram/email quando serviços caem
- Rastreiam memory/CPU usage em tempo real
- Detectam anomalias (spike de erros, slowdown)

**Palavras-chave:** `prometheus nodejs exporter`, `grafana docker compose`, `winston structured logging`, `opentelemetry nodejs`, `healthcheck docker compose`, `nodejs metrics prom-client`

---

### 💾 CATEGORIA 4: Backup & Disaster Recovery
Procure por skills/estratégias que:
- Fazem backup automático de SQLite databases (hot backup)
- Sincronizam state para cloud storage (S3, Backblaze B2)
- Implementam point-in-time recovery
- Versionam configurações (git-backed config)
- Replicam dados críticos em tempo real
- Testam backups automaticamente (restore tests)

**Palavras-chave:** `sqlite backup nodejs`, `docker volume backup`, `litestream sqlite replication`, `config versioning`, `disaster recovery nodejs`

---

### 🔐 CATEGORIA 5: Segurança & Hardening
Procure por skills/práticas que:
- Implementam rate limiting por IP/user (Redis-backed)
- Protegem contra DDoS em WebSocket
- Validam tokens com rotação automática
- Implementam least privilege (non-root containers)
- Escanam vulnerabilidades em dependencies (Snyk, npm audit)
- Isolam secrets (Vault, encrypted env vars)

**Palavras-chave:** `express rate limit redis`, `websocket ddos protection`, `docker security hardening`, `nodejs secrets management`, `token rotation nodejs`

---

### ⚡ CATEGORIA 6: Performance & Escalabilidade
Procure por skills/otimizações que:
- Implementam horizontal scaling (multi-instance)
- Usam load balancing para WebSocket (sticky sessions)
- Otimizam Node.js event loop (clustering, worker threads)
- Implementam caching inteligente (Redis, in-memory)
- Comprimem payloads (gzip, brotli)
- Otimizam SQLite queries (indexes, WAL mode)

**Palavras-chave:** `nodejs cluster mode`, `websocket load balancing`, `redis caching nodejs`, `sqlite performance tuning`, `nginx websocket proxy`

---

### 🤖 CATEGORIA 7: Skills Específicas do OpenClaw
Procure por:
- Plugins populares do ecossistema OpenClaw/similar frameworks
- Skills de integração com Telegram Bot API (polling vs webhooks)
- Skills de gerenciamento de sessões de chat
- Skills de queue management para mensagens (Bull, BullMQ)
- Skills de NLP/context management (RAG, embeddings)
- Skills de multi-channel orchestration

**Palavras-chave:** `telegraf.js plugins`, `whatsapp-web.js best practices`, `chatbot queue management`, `conversational AI nodejs`, `multi-channel bot framework`

---

### 🔧 CATEGORIA 8: DevOps & Automação
Procure por skills/ferramentas que:
- Automatizam deploy via CI/CD (GitHub Actions, GitLab CI)
- Implementam blue-green deployment para zero downtime
- Fazem smoke tests pós-deploy
- Gerenciam secrets de forma segura (SOPS, Sealed Secrets)
- Automatizam rollback em caso de falha
- Implementam feature flags (LaunchDarkly, Unleash)

**Palavras-chave:** `docker compose ci/cd`, `blue green deployment docker`, `automated rollback`, `smoke tests nodejs`, `feature flags nodejs`

---

### 📱 CATEGORIA 9: Telegram-Specific Hardening
Procure por skills/práticas que:
- Lidam com Telegram rate limits (flood wait)
- Implementam message queue para evitar spam
- Otimizam polling vs webhooks (quando usar cada um)
- Lidam com Telegram API downtime
- Implementam retry exponencial para sendMessage
- Gerenciam sessões de longa duração

**Palavras-chave:** `telegram bot rate limit handling`, `telegram flood wait`, `telegram webhook vs polling`, `telegraf.js queue`, `telegram api reliability`

---

### 🧰 CATEGORIA 10: Troubleshooting & Debug Tools
Procure por skills/ferramentas que:
- Facilitam debug de WebSocket connections (wscat, websocat)
- Permitem inspecionar Docker network (dive, ctop)
- Monitoram file descriptors e connections (lsof, netstat)
- Fazem profiling de Node.js apps (clinic.js, 0x)
- Capturam dumps de memória para análise (heapdump)
- Implementam remote debugging seguro

**Palavras-chave:** `nodejs debugging production`, `websocket debugging tools`, `docker network troubleshooting`, `nodejs profiling`, `heapdump analysis`

---

## Formato de Resposta Esperado

Para cada skill/ferramenta, forneça:

```markdown
### [Número]. [Nome da Skill/Ferramenta]

**Categoria:** [Uma das 10 categorias acima]
**Problema que Resolve:** [Descrição clara]
**Popularidade:** [GitHub stars / npm downloads / adoção]
**Status:** [Produção-ready / Beta / Experimental]

**Implementação:**
- Repo/Package: [Link do GitHub/NPM]
- Instalação: `[comando]`
- Config mínima: [Exemplo de código/config]

**Prós:**
- [Lista de benefícios]

**Contras:**
- [Lista de limitações]

**Caso de Uso no OpenClaw:**
[Como aplicar especificamente no meu setup]

**Prioridade:** [🔥 Crítica / ⚡ Alta / 📌 Média / 💡 Baixa]
```

---

## Critérios de Seleção

✅ **Deve ter:**
- GitHub repo ativo (commits recentes)
- Documentação clara
- Exemplos de código
- Uso em produção comprovado (cases, testimonials)
- Compatível com Node.js 22+ e Docker

❌ **Evitar:**
- Ferramentas abandonadas (sem commits há 2+ anos)
- Experimental/alpha sem produção real
- Dependências pesadas sem benefício claro
- Vendor lock-in excessivo

---

## Priorização

Ordene as 30+ skills por:
1. 🔥 **Críticas** (resolvem quedas de conexão / auto-healing) - TOP 10
2. ⚡ **Altas** (monitoramento / backup / segurança) - 10-15
3. 📌 **Médias** (performance / escalabilidade) - 5-8
4. 💡 **Baixas** (nice-to-have / otimizações futuras) - resto

---

## Contexto Adicional para Busca

- **Framework similar:** Botpress, Rasa, Botkit, Microsoft Bot Framework
- **Tech stack similar:** Node.js microservices, WebSocket servers, multi-tenant chat platforms
- **Empresas de referência:** Intercom (chat), Crisp (messaging), Chatwoot (open-source)
- **Arquiteturas de referência:** Event-driven architecture, CQRS for chat, Saga pattern for long-running conversations

---

## Entregáveis Esperados

1. **Lista de 30+ skills** (formato acima)
2. **Roadmap de implementação** (ordem de prioridade)
3. **Compatibilidade matrix** (quais skills funcionam juntas)
4. **Estimativa de esforço** (low/medium/high para cada skill)
5. **Quick wins** (top 5 que posso implementar hoje)

---

## Perguntas para Guiar a Busca

- Quais são os TOP 10 plugins do npm para resiliência de WebSocket em 2026?
- Quais ferramentas de monitoramento são mais usadas em produção para Node.js microservices?
- Como grandes bots de Telegram (100k+ users) lidam com rate limits e quedas?
- Quais são as best practices de Docker Compose para high availability?
- Quais tools de backup são recomendados para SQLite em produção?
- Como implementar zero-downtime deploys em Docker Compose?
- Quais são as vulnerabilidades comuns em WebSocket servers e como prevenir?
- Quais bibliotecas de circuit breaker são mais confiáveis para Node.js?
- Como implementar distributed tracing em um bot framework?
- Quais são os benchmarks de performance para Node.js WebSocket servers?

---

**OBJETIVO FINAL:** Zero downtime, auto-recuperação, monitoramento 24/7, backups automáticos, segurança hardened - um OpenClaw production-grade que NÃO CAI. 🛡️🚀
