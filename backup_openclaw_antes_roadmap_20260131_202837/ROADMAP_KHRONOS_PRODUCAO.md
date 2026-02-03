# 🚀 ROADMAP KHRONOS PRODUÇÃO

> **Objetivo:** Transformar o Khronos em sistema production-grade com 99.9%+ uptime
> **Duração Total:** 30 horas (5 sprints)
> **Status Atual:** ✅ Sistema funcionando (Telegram OK, UI OK, Gateway OK)

---

## 📊 VISÃO GERAL

```
┌─────────────────────────────────────────────────────────────────┐
│ ESTADO ATUAL → ESTADO DESEJADO                                  │
├─────────────────────────────────────────────────────────────────┤
│ ❌ Cai frequentemente    → ✅ 99.9% uptime                       │
│ ❌ Sem monitoramento     → ✅ Prometheus + Grafana               │
│ ❌ Sem backup automático → ✅ Backup contínuo (Litestream)       │
│ ❌ Sem testes            → ✅ 70%+ coverage + CI/CD              │
│ ❌ Single process        → ✅ Clustering (multi-core)            │
│ ❌ Sem cache             → ✅ Cache 3 camadas (memória+Redis)    │
│ ❌ Sem alertas           → ✅ Telegram alerts críticos           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎯 7 CAUSAS DE QUEDA IDENTIFICADAS → SOLUÇÕES

| # | Causa | Solução | Sprint |
|---|-------|---------|--------|
| 1 | Auto-reload config (doctor --fix) | Graceful shutdown handlers | Sprint 1 |
| 2 | WebSocket timeout (WSL2) | Health monitoring + auto-restart | Sprint 0 |
| 3 | Memory leaks (Node.js) | PM2 max_memory_restart + monitoramento | Sprint 2 |
| 4 | Telegram rate limits | Rate limiting (Bottleneck.js) | Sprint 1 |
| 5 | Docker restart abrupto | Graceful shutdown + SIGTERM handlers | Sprint 1 |
| 6 | WSL2 suspend/hibernate | Monitoring script + auto-recovery | Sprint 0 |
| 7 | Anthropic API timeout | Circuit breakers (Opossum) | Sprint 1 |

---

## 📅 TIMELINE DE IMPLEMENTAÇÃO

```
Semana 1: Sprint 0 (2h) + Sprint 1 (6h) = 8h
  ├─ Dia 1-2: Setup básico (PM2, logs, health)
  └─ Dia 3-5: Resiliência (circuit breakers, rate limit)

Semana 2: Sprint 2 (8h) = 8h
  ├─ Dia 1-2: Backup automático (Litestream)
  ├─ Dia 3-4: Prometheus + Grafana
  └─ Dia 5: Winston logging + alertas Telegram

Semana 3: Sprint 3 (6h) + Sprint 4 (8h) = 14h
  ├─ Dia 1-2: Testes Jest + CI/CD
  ├─ Dia 3-4: Clustering + Load balancing
  └─ Dia 5: Cache Redis + Connection pooling
```

---

## 🏃 SPRINT 0: SETUP BÁSICO (2H)

### Objetivo
Preparar infraestrutura base: PM2, health checks, logs estruturados

### Tarefas

#### TASK 0.1: Instalar PM2 (30min)
```bash
cd /mnt/c/Users/lucas/Desktop/openclaw-main
npm install -g pm2
npm install --save pm2 winston ioredis dotenv
```

**Validação:**
```bash
pm2 --version  # Deve mostrar versão
node -p "require('pm2')"  # Não deve dar erro
```

---

#### TASK 0.2: Criar ecosystem.config.js (30min)

**Arquivo:** `ecosystem.config.js`

```javascript
module.exports = {
  apps: [{
    name: 'khronos-gateway',
    script: 'dist/index.js',
    args: 'gateway --bind lan --port 18789',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '500M',
    env: {
      NODE_ENV: 'production',
      HOME: '/home/node'
    },
    error_file: 'logs/pm2-error.log',
    out_file: 'logs/pm2-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    kill_timeout: 5000
  }]
};
```

**Validação:**
```bash
pm2 start ecosystem.config.js
pm2 list  # Deve mostrar khronos-gateway online
pm2 logs khronos-gateway --lines 20  # Ver logs
```

---

#### TASK 0.3: Criar módulo logger (30min)

**Arquivo:** `src/logger.js`

```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
      maxsize: 10485760, // 10MB
      maxFiles: 5
    }),
    new winston.transports.File({
      filename: 'logs/combined.log',
      maxsize: 10485760,
      maxFiles: 5
    })
  ]
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple()
    )
  }));
}

module.exports = logger;
```

**Validação:**
```javascript
const logger = require('./src/logger');
logger.info('Test log');
logger.error('Test error', { meta: 'data' });
```

---

#### TASK 0.4: Health Endpoints (30min)

**Arquivo:** `src/health.js`

```javascript
const logger = require('./logger');
const redis = require('./redis');

async function healthCheck(req, res) {
  const memUsage = process.memoryUsage();

  res.status(200).json({
    status: 'UP',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: {
      heapUsed: Math.round(memUsage.heapUsed / 1024 / 1024) + 'MB',
      heapTotal: Math.round(memUsage.heapTotal / 1024 / 1024) + 'MB',
      rss: Math.round(memUsage.rss / 1024 / 1024) + 'MB'
    },
    pid: process.pid
  });

  logger.info('Health check called', { endpoint: '/health' });
}

async function readinessCheck(req, res) {
  const checks = {};
  let ready = true;

  // Check Redis
  try {
    await redis.ping();
    checks.redis = { status: 'OK' };
  } catch (error) {
    checks.redis = { status: 'FAIL', error: error.message };
    ready = false;
  }

  // Check memory
  const memUsage = process.memoryUsage();
  const heapPercent = (memUsage.heapUsed / memUsage.heapTotal) * 100;
  checks.memory = {
    status: heapPercent > 90 ? 'WARNING' : 'OK',
    heapUsedPercent: Math.round(heapPercent)
  };

  res.status(ready ? 200 : 503).json({
    ready,
    checks,
    timestamp: new Date().toISOString()
  });
}

module.exports = { healthCheck, readinessCheck };
```

**Integração:** Adicionar rotas no `src/index.js` (ou onde o Express está configurado)

**Validação:**
```bash
curl http://localhost:18789/health
curl http://localhost:18789/ready
```

---

### ✅ CHECKLIST SPRINT 0

- [ ] PM2 instalado globalmente e via npm
- [ ] ecosystem.config.js criado e testado
- [ ] Winston logger configurado
- [ ] Redis módulo criado
- [ ] Health endpoints /health e /ready funcionando
- [ ] Logs sendo escritos em logs/combined.log
- [ ] PM2 mostrando app online

**Critério de Sucesso:**
```bash
pm2 list  # khronos-gateway: online, uptime > 1min
curl -s http://localhost:18789/health | jq .status  # "UP"
curl -s http://localhost:18789/ready | jq .ready  # true
ls logs/  # combined.log e error.log existem
```

---

## 🛡️ SPRINT 1: RESILIÊNCIA (6H)

### Objetivo
Implementar circuit breakers, rate limiting, graceful shutdown

### Tarefas

#### TASK 1.1: Circuit Breakers (2h)

**Instalar:**
```bash
npm install opossum
```

**Arquivo:** `src/circuit-breaker.js`

```javascript
const CircuitBreaker = require('opossum');
const logger = require('./logger');

function createBreaker(name, fn, options = {}) {
  const defaultOptions = {
    timeout: 10000,
    errorThresholdPercentage: 50,
    resetTimeout: 30000,
    rollingCountTimeout: 10000,
    rollingCountBuckets: 10,
    name
  };

  const breaker = new CircuitBreaker(fn, { ...defaultOptions, ...options });

  // Logging
  breaker.on('open', () => {
    logger.error(`Circuit breaker OPEN: ${name}`);
  });

  breaker.on('halfOpen', () => {
    logger.warn(`Circuit breaker HALF-OPEN: ${name}`);
  });

  breaker.on('close', () => {
    logger.info(`Circuit breaker CLOSED: ${name}`);
  });

  breaker.on('success', () => {
    logger.debug(`Circuit breaker success: ${name}`);
  });

  breaker.on('failure', (error) => {
    logger.error(`Circuit breaker failure: ${name}`, { error: error.message });
  });

  breaker.on('fallback', (result) => {
    logger.warn(`Circuit breaker fallback: ${name}`, { result });
  });

  return breaker;
}

// Circuit breaker para Anthropic API
const anthropicBreaker = createBreaker(
  'anthropic-api',
  async (prompt, options) => {
    // Sua função de chamada Anthropic aqui
    const response = await callAnthropicAPI(prompt, options);
    return response;
  },
  {
    timeout: 30000, // 30s timeout
    errorThresholdPercentage: 50,
    resetTimeout: 60000, // 1min cooldown
    fallback: () => ({
      error: true,
      message: 'Anthropic API indisponível. Tente novamente.'
    })
  }
);

// Circuit breaker para Telegram
const telegramBreaker = createBreaker(
  'telegram-api',
  async (method, params) => {
    // Sua função de chamada Telegram aqui
    const response = await callTelegramAPI(method, params);
    return response;
  },
  {
    timeout: 5000,
    errorThresholdPercentage: 60,
    resetTimeout: 30000,
    fallback: (method, params) => {
      logger.warn('Telegram API fallback', { method, params });
      return { ok: false, error: 'Telegram temporariamente indisponível' };
    }
  }
);

// Circuit breaker para Database
const dbBreaker = createBreaker(
  'database',
  async (query, params) => {
    // Sua função de query ao DB aqui
    const result = await executeQuery(query, params);
    return result;
  },
  {
    timeout: 3000,
    errorThresholdPercentage: 70,
    resetTimeout: 10000,
    fallback: () => {
      logger.error('Database circuit breaker triggered');
      throw new Error('Database indisponível');
    }
  }
);

module.exports = {
  createBreaker,
  anthropicBreaker,
  telegramBreaker,
  dbBreaker
};
```

**Uso:**
```javascript
const { anthropicBreaker } = require('./circuit-breaker');

// Em vez de:
// const result = await callAnthropicAPI(prompt);

// Usar:
try {
  const result = await anthropicBreaker.fire(prompt, options);
} catch (error) {
  logger.error('Anthropic call failed', { error });
  // Handle fallback
}
```

**Validação:**
```javascript
// Testar circuit breaker manualmente
const breaker = createBreaker('test', async () => {
  throw new Error('Simulated failure');
});

// Disparar várias vezes para abrir o circuito
for (let i = 0; i < 10; i++) {
  try {
    await breaker.fire();
  } catch (e) {
    console.log(`Attempt ${i}: ${breaker.getState()}`);
  }
}
```

---

#### TASK 1.2: Rate Limiting (2h)

**Instalar:**
```bash
npm install bottleneck
```

**Arquivo:** `src/rate-limiter.js`

```javascript
const Bottleneck = require('bottleneck');
const logger = require('./logger');

// Telegram rate limiter (30 msgs/sec global, 1 msg/sec por chat)
const telegramLimiter = new Bottleneck({
  reservoir: 30,
  reservoirRefreshAmount: 30,
  reservoirRefreshInterval: 1000, // 1 second
  maxConcurrent: 5,
  minTime: 35, // 35ms between requests
  id: 'telegram-limiter'
});

telegramLimiter.on('failed', async (error, jobInfo) => {
  const id = jobInfo.options.id;
  logger.warn(`Rate limit hit for ${id}`, { error: error.message });

  // Retry after 429 (Too Many Requests)
  if (error.statusCode === 429) {
    const retryAfter = error.parameters?.retry_after || 60;
    logger.info(`Retrying after ${retryAfter}s`);
    return retryAfter * 1000; // Return ms to wait before retry
  }
});

telegramLimiter.on('retry', (error, jobInfo) => {
  logger.info(`Retrying job ${jobInfo.options.id}`);
});

// Anthropic rate limiter (50 req/min)
const anthropicLimiter = new Bottleneck({
  reservoir: 50,
  reservoirRefreshAmount: 50,
  reservoirRefreshInterval: 60 * 1000, // 1 minute
  maxConcurrent: 3,
  minTime: 1200, // 1.2s between requests
  id: 'anthropic-limiter'
});

// Generic rate limiter
function createRateLimiter(options) {
  const limiter = new Bottleneck(options);

  limiter.on('error', (error) => {
    logger.error(`Rate limiter error: ${options.id}`, { error });
  });

  limiter.on('depleted', (empty) => {
    logger.warn(`Rate limiter depleted: ${options.id}`, { empty });
  });

  return limiter;
}

module.exports = {
  telegramLimiter,
  anthropicLimiter,
  createRateLimiter
};
```

**Uso:**
```javascript
const { telegramLimiter } = require('./rate-limiter');

// Enviar mensagem do Telegram com rate limiting
async function sendTelegramMessage(chatId, text) {
  return telegramLimiter.schedule({ id: `chat-${chatId}` }, async () => {
    // Sua lógica de envio aqui
    const result = await telegram.sendMessage(chatId, text);
    return result;
  });
}
```

**Validação:**
```javascript
// Testar rate limiter
const { telegramLimiter } = require('./rate-limiter');

const promises = [];
for (let i = 0; i < 100; i++) {
  promises.push(
    telegramLimiter.schedule({ id: `test-${i}` }, async () => {
      console.log(`Request ${i} at ${new Date().toISOString()}`);
      return i;
    })
  );
}

await Promise.all(promises);
// Deve espaçar as requisições conforme os limites
```

---

#### TASK 1.3: Graceful Shutdown (2h)

**Arquivo:** `src/graceful-shutdown.js`

```javascript
const logger = require('./logger');

let isShuttingDown = false;
const connections = new Set();

function registerConnection(conn) {
  connections.add(conn);
  conn.on('close', () => {
    connections.delete(conn);
  });
}

async function gracefulShutdown(signal) {
  if (isShuttingDown) {
    logger.warn('Shutdown already in progress');
    return;
  }

  isShuttingDown = true;
  logger.info(`Received ${signal}, starting graceful shutdown...`);

  // 1. Stop accepting new connections
  if (global.httpServer) {
    global.httpServer.close(() => {
      logger.info('HTTP server closed');
    });
  }

  // 2. Close existing connections
  logger.info(`Closing ${connections.size} active connections`);
  for (const conn of connections) {
    try {
      conn.end();
    } catch (error) {
      logger.error('Error closing connection', { error });
    }
  }

  // 3. Close database connections
  if (global.db) {
    try {
      await global.db.close();
      logger.info('Database closed');
    } catch (error) {
      logger.error('Error closing database', { error });
    }
  }

  // 4. Close Redis connection
  if (global.redis) {
    try {
      await global.redis.quit();
      logger.info('Redis closed');
    } catch (error) {
      logger.error('Error closing Redis', { error });
    }
  }

  // 5. Flush logs
  await new Promise(resolve => {
    logger.on('finish', resolve);
    logger.end();
  });

  logger.info('Graceful shutdown complete');
  process.exit(0);
}

// Register signal handlers
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
process.on('SIGUSR2', () => gracefulShutdown('SIGUSR2')); // PM2 reload

// Handle uncaught errors
process.on('uncaughtException', (error) => {
  logger.error('Uncaught exception', { error, stack: error.stack });
  gracefulShutdown('uncaughtException');
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled rejection', { reason, promise });
  gracefulShutdown('unhandledRejection');
});

module.exports = {
  registerConnection,
  gracefulShutdown
};
```

**Integração:** No `src/index.js` ou arquivo principal:

```javascript
const { registerConnection } = require('./graceful-shutdown');

// Quando criar o servidor HTTP
const server = app.listen(port, () => {
  logger.info(`Server listening on port ${port}`);
});

global.httpServer = server;

// Registrar conexões
server.on('connection', (conn) => {
  registerConnection(conn);
});
```

**Atualizar ecosystem.config.js:**
```javascript
module.exports = {
  apps: [{
    name: 'khronos-gateway',
    script: 'dist/index.js',
    // ...
    kill_timeout: 10000, // 10s para shutdown gracioso
    wait_ready: true,
    listen_timeout: 3000
  }]
};
```

**Validação:**
```bash
pm2 start ecosystem.config.js
pm2 logs khronos-gateway --lines 20

# Em outro terminal, enviar SIGTERM
pm2 stop khronos-gateway

# Verificar logs - deve mostrar:
# "Received SIGTERM, starting graceful shutdown..."
# "HTTP server closed"
# "Database closed"
# "Redis closed"
# "Graceful shutdown complete"
```

---

### ✅ CHECKLIST SPRINT 1

- [ ] Circuit breakers criados (Anthropic, Telegram, Database)
- [ ] Rate limiters configurados (Telegram 30/s, Anthropic 50/min)
- [ ] Graceful shutdown handlers registrados
- [ ] ecosystem.config.js atualizado com kill_timeout
- [ ] Testes manuais de circuit breaker funcionando
- [ ] Testes manuais de rate limiting funcionando
- [ ] pm2 stop mostra shutdown gracioso nos logs

**Critério de Sucesso:**
```bash
# Circuit breaker abre após falhas consecutivas
# Rate limiter respeita limites configurados
# pm2 reload não causa perda de requisições em andamento
grep "Graceful shutdown complete" logs/combined.log  # Deve existir
```

---

## 💾 SPRINT 2: BACKUP & MONITORING (8H)

### Objetivo
Backup automático, métricas Prometheus, logs estruturados, alertas Telegram

### Tarefas

#### TASK 2.1: Litestream Backup (2h)

**Instalar Litestream:**
```bash
# No WSL2
wget https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-amd64.tar.gz
tar -xzf litestream-v0.3.13-linux-amd64.tar.gz
sudo mv litestream /usr/local/bin/
litestream version
```

**Criar litestream.yml:**
```yaml
dbs:
  - path: /home/lucas/.openclaw/khronos.db
    replicas:
      - type: s3
        bucket: khronos-backups
        path: db
        region: us-east-1
        access-key-id: ${AWS_ACCESS_KEY_ID}
        secret-access-key: ${AWS_SECRET_ACCESS_KEY}
        retention: 168h  # 7 days
        sync-interval: 10s
        snapshot-interval: 1h
        validation-interval: 6h
```

**Ou usar Backblaze B2 (mais barato):**
```yaml
dbs:
  - path: /home/lucas/.openclaw/khronos.db
    replicas:
      - type: s3
        bucket: khronos-backups
        path: db
        endpoint: s3.us-west-000.backblazeb2.com
        region: us-west-000
        access-key-id: ${B2_KEY_ID}
        secret-access-key: ${B2_APPLICATION_KEY}
        retention: 168h
        sync-interval: 10s
```

**Adicionar ao .env:**
```bash
# AWS S3 (ou Backblaze B2)
AWS_ACCESS_KEY_ID=your_key_id
AWS_SECRET_ACCESS_KEY=your_secret_key
```

**Iniciar Litestream como serviço:**

Criar `scripts/start-litestream.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

litestream replicate -config litestream.yml
```

**Adicionar ao PM2:**
```javascript
module.exports = {
  apps: [
    {
      name: 'khronos-gateway',
      // ... configuração existente
    },
    {
      name: 'litestream',
      script: 'scripts/start-litestream.sh',
      autorestart: true,
      watch: false
    }
  ]
};
```

**Validação:**
```bash
pm2 start ecosystem.config.js --only litestream
pm2 logs litestream --lines 20

# Verificar que está replicando
litestream databases -config litestream.yml

# Testar restore
litestream restore -config litestream.yml -o /tmp/khronos-restore.db /home/lucas/.openclaw/khronos.db
sqlite3 /tmp/khronos-restore.db "SELECT COUNT(*) FROM users;"
```

---

#### TASK 2.2: Prometheus Metrics (3h)

**Instalar:**
```bash
npm install prom-client
```

**Arquivo:** `src/metrics.js`

```javascript
const client = require('prom-client');
const logger = require('./logger');

// Register
const register = new client.Registry();

// Default metrics (CPU, memory, event loop lag)
client.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDuration = new client.Histogram({
  name: 'khronos_http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5, 10]
});

const httpRequestTotal = new client.Counter({
  name: 'khronos_http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

const telegramMessagesReceived = new client.Counter({
  name: 'khronos_telegram_messages_received_total',
  help: 'Total Telegram messages received',
  labelNames: ['chat_type']
});

const telegramMessagesSent = new client.Counter({
  name: 'khronos_telegram_messages_sent_total',
  help: 'Total Telegram messages sent',
  labelNames: ['status']
});

const anthropicApiCalls = new client.Counter({
  name: 'khronos_anthropic_api_calls_total',
  help: 'Total Anthropic API calls',
  labelNames: ['model', 'status']
});

const anthropicApiDuration = new client.Histogram({
  name: 'khronos_anthropic_api_duration_seconds',
  help: 'Duration of Anthropic API calls',
  labelNames: ['model'],
  buckets: [1, 5, 10, 30, 60, 120]
});

const anthropicTokensUsed = new client.Counter({
  name: 'khronos_anthropic_tokens_used_total',
  help: 'Total tokens used by Anthropic API',
  labelNames: ['model', 'type']
});

const circuitBreakerState = new client.Gauge({
  name: 'khronos_circuit_breaker_state',
  help: 'Circuit breaker state (0=closed, 1=open, 2=half-open)',
  labelNames: ['name']
});

const activeConnections = new client.Gauge({
  name: 'khronos_active_connections',
  help: 'Number of active connections'
});

const databaseQueryDuration = new client.Histogram({
  name: 'khronos_database_query_duration_seconds',
  help: 'Duration of database queries',
  labelNames: ['operation'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 5]
});

// Register all metrics
register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestTotal);
register.registerMetric(telegramMessagesReceived);
register.registerMetric(telegramMessagesSent);
register.registerMetric(anthropicApiCalls);
register.registerMetric(anthropicApiDuration);
register.registerMetric(anthropicTokensUsed);
register.registerMetric(circuitBreakerState);
register.registerMetric(activeConnections);
register.registerMetric(databaseQueryDuration);

// Middleware para HTTP requests
function metricsMiddleware(req, res, next) {
  const start = Date.now();

  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route?.path || req.path || 'unknown';

    httpRequestDuration.observe(
      { method: req.method, route, status_code: res.statusCode },
      duration
    );

    httpRequestTotal.inc({
      method: req.method,
      route,
      status_code: res.statusCode
    });
  });

  next();
}

// Export metrics endpoint
async function metricsEndpoint(req, res) {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (error) {
    logger.error('Error generating metrics', { error });
    res.status(500).end(error.message);
  }
}

module.exports = {
  register,
  metrics: {
    httpRequestDuration,
    httpRequestTotal,
    telegramMessagesReceived,
    telegramMessagesSent,
    anthropicApiCalls,
    anthropicApiDuration,
    anthropicTokensUsed,
    circuitBreakerState,
    activeConnections,
    databaseQueryDuration
  },
  metricsMiddleware,
  metricsEndpoint
};
```

**Integração no src/index.js:**
```javascript
const { metricsMiddleware, metricsEndpoint } = require('./metrics');

// Adicionar middleware
app.use(metricsMiddleware);

// Adicionar endpoint
app.get('/metrics', metricsEndpoint);
```

**Uso nos circuit breakers:**
```javascript
const { metrics } = require('./metrics');

breaker.on('open', () => {
  metrics.circuitBreakerState.set({ name }, 1);
});

breaker.on('close', () => {
  metrics.circuitBreakerState.set({ name }, 0);
});

breaker.on('halfOpen', () => {
  metrics.circuitBreakerState.set({ name }, 2);
});
```

**Instalar Prometheus (Docker):**
```yaml
# docker-compose.yml - adicionar serviço
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'
    networks:
      - openclaw-network
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    volumes:
      - grafana_data:/var/lib/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    networks:
      - openclaw-network
    restart: unless-stopped
    depends_on:
      - prometheus

volumes:
  prometheus_data:
  grafana_data:
```

**Criar prometheus.yml:**
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'khronos'
    static_configs:
      - targets: ['openclaw-gateway:18789']
    metrics_path: '/metrics'
    scrape_interval: 10s
```

**Validação:**
```bash
docker compose up -d prometheus grafana
curl http://localhost:18789/metrics  # Ver métricas
curl http://localhost:9090  # Prometheus UI
curl http://localhost:3000  # Grafana (admin/admin)
```

---

#### TASK 2.3: Winston Advanced Logging (2h)

**Arquivo:** `src/logger.js` (atualizar)

```javascript
const winston = require('winston');
const { v4: uuidv4 } = require('uuid');

// Correlation ID middleware
function correlationMiddleware(req, res, next) {
  req.correlationId = uuidv4();
  res.setHeader('X-Correlation-ID', req.correlationId);
  next();
}

// Custom format with correlation ID
const correlationFormat = winston.format((info, opts) => {
  if (opts.correlationId) {
    info.correlationId = opts.correlationId;
  }
  return info;
});

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    correlationFormat(),
    winston.format.json()
  ),
  defaultMeta: {
    service: 'khronos',
    environment: process.env.NODE_ENV || 'development',
    version: require('../package.json').version
  },
  transports: [
    // Error log
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
      maxsize: 10485760, // 10MB
      maxFiles: 10,
      tailable: true
    }),

    // Combined log
    new winston.transports.File({
      filename: 'logs/combined.log',
      maxsize: 10485760,
      maxFiles: 10,
      tailable: true
    }),

    // Separate log for important events
    new winston.transports.File({
      filename: 'logs/audit.log',
      level: 'warn',
      maxsize: 52428800, // 50MB
      maxFiles: 20
    })
  ]
});

// Console transport for development
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.printf(({ timestamp, level, message, correlationId, ...meta }) => {
        let msg = `${timestamp} [${level}]: ${message}`;
        if (correlationId) {
          msg += ` [${correlationId}]`;
        }
        if (Object.keys(meta).length > 0) {
          msg += ` ${JSON.stringify(meta)}`;
        }
        return msg;
      })
    )
  }));
}

// Helper to create child logger with correlation ID
function createChildLogger(correlationId) {
  return logger.child({ correlationId });
}

module.exports = logger;
module.exports.correlationMiddleware = correlationMiddleware;
module.exports.createChildLogger = createChildLogger;
```

**Uso:**
```javascript
const { correlationMiddleware, createChildLogger } = require('./logger');

// No Express
app.use(correlationMiddleware);

// Em controllers
app.get('/api/chat', (req, res) => {
  const logger = createChildLogger(req.correlationId);
  logger.info('Chat request received', { userId: req.user.id });

  // Todos os logs terão o mesmo correlationId
  logger.debug('Processing chat message');
  logger.error('Error processing chat', { error: 'details' });
});
```

**Validação:**
```bash
# Gerar alguns logs
curl http://localhost:18789/health
curl http://localhost:18789/api/chat

# Ver logs estruturados
cat logs/combined.log | jq .
cat logs/combined.log | jq 'select(.correlationId != null)'
```

---

#### TASK 2.4: Telegram Alerts (1h)

**Arquivo:** `src/telegram-alerts.js`

```javascript
const logger = require('./logger');
const { telegramLimiter } = require('./rate-limiter');

const ALERT_CHAT_ID = process.env.TELEGRAM_ALERT_CHAT_ID;
const BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN;

async function sendTelegramAlert(level, message, metadata = {}) {
  if (!ALERT_CHAT_ID || !BOT_TOKEN) {
    logger.warn('Telegram alerts not configured');
    return;
  }

  const emoji = {
    error: '🔴',
    warning: '⚠️',
    info: 'ℹ️',
    success: '✅'
  }[level] || '📢';

  const text = `${emoji} *${level.toUpperCase()}*\n\n${message}\n\n\`\`\`json\n${JSON.stringify(metadata, null, 2)}\n\`\`\``;

  try {
    await telegramLimiter.schedule({ id: 'alert' }, async () => {
      const response = await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          chat_id: ALERT_CHAT_ID,
          text,
          parse_mode: 'Markdown'
        })
      });

      if (!response.ok) {
        throw new Error(`Telegram API error: ${response.statusText}`);
      }
    });

    logger.info('Telegram alert sent', { level, message });
  } catch (error) {
    logger.error('Failed to send Telegram alert', { error: error.message, level, message });
  }
}

// Hooks para eventos críticos
function setupAlertHooks() {
  // Circuit breaker aberto
  process.on('circuitBreakerOpen', (name) => {
    sendTelegramAlert('error', `Circuit breaker OPEN: ${name}`, {
      timestamp: new Date().toISOString(),
      breaker: name
    });
  });

  // Erro não tratado
  process.on('uncaughtException', (error) => {
    sendTelegramAlert('error', 'Uncaught Exception', {
      error: error.message,
      stack: error.stack
    });
  });

  // Memory warning
  setInterval(() => {
    const usage = process.memoryUsage();
    const heapPercent = (usage.heapUsed / usage.heapTotal) * 100;

    if (heapPercent > 90) {
      sendTelegramAlert('warning', 'High memory usage', {
        heapUsedPercent: Math.round(heapPercent),
        heapUsedMB: Math.round(usage.heapUsed / 1024 / 1024),
        rss: Math.round(usage.rss / 1024 / 1024)
      });
    }
  }, 60000); // Check every minute
}

module.exports = {
  sendTelegramAlert,
  setupAlertHooks
};
```

**Adicionar ao .env:**
```bash
TELEGRAM_ALERT_CHAT_ID=your_chat_id  # Seu ID do Telegram
```

**Integração no src/index.js:**
```javascript
const { setupAlertHooks } = require('./telegram-alerts');

// No startup
setupAlertHooks();
```

**Validação:**
```bash
# Testar alerta manualmente
node -e "
const { sendTelegramAlert } = require('./src/telegram-alerts');
sendTelegramAlert('info', 'Teste de alerta', { foo: 'bar' });
"

# Deve receber mensagem no Telegram
```

---

### ✅ CHECKLIST SPRINT 2

- [ ] Litestream instalado e replicando para S3/B2
- [ ] PM2 rodando litestream como serviço
- [ ] Prometheus coletando métricas do /metrics endpoint
- [ ] Grafana dashboard criado
- [ ] Winston logging com correlation IDs
- [ ] Telegram alerts configurado e testado
- [ ] Restore de backup testado com sucesso

**Critério de Sucesso:**
```bash
pm2 list  # litestream: online
litestream databases  # Mostra última replicação
curl http://localhost:18789/metrics | grep khronos_  # Métricas existem
curl http://localhost:9090  # Prometheus acessível
curl http://localhost:3000  # Grafana acessível
cat logs/combined.log | jq 'select(.correlationId != null)' | head -1  # Logs com correlationId
# Recebeu alerta de teste no Telegram
```

---

## 🧪 SPRINT 3: TESTING & CI/CD (6H)

### Objetivo
Criar testes Jest, GitHub Actions CI/CD, ESLint, coverage >= 70%

### Tarefas

#### TASK 3.1: Jest Testing Setup (2h)

**Instalar:**
```bash
npm install --save-dev jest supertest
```

**Criar tests/health.test.js:**
```javascript
const request = require('supertest');
const app = require('../src/index');

describe('Health Endpoints', () => {
  describe('GET /health', () => {
    it('should return status UP', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.body.status).toBe('UP');
      expect(response.body.uptime).toBeGreaterThan(0);
    });

    it('should have memory stats', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.body.memory).toBeDefined();
      expect(response.body.memory.heapUsed).toBeDefined();
    });
  });

  describe('GET /ready', () => {
    it('should check Redis', async () => {
      const response = await request(app)
        .get('/ready')
        .expect(200);

      expect(response.body.checks.redis).toBeDefined();
    });
  });

  describe('GET /metrics', () => {
    it('should return Prometheus metrics', async () => {
      const response = await request(app)
        .get('/metrics')
        .expect(200);

      expect(response.text).toContain('khronos_');
      expect(response.type).toBe('text/plain');
    });
  });
});
```

**Criar tests/circuit-breaker.test.js:**
```javascript
const { createBreaker } = require('../src/circuit-breaker');

describe('Circuit Breaker', () => {
  it('should execute successfully', async () => {
    const breaker = createBreaker('test', async () => {
      return { success: true };
    });

    const result = await breaker.fire();
    expect(result.success).toBe(true);
    expect(breaker.getState()).toBe('closed');
  });

  it('should open after threshold', async () => {
    const breaker = createBreaker(
      'test-fail',
      async () => {
        throw new Error('API down');
      },
      {
        timeout: 100,
        errorThresholdPercentage: 50,
        resetTimeout: 1000,
        fallback: () => ({ fallback: true })
      }
    );

    // Trigger failures
    for (let i = 0; i < 5; i++) {
      try {
        await breaker.fire();
      } catch (e) {
        // Expected
      }
    }

    await new Promise(r => setTimeout(r, 200));
    expect(breaker.getState()).toBe('open');

    // Fallback should be used
    const result = await breaker.fire();
    expect(result.fallback).toBe(true);
  });
});
```

**Criar tests/rate-limiter.test.js:**
```javascript
const { createRateLimiter } = require('../src/rate-limiter');

describe('Rate Limiter', () => {
  it('should queue requests', async () => {
    const limiter = createRateLimiter({
      maxConcurrent: 1,
      minTime: 50
    });

    const times = [];
    const promises = Array(3).fill(null).map((_, i) =>
      limiter.schedule(async () => {
        times.push(Date.now());
        return i;
      })
    );

    await Promise.all(promises);

    // Verify timing
    for (let i = 1; i < times.length; i++) {
      const gap = times[i] - times[i - 1];
      expect(gap).toBeGreaterThanOrEqual(45); // minTime with margin
    }
  });
});
```

**Atualizar package.json:**
```json
{
  "scripts": {
    "test": "jest --coverage",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage --coverageThreshold='{\"global\":{\"branches\":70,\"functions\":70,\"lines\":70,\"statements\":70}}'"
  },
  "jest": {
    "testEnvironment": "node",
    "coverageDirectory": "coverage",
    "collectCoverageFrom": [
      "src/**/*.js",
      "!src/index.js"
    ],
    "testTimeout": 10000
  }
}
```

**Validação:**
```bash
npm test
npm run test:coverage

# Deve passar todos os testes e coverage >= 70%
```

---

#### TASK 3.2: GitHub Actions CI/CD (2h)

**Criar .github/workflows/test.yml:**
```yaml
name: Tests & Quality

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
    - uses: actions/checkout@v3

    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Run linter
      run: npm run lint --if-present

    - name: Run tests
      run: npm test
      env:
        REDIS_HOST: localhost
        REDIS_PORT: 6379

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: ./coverage/lcov.info
        flags: unittests

  build:
    runs-on: ubuntu-latest
    needs: [test]

    steps:
    - uses: actions/checkout@v3

    - name: Docker build test
      run: docker build -t khronos:test .
```

**Criar .github/workflows/deploy.yml:**
```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
    - uses: actions/checkout@v3

    - name: Deploy via SSH
      uses: appleboy/ssh-action@master
      with:
        host: ${{ secrets.DEPLOY_HOST }}
        username: ${{ secrets.DEPLOY_USER }}
        key: ${{ secrets.DEPLOY_KEY }}
        script: |
          cd ~/khronos
          git pull origin main
          npm install
          npm test
          pm2 reload ecosystem.config.js
```

**Validação:**
```bash
# Commit e push para testar CI
git add .
git commit -m "feat: add CI/CD workflows"
git push origin develop

# Verificar no GitHub Actions que os testes passaram
```

---

#### TASK 3.3: Code Quality (2h)

**Instalar:**
```bash
npm install --save-dev eslint
```

**Criar .eslintrc.js:**
```javascript
module.exports = {
  env: {
    node: true,
    es2021: true,
    jest: true
  },
  extends: 'eslint:recommended',
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module'
  },
  rules: {
    'no-console': 'warn',
    'no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
    'prefer-const': 'error',
    'eqeqeq': ['error', 'always'],
    'quotes': ['error', 'single'],
    'semi': ['error', 'always']
  }
};
```

**Adicionar ao package.json:**
```json
{
  "scripts": {
    "lint": "eslint src tests",
    "lint:fix": "eslint src tests --fix"
  }
}
```

**Criar CONTRIBUTING.md:**
```markdown
# Contribuindo para Khronos

## Setup Local

```bash
git clone <repo>
cd khronos
npm install
cp .env.example .env
# Editar .env com suas credenciais
npm test
pm2 start ecosystem.config.js
```

## Testing

```bash
npm test              # Rodar testes
npm run test:watch   # Watch mode
npm run test:coverage # Coverage
```

## Code Standards

- ESLint: `.eslintrc.js`
- Coverage mínimo: 70%
- Sem console.log (usar logger)
- Async/await preferred

## Commit Messages

```
type(scope): description

[optional body]
```

Types: feat, fix, docs, style, refactor, perf, test, chore

## PR Process

1. Fork repository
2. Create feature branch: `git checkout -b feat/my-feature`
3. Commit: `git commit -am 'feat: add feature'`
4. Push: `git push origin feat/my-feature`
5. Create Pull Request
6. Wait for CI/CD
7. Request review
```

**Validação:**
```bash
npm run lint
npm run lint:fix

# Deve passar sem erros
```

---

### ✅ CHECKLIST SPRINT 3

- [ ] Jest tests criados (health, circuit-breaker, rate-limiter)
- [ ] Coverage >= 70%
- [ ] GitHub Actions workflows criados (.github/workflows/test.yml, deploy.yml)
- [ ] ESLint configurado
- [ ] CONTRIBUTING.md criado
- [ ] CI passa no GitHub Actions

**Critério de Sucesso:**
```bash
npm test  # All tests pass
npm run test:coverage  # >= 70%
npm run lint  # No errors
# GitHub Actions badge: passing
```

---

## 📈 SPRINT 4: ESCALABILIDADE (8H)

### Objetivo
Clustering, load balancing, cache Redis, connection pooling

### Tarefas

#### TASK 4.1: PM2 Clustering (2h)

**Atualizar ecosystem.config.js:**
```javascript
module.exports = {
  apps: [{
    name: 'khronos-gateway',
    script: 'dist/index.js',
    args: 'gateway --bind lan --port 18789',
    instances: 'max',  // Usar todos os cores
    exec_mode: 'cluster',
    autorestart: true,
    watch: false,
    max_memory_restart: '500M',
    min_uptime: '10s',
    max_restarts: 10,
    env: {
      NODE_ENV: 'production',
      HOME: '/home/node'
    },
    env_production: {
      NODE_ENV: 'production'
    },
    error_file: 'logs/pm2-error.log',
    out_file: 'logs/pm2-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    kill_timeout: 10000,
    wait_ready: true,
    listen_timeout: 3000
  }]
};
```

**Atualizar src/index.js para modo cluster:**
```javascript
// No final do arquivo, depois de criar o servidor
if (process.send) {
  process.send('ready');
}

// IPC communication
process.on('message', (msg) => {
  if (msg === 'shutdown') {
    gracefulShutdown('PM2 shutdown');
  }
});
```

**Validação:**
```bash
pm2 delete all
pm2 start ecosystem.config.js

pm2 list
# Deve mostrar múltiplas instâncias (ex: 4 instâncias em CPU de 4 cores)

pm2 monit
# Ver uso de CPU distribuído entre instâncias
```

---

#### TASK 4.2: Nginx Load Balancer (2h)

**Criar nginx.conf:**
```nginx
upstream khronos_backend {
    least_conn;  # Melhor para WebSockets

    server 127.0.0.1:18789 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:18790 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:18791 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:18792 max_fails=3 fail_timeout=30s;

    keepalive 64;
}

server {
    listen 80;
    server_name khronos.example.com;

    # WebSocket support
    location / {
        proxy_pass http://khronos_backend;
        proxy_http_version 1.1;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 300s;

        proxy_buffering off;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://khronos_backend/health;
        access_log off;
    }

    # Metrics endpoint
    location /metrics {
        proxy_pass http://khronos_backend/metrics;
        allow 127.0.0.1;
        deny all;
    }
}
```

**Atualizar ecosystem.config.js para múltiplas portas:**
```javascript
module.exports = {
  apps: [
    {
      name: 'khronos-gateway-0',
      script: 'dist/index.js',
      args: 'gateway --bind lan --port 18789',
      // ... resto da config
    },
    {
      name: 'khronos-gateway-1',
      script: 'dist/index.js',
      args: 'gateway --bind lan --port 18790',
      // ... resto da config
    },
    {
      name: 'khronos-gateway-2',
      script: 'dist/index.js',
      args: 'gateway --bind lan --port 18791',
      // ... resto da config
    },
    {
      name: 'khronos-gateway-3',
      script: 'dist/index.js',
      args: 'gateway --bind lan --port 18792',
      // ... resto da config
    }
  ]
};
```

**Instalar e iniciar Nginx:**
```bash
sudo apt install nginx
sudo cp nginx.conf /etc/nginx/sites-available/khronos
sudo ln -s /etc/nginx/sites-available/khronos /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

**Validação:**
```bash
curl http://localhost/health
curl http://localhost/metrics

# Fazer várias requisições e ver distribuição
for i in {1..20}; do
  curl -s http://localhost/health | jq .pid
done

# PIDs devem variar (diferentes instâncias)
```

---

#### TASK 4.3: Redis Cache (2h)

**Instalar:**
```bash
npm install ioredis
```

**Arquivo:** `src/cache.js`

```javascript
const Redis = require('ioredis');
const logger = require('./logger');

const redis = new Redis({
  host: process.env.REDIS_HOST || '127.0.0.1',
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD,
  db: 0,
  retryStrategy(times) {
    const delay = Math.min(times * 50, 2000);
    return delay;
  },
  maxRetriesPerRequest: 3
});

redis.on('error', (error) => {
  logger.error('Redis error', { error });
});

redis.on('connect', () => {
  logger.info('Redis connected');
});

// 3-layer cache: Memory → Redis → Compute
class CacheManager {
  constructor() {
    this.memoryCache = new Map();
    this.memoryTTL = 60 * 1000; // 1min
    this.redisTTL = 600; // 10min
  }

  async get(key, computeFn, options = {}) {
    const { ttl = this.redisTTL, skipMemory = false } = options;

    // Layer 1: Memory cache
    if (!skipMemory && this.memoryCache.has(key)) {
      const cached = this.memoryCache.get(key);
      if (Date.now() < cached.expiry) {
        logger.debug('Cache hit (memory)', { key });
        return cached.value;
      } else {
        this.memoryCache.delete(key);
      }
    }

    // Layer 2: Redis cache
    try {
      const redisValue = await redis.get(key);
      if (redisValue !== null) {
        logger.debug('Cache hit (Redis)', { key });
        const parsed = JSON.parse(redisValue);

        // Store in memory cache
        if (!skipMemory) {
          this.memoryCache.set(key, {
            value: parsed,
            expiry: Date.now() + this.memoryTTL
          });
        }

        return parsed;
      }
    } catch (error) {
      logger.warn('Redis cache error', { key, error: error.message });
    }

    // Layer 3: Compute
    logger.debug('Cache miss', { key });
    const value = await computeFn();

    // Store in Redis
    try {
      await redis.setex(key, ttl, JSON.stringify(value));
    } catch (error) {
      logger.error('Redis set error', { key, error: error.message });
    }

    // Store in memory
    if (!skipMemory) {
      this.memoryCache.set(key, {
        value,
        expiry: Date.now() + this.memoryTTL
      });
    }

    return value;
  }

  async invalidate(pattern) {
    // Clear memory cache
    for (const key of this.memoryCache.keys()) {
      if (key.match(pattern)) {
        this.memoryCache.delete(key);
      }
    }

    // Clear Redis cache
    try {
      const keys = await redis.keys(pattern);
      if (keys.length > 0) {
        await redis.del(...keys);
        logger.info('Cache invalidated', { pattern, count: keys.length });
      }
    } catch (error) {
      logger.error('Cache invalidation error', { pattern, error: error.message });
    }
  }

  async clear() {
    this.memoryCache.clear();
    await redis.flushdb();
    logger.info('Cache cleared');
  }
}

const cache = new CacheManager();

module.exports = {
  redis,
  cache
};
```

**Uso:**
```javascript
const { cache } = require('./cache');

// Exemplo: cachear resposta de API
async function getAnthropicResponse(prompt) {
  const cacheKey = `anthropic:${hashPrompt(prompt)}`;

  return cache.get(cacheKey, async () => {
    // Função computacional cara
    const response = await callAnthropicAPI(prompt);
    return response;
  }, { ttl: 3600 }); // 1 hour
}

// Invalidar cache
await cache.invalidate('anthropic:*');
```

**Validação:**
```bash
# Instalar Redis
docker run -d -p 6379:6379 --name redis redis:7-alpine

# Testar cache
node -e "
const { cache } = require('./src/cache');

(async () => {
  let calls = 0;

  const result1 = await cache.get('test', async () => {
    calls++;
    return { value: 42 };
  });

  const result2 = await cache.get('test', async () => {
    calls++;
    return { value: 42 };
  });

  console.log('Calls:', calls); // Should be 1
  console.log('Result:', result1, result2);
})();
"
```

---

#### TASK 4.4: Connection Pooling (2h)

**Instalar:**
```bash
npm install generic-pool better-sqlite3
```

**Arquivo:** `src/db-pool.js`

```javascript
const genericPool = require('generic-pool');
const Database = require('better-sqlite3');
const logger = require('./logger');

const factory = {
  create: async () => {
    const db = new Database(process.env.DB_PATH || '/home/lucas/.openclaw/khronos.db', {
      verbose: process.env.NODE_ENV === 'development' ? console.log : null
    });

    // Optimize SQLite
    db.pragma('journal_mode = WAL');
    db.pragma('synchronous = NORMAL');
    db.pragma('cache_size = 10000');
    db.pragma('temp_store = MEMORY');

    logger.info('Database connection created');
    return db;
  },

  destroy: async (db) => {
    db.close();
    logger.info('Database connection closed');
  },

  validate: async (db) => {
    try {
      db.prepare('SELECT 1').get();
      return true;
    } catch (error) {
      logger.error('Database connection invalid', { error });
      return false;
    }
  }
};

const pool = genericPool.createPool(factory, {
  min: 2,
  max: 10,
  acquireTimeoutMillis: 5000,
  idleTimeoutMillis: 30000,
  evictionRunIntervalMillis: 10000
});

// Metrics
pool.on('factoryCreateError', (error) => {
  logger.error('Pool factory create error', { error });
});

pool.on('factoryDestroyError', (error) => {
  logger.error('Pool factory destroy error', { error });
});

// Helper function
async function withDb(fn) {
  const db = await pool.acquire();
  try {
    return await fn(db);
  } finally {
    await pool.release(db);
  }
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  await pool.drain();
  await pool.clear();
  logger.info('Database pool drained');
});

module.exports = {
  pool,
  withDb
};
```

**Uso:**
```javascript
const { withDb } = require('./db-pool');
const { metrics } = require('./metrics');

async function getUser(userId) {
  const start = Date.now();

  return withDb(async (db) => {
    const user = db.prepare('SELECT * FROM users WHERE id = ?').get(userId);

    const duration = (Date.now() - start) / 1000;
    metrics.databaseQueryDuration.observe({ operation: 'getUser' }, duration);

    return user;
  });
}

async function createUser(userData) {
  return withDb(async (db) => {
    const insert = db.prepare('INSERT INTO users (name, email) VALUES (?, ?)');
    const result = insert.run(userData.name, userData.email);
    return result.lastInsertRowid;
  });
}
```

**Validação:**
```bash
node -e "
const { pool, withDb } = require('./src/db-pool');

(async () => {
  // Criar múltiplas queries simultâneas
  const promises = [];
  for (let i = 0; i < 20; i++) {
    promises.push(
      withDb(async (db) => {
        const result = db.prepare('SELECT 1 as test').get();
        console.log('Query', i, 'done');
        return result;
      })
    );
  }

  await Promise.all(promises);

  console.log('Pool size:', pool.size);
  console.log('Pool available:', pool.available);
  console.log('Pool pending:', pool.pending);
})();
"
```

---

### ✅ CHECKLIST SPRINT 4

- [ ] PM2 clustering ativo (múltiplas instâncias)
- [ ] Nginx load balancer configurado
- [ ] Redis cache implementado (3 camadas)
- [ ] Connection pooling ativo (generic-pool)
- [ ] Testes de carga passando
- [ ] Observability dashboard criado

**Critério de Sucesso:**
```bash
pm2 list  # Múltiplas instâncias khronos-gateway
sudo nginx -t  # Config válida
redis-cli ping  # PONG
curl http://localhost/health  # Load balancer funcionando

# Teste de carga
ab -n 1000 -c 10 http://localhost/health
# Deve distribuir entre instâncias sem erros
```

---

## 🎯 RESUMO EXECUTIVO

### Progresso Total: 30 horas divididas em 5 sprints

| Sprint | Duração | Status | Prioridade |
|--------|---------|--------|-----------|
| Sprint 0: Setup Básico | 2h | ⏳ Pendente | 🔴 Crítica |
| Sprint 1: Resiliência | 6h | ⏳ Pendente | 🔴 Crítica |
| Sprint 2: Backup & Monitoring | 8h | ⏳ Pendente | 🟡 Alta |
| Sprint 3: Testing & CI/CD | 6h | ⏳ Pendente | 🟡 Alta |
| Sprint 4: Escalabilidade | 8h | ⏳ Pendente | 🟢 Média |

### Ganhos Esperados

**Após Sprint 0 + 1 (8h):**
- ✅ 90% uptime (vs atual ~70%)
- ✅ Auto-restart em falhas
- ✅ Circuit breakers protegem APIs
- ✅ Rate limiting evita bans

**Após Sprint 2 (16h total):**
- ✅ 99% uptime
- ✅ Backup automático (pode restaurar qualquer ponto no tempo)
- ✅ Alertas Telegram em problemas críticos
- ✅ Dashboards Grafana para monitoramento

**Após Sprint 3 (22h total):**
- ✅ 99.5% uptime
- ✅ CI/CD automatizado (deploys seguros)
- ✅ Testes cobrem 70%+ do código
- ✅ Qualidade de código garantida

**Após Sprint 4 (30h total):**
- ✅ 99.9% uptime
- ✅ Suporta 1M+ requests/dia
- ✅ Cache reduz 80% das chamadas a APIs caras
- ✅ Multi-core utilizado (4x+ throughput)

### Quick Wins (faça primeiro!)

1. **SPRINT 0 TASK 0.2** (30min) - ecosystem.config.js com auto-restart
   - Resolve: Causas #2, #5, #6
   - Impacto: +20% uptime imediato

2. **SPRINT 1 TASK 1.3** (2h) - Graceful shutdown
   - Resolve: Causa #1, #5
   - Impacto: Sem perda de conexões em restart

3. **SPRINT 1 TASK 1.2** (2h) - Rate limiting Telegram
   - Resolve: Causa #4
   - Impacto: Sem bans do Telegram

4. **SPRINT 1 TASK 1.1** (2h) - Circuit breakers
   - Resolve: Causa #7
   - Impacto: Sem cascata de erros

5. **scripts/monitor_openclaw.sh** (já criado!) - Monitoramento
   - Resolve: Causas #2, #3, #6
   - Impacto: Auto-recovery em problemas

### Como Executar (TDAH-friendly)

**Regra de Ouro:** 1 task por sessão, validar antes de próxima

```bash
# Sessão 1 (30min): PM2 setup
cd /mnt/c/Users/lucas/Desktop/openclaw-main
# Seguir SPRINT 0 TASK 0.1 e 0.2
# ✅ Validar: pm2 list mostra app online
# 🎉 Comemorar! Tomar café.

# Sessão 2 (30min): Logger
# Seguir SPRINT 0 TASK 0.3
# ✅ Validar: logs/combined.log existe
# 🎉 Comemorar! Alongar.

# Sessão 3 (30min): Health endpoints
# Seguir SPRINT 0 TASK 0.4
# ✅ Validar: curl http://localhost:18789/health
# 🎉 SPRINT 0 COMPLETA! Dar uma volta.

# Continue assim...
```

### Scripts Úteis

**Rodar monitoring:**
```bash
# Adicionar ao crontab
*/5 * * * * bash /mnt/c/Users/lucas/Desktop/openclaw-main/scripts/monitor_openclaw.sh
```

**Ver status geral:**
```bash
pm2 list
pm2 monit
docker compose ps
curl http://localhost:18789/health
```

**Backup manual:**
```bash
litestream restore -config litestream.yml -o /tmp/backup.db /home/lucas/.openclaw/khronos.db
```

---

## 🚨 ATENÇÃO: DEPRECATION WARNING

**Detected no log:** "Using the deprecated Claude 3.7 Sonnet model"

### Action Required:
Atualizar configuração do modelo para Claude 4.5 ou 4.0:

```javascript
// Em openclaw.json ou config
{
  "anthropic": {
    "model": "claude-sonnet-4-5-20250929"  // Atualizar aqui
  }
}
```

**Urgência:** Média (modelo 3.7 será descontinuado)

---

## 📞 SUPORTE

Se qualquer sprint falhar:

1. Verificar logs: `pm2 logs khronos-gateway --lines 50`
2. Verificar health: `curl http://localhost:18789/health`
3. Verificar permissões: `ls -la /home/lucas/.openclaw/`
4. Rodar fix: `bash scripts/fix_openclaw.sh`
5. Consultar RELATORIO_FIX_OPENCLAW.md

**Logs importantes:**
- `logs/combined.log` - Tudo
- `logs/error.log` - Só erros
- `logs/pm2-error.log` - Erros do PM2
- `/tmp/openclaw_monitor.log` - Monitor script

---

## ✅ VALIDAÇÃO FINAL (após todas as sprints)

```bash
#!/usr/bin/env bash
# validation_final.sh

echo "=== VALIDAÇÃO FINAL KHRONOS ==="

# PM2
pm2 list | grep -q "khronos-gateway.*online" && echo "✅ PM2 online" || echo "❌ PM2 offline"

# Health
curl -sf http://localhost:18789/health > /dev/null && echo "✅ Health OK" || echo "❌ Health fail"

# Metrics
curl -sf http://localhost:18789/metrics | grep -q "khronos_" && echo "✅ Metrics OK" || echo "❌ Metrics fail"

# Litestream
litestream databases -config litestream.yml | grep -q "khronos.db" && echo "✅ Backup OK" || echo "❌ Backup fail"

# Redis
redis-cli ping | grep -q "PONG" && echo "✅ Redis OK" || echo "❌ Redis fail"

# Logs
test -f logs/combined.log && echo "✅ Logs OK" || echo "❌ Logs fail"

# Tests
npm test --silent && echo "✅ Tests OK" || echo "❌ Tests fail"

# Coverage
COVERAGE=$(cat coverage/coverage-summary.json | jq .total.lines.pct)
echo "Coverage: $COVERAGE%"
[[ $(echo "$COVERAGE > 70" | bc) -eq 1 ]] && echo "✅ Coverage OK" || echo "❌ Coverage baixo"

echo "=== FIM VALIDAÇÃO ==="
```

**Critério de Sucesso:** Todos ✅ verdes

---

## 🎓 PRÓXIMOS PASSOS (pós-roadmap)

Após completar as 4 sprints, considerar:

1. **Kubernetes deployment** - Orquestração avançada
2. **Multi-region replication** - Disaster recovery
3. **A/B testing framework** - Experimentação
4. **Real-time analytics** - Insights em tempo real
5. **Auto-scaling** - Escala automática baseada em carga
6. **Canary deployments** - Deploy gradual seguro
7. **Feature flags** - Toggle features sem deploy
8. **Performance profiling** - Clinic.js, 0x
9. **Security hardening** - Helmet, rate limiting por IP, CSP
10. **Compliance** - GDPR, LGPD data handling

---

**Criado em:** 2026-01-31
**Versão:** 1.0
**Autor:** Claude Sonnet 4.5
**Projeto:** OpenClaw/Khronos Production Hardening

**Bora começar! 🚀**
