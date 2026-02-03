# 📊 SPRINT 2: BACKUP & MONITORING (8H)

> **Objetivo:** Seus dados nunca são perdidos + você vê tudo em tempo real
> **Duração:** 8 horas (4 tasks de 2h cada)
> **Pré-requisito:** SPRINT 0 + SPRINT 1
> **Seu TDAH:** Um task por dia = perfeito!

---

## TASK 2.1: Litestream para Backup Automático (2H)

### 🎯 O Problema
Database cai, você perde TUDO de histórico, estados, configurações.

### 💡 A Solução
Litestream faz backup contínuo do SQLite para S3/B2 em tempo real (streaming).

### 📝 Implementação

#### Passo 1: Instalar Litestream

```bash
# Baixar Litestream (Linux)
wget https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-amd64.tar.gz

# Extrair
tar xzf litestream-v0.3.13-linux-amd64.tar.gz

# Instalar globalmente
sudo cp litestream /usr/local/bin/
sudo chmod +x /usr/local/bin/litestream

# Verificar
litestream version
```

#### Passo 2: Criar Config (litestream.yml)

Na raiz do seu projeto:

```yaml
# ============ LITESTREAM CONFIG ============
dbs:
  - path: /home/node/.openclaw/state.db
    
    # ============ S3 BACKUP ============
    replicas:
      - type: s3
        bucket: seu-bucket-backup
        path: khronos/state.db
        
        # ============ AWS CREDENTIALS ============
        access-key-id: ${AWS_ACCESS_KEY_ID}
        secret-access-key: ${AWS_SECRET_ACCESS_KEY}
        region: us-east-1
        
        # ============ SYNC CONFIG ============
        sync-interval: 5s          # Sync a cada 5s
        validation-interval: 24h   # Validação diária
        
        # ============ RETENTION ============
        retention: 168h            # Manter por 7 dias
        retention-check-interval: 1h

    # ============ B2 BACKUP (Secondary) ============
    # Se preferir Backblaze B2 (mais barato)
    # replicas:
    #   - type: b2
    #     bucket: seu-bucket-b2
    #     key-id: ${B2_KEY_ID}
    #     application-key: ${B2_APPLICATION_KEY}
    #     path: khronos/state.db

monitoring:
  # ============ METRICS ============
  addr: ":9090"
  
# ============ LOG ============
logging:
  level: info
  format: json
```

#### Passo 3: Criar Script de Restore

Criar `scripts/restore-backup.sh`:

```bash
#!/bin/bash

set -e

echo "🔄 LITESTREAM RESTORE"
echo ""

# Variáveis
DB_PATH="/home/node/.openclaw/state.db"
DB_BACKUP="${DB_PATH}.backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "📍 Database Path: $DB_PATH"
echo ""

# ============ STEP 1: BACKUP CURRENT ============
if [ -f "$DB_PATH" ]; then
  echo "💾 Backing up current database..."
  cp "$DB_PATH" "${DB_BACKUP}.${TIMESTAMP}"
  echo "✅ Backup created: ${DB_BACKUP}.${TIMESTAMP}"
fi

# ============ STEP 2: RESTORE FROM S3 ============
echo ""
echo "📥 Restoring from S3..."

litestream restore -o "$DB_PATH" \
  -replica s3://seu-bucket-backup/khronos/state.db

if [ $? -eq 0 ]; then
  echo "✅ Restore successful!"
  ls -lh "$DB_PATH"
else
  echo "❌ Restore failed!"
  exit 1
fi

# ============ STEP 3: VERIFY ============
echo ""
echo "🔍 Verifying restore..."
sqlite3 "$DB_PATH" "SELECT COUNT(*) as total_rows FROM sqlite_master;"

echo ""
echo "✅ Restore complete!"
```

Dar permissão:
```bash
chmod +x scripts/restore-backup.sh
```

#### Passo 4: Integrar com PM2

Adicionar ao `ecosystem.config.js`:

```javascript
{
  name: "litestream",
  script: "litestream",
  args: "replicate /home/node/.openclaw/state.db -config litestream.yml",
  
  autorestart: true,
  max_restarts: 10,
  min_uptime: "10s",
  restart_delay: 4000,
  
  error_file: "./logs/litestream-error.log",
  out_file: "./logs/litestream-out.log",
  
  env: {
    AWS_ACCESS_KEY_ID: "YOUR_KEY",
    AWS_SECRET_ACCESS_KEY: "YOUR_SECRET"
  }
}
```

### 🧪 Testar

```bash
# 1. Iniciar Litestream
pm2 start litestream

# 2. Ver logs
pm2 logs litestream

# 3. Simular falha (deletar database)
# rm /home/node/.openclaw/state.db

# 4. Restaurar
./scripts/restore-backup.sh

# 5. Verificar que restaurou
ls -lh /home/node/.openclaw/state.db
```

---

## TASK 2.2: Prometheus para Métricas (2H)

### 🎯 O Problema
Você não vê o que está acontecendo em tempo real (CPU, memory, requests, etc).

### 💡 A Solução
Prometheus coleta métricas que você visualiza no Grafana.

### 📝 Implementação

#### Passo 1: Criar Metrics Module

Criar `src/metrics.js`:

```javascript
const promClient = require('prom-client');
const logger = require('./logger');

// ============ REGISTER ============
const register = new promClient.Registry();

// ============ DEFAULT METRICS ============
promClient.collectDefaultMetrics({ register });

// ============ CUSTOM METRICS ============

// Counter: Mensagens processadas
const messagesProcessedCounter = new promClient.Counter({
  name: 'khronos_messages_processed_total',
  help: 'Total de mensagens processadas',
  labelNames: ['source', 'status'],
  registers: [register]
});

// Counter: Mensagens falhadas
const messagesFailedCounter = new promClient.Counter({
  name: 'khronos_messages_failed_total',
  help: 'Total de mensagens que falharam',
  labelNames: ['source', 'reason'],
  registers: [register]
});

// Gauge: Usuarios ativos
const activeUsersGauge = new promClient.Gauge({
  name: 'khronos_active_users',
  help: 'Número de usuários ativos agora',
  registers: [register]
});

// Gauge: Queue size
const queueSizeGauge = new promClient.Gauge({
  name: 'khronos_queue_size',
  help: 'Tamanho da fila de mensagens',
  registers: [register]
});

// Histogram: Latência de resposta
const responseTimeHistogram = new promClient.Histogram({
  name: 'khronos_response_time_ms',
  help: 'Tempo de resposta em milissegundos',
  labelNames: ['endpoint'],
  buckets: [10, 50, 100, 250, 500, 1000, 2500, 5000],
  registers: [register]
});

// Histogram: Latência de IA
const aiLatencyHistogram = new promClient.Histogram({
  name: 'khronos_ai_latency_ms',
  help: 'Latência de chamadas de IA',
  labelNames: ['provider'],
  buckets: [100, 500, 1000, 2000, 5000, 10000],
  registers: [register]
});

// Counter: API calls por provider
const apiCallsCounter = new promClient.Counter({
  name: 'khronos_api_calls_total',
  help: 'Total de chamadas de API',
  labelNames: ['provider', 'status'],
  registers: [register]
});

// Counter: Circuit breaker state changes
const circuitBreakerStateCounter = new promClient.Counter({
  name: 'khronos_circuit_breaker_state_changes_total',
  help: 'Mudanças de estado do circuit breaker',
  labelNames: ['breaker', 'state'],
  registers: [register]
});

// ============ MIDDLEWARE ============
function metricsMiddleware(req, res, next) {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    responseTimeHistogram
      .labels(req.path)
      .observe(duration);
  });
  
  next();
}

// ============ FUNCTIONS ============
function recordMessageProcessed(source, status) {
  messagesProcessedCounter.labels(source, status).inc();
}

function recordMessageFailed(source, reason) {
  messagesFailedCounter.labels(source, reason).inc();
}

function setActiveUsers(count) {
  activeUsersGauge.set(count);
}

function setQueueSize(count) {
  queueSizeGauge.set(count);
}

function recordAILatency(provider, duration) {
  aiLatencyHistogram.labels(provider).observe(duration);
}

function recordAPICall(provider, status) {
  apiCallsCounter.labels(provider, status).inc();
}

function recordCircuitBreakerStateChange(breaker, state) {
  circuitBreakerStateCounter.labels(breaker, state).inc();
}

// ============ EXPORT METRICS ============
function getMetrics() {
  return register.metrics();
}

// ============ EXPORTS ============
module.exports = {
  register,
  metricsMiddleware,
  recordMessageProcessed,
  recordMessageFailed,
  setActiveUsers,
  setQueueSize,
  recordAILatency,
  recordAPICall,
  recordCircuitBreakerStateChange,
  getMetrics
};
```

#### Passo 2: Integrar com Express

No seu `src/index.js`:

```javascript
const { metricsMiddleware, getMetrics } = require('./metrics');

app.use(metricsMiddleware);

// ============ PROMETHEUS ENDPOINT ============
app.get('/metrics', (req, res) => {
  res.set('Content-Type', 'text/plain; version=0.0.4');
  res.end(getMetrics());
});
```

#### Passo 3: Criar prometheus.yml

Na raiz:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'khronos'
    static_configs:
      - targets: ['localhost:18789']
    metrics_path: '/metrics'
    scrape_interval: 5s
    scrape_timeout: 5s
```

#### Passo 4: Docker Prometheus

Adicionar ao `docker-compose.yml`:

```yaml
prometheus:
  image: prom/prometheus:latest
  container_name: prometheus
  ports:
    - "9090:9090"
  volumes:
    - ./prometheus.yml:/etc/prometheus/prometheus.yml
    - prometheus_data:/prometheus
  command:
    - '--config.file=/etc/prometheus/prometheus.yml'
    - '--storage.tsdb.path=/prometheus'
  networks:
    - openclaw-network

volumes:
  prometheus_data:
```

### 🧪 Testar

```bash
# 1. Iniciar Prometheus
docker-compose up prometheus

# 2. Acessar
# http://localhost:9090

# 3. Query graph
# Sum(rate(khronos_messages_processed_total[1m]))
```

---

## TASK 2.3: Winston Logging Avançado (2H)

### 🎯 O Problema
Você não sabe o que aconteceu quando o bot falha.

### 💡 A Solução
Logs estruturados, JSON, com contexto, correlation IDs, etc.

### 📝 Implementação

Expandir seu `src/logger.js`:

```javascript
const winston = require('winston');
const crypto = require('crypto');

// ============ CORRELATION ID ============
let correlationId = null;

function setCorrelationId(id) {
  correlationId = id;
}

function getCorrelationId() {
  return correlationId || crypto.randomUUID();
}

// ============ LOGGER COMPLETO ============
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  
  // ============ FORMAT ============
  format: winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
    winston.format.errors({ stack: true }),
    
    // ============ CUSTOM FORMAT ============
    winston.format.printf(({ level, message, timestamp, ...meta }) => {
      const correlationIdValue = meta.correlationId || getCorrelationId();
      const userId = meta.userId || 'SYSTEM';
      
      return JSON.stringify({
        '@timestamp': timestamp,
        level,
        message,
        correlationId: correlationIdValue,
        userId,
        service: 'khronos',
        environment: process.env.NODE_ENV,
        pid: process.pid,
        ...meta
      });
    })
  ),
  
  defaultMeta: {
    service: 'khronos',
    version: process.env.npm_package_version || '1.0.0'
  },
  
  // ============ TRANSPORTS ============
  transports: [
    // ============ CONSOLE ============
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    }),
    
    // ============ FILE - TODOS OS LOGS ============
    new winston.transports.File({
      filename: 'logs/combined.log',
      maxsize: 20971520, // 20MB
      maxFiles: 7,
      tailable: true
    }),
    
    // ============ FILE - ERROS APENAS ============
    new winston.transports.File({
      filename: 'logs/errors.log',
      level: 'error',
      maxsize: 20971520,
      maxFiles: 30,
      tailable: true
    }),
    
    // ============ FILE - CRÍTICO APENAS ============
    new winston.transports.File({
      filename: 'logs/critical.log',
      level: 'error',
      filter: (info) => info.level === 'error' && info.critical === true,
      maxsize: 10485760,
      maxFiles: 90
    })
  ],
  
  // ============ EXCEPTION HANDLERS ============
  exceptionHandlers: [
    new winston.transports.File({
      filename: 'logs/exceptions.log'
    })
  ],
  
  // ============ REJECTION HANDLERS ============
  rejectionHandlers: [
    new winston.transports.File({
      filename: 'logs/rejections.log'
    })
  ]
});

// ============ HELPER FUNCTIONS ============
const logWithContext = (level, message, context = {}) => {
  logger.log(level, message, {
    ...context,
    correlationId: getCorrelationId(),
    timestamp: new Date().toISOString()
  });
};

// ============ EXPORTS ============
module.exports = {
  logger,
  setCorrelationId,
  getCorrelationId,
  
  info: (msg, ctx) => logWithContext('info', msg, ctx),
  warn: (msg, ctx) => logWithContext('warn', msg, ctx),
  error: (msg, ctx) => logWithContext('error', msg, ctx),
  debug: (msg, ctx) => logWithContext('debug', msg, ctx),
  
  // ============ SEMANTIC LOGGING ============
  logUserAction: (userId, action, details = {}) => {
    logWithContext('info', `User action: ${action}`, {
      userId,
      action,
      ...details
    });
  },
  
  logAPICall: (method, url, status, duration) => {
    logWithContext('info', `API call: ${method} ${url}`, {
      method,
      url,
      status,
      durationMs: duration
    });
  },
  
  logDatabaseQuery: (query, duration, rowsAffected) => {
    logWithContext('debug', 'Database query', {
      query: query.substring(0, 100),
      durationMs: duration,
      rowsAffected
    });
  },
  
  logJobStart: (jobId, jobType) => {
    logWithContext('info', `Job started: ${jobType}`, {
      jobId,
      jobType,
      startTime: Date.now()
    });
  },
  
  logJobComplete: (jobId, duration, success = true) => {
    logWithContext('info', 'Job completed', {
      jobId,
      durationMs: duration,
      success
    });
  }
};
```

### 🧪 Testar

```bash
# Ver logs em JSON
tail -f logs/combined.log | jq

# Filtrar por nível
tail -f logs/errors.log | jq 'select(.level=="error")'

# Filtrar por usuário
tail -f logs/combined.log | jq 'select(.userId=="123")'

# Filtrar por correlationId
tail -f logs/combined.log | jq 'select(.correlationId=="abc-123")'
```

---

## TASK 2.4: Alertas via Telegram (2H)

### 🎯 O Problema
Erro crítico acontece, você só vê horas depois ao acordar.

### 💡 A Solução
Enviar alertas críticos direto pro Telegram.

### 📝 Implementação

Criar `src/alerts.js`:

```javascript
const logger = require('./logger');
const { telegramBreaker } = require('./circuit-breaker');

const ALERT_CHAT_ID = process.env.ALERT_CHAT_ID;
const CRITICAL_CHAT_ID = process.env.CRITICAL_CHAT_ID;

// ============ ALERT LEVELS ============
const ALERT_LEVELS = {
  INFO: { emoji: 'ℹ️', level: 0 },
  WARN: { emoji: '⚠️', level: 1 },
  ERROR: { emoji: '❌', level: 2 },
  CRITICAL: { emoji: '🚨', level: 3 }
};

// ============ RATE LIMIT ALERTS ============
const alertCache = new Map();
const ALERT_COOLDOWN = 5 * 60 * 1000; // 5 minutos

function shouldAlert(key) {
  const lastAlert = alertCache.get(key);
  const now = Date.now();
  
  if (!lastAlert || (now - lastAlert) > ALERT_COOLDOWN) {
    alertCache.set(key, now);
    return true;
  }
  
  return false;
}

// ============ ENVIAR ALERTA ============
async function sendAlert(message, level = 'WARN', details = {}) {
  try {
    const { emoji } = ALERT_LEVELS[level];
    const key = `${level}:${message}`;
    
    // Rate limit: não enviar mesmo alerta frequentemente
    if (!shouldAlert(key)) {
      logger.debug('Alert rate limited', { message, level });
      return;
    }
    
    const formattedMessage = `${emoji} [${new Date().toLocaleTimeString()}] ${message}`;
    
    // Detalhes adicionais
    let detailsText = '';
    if (Object.keys(details).length > 0) {
      detailsText = '\n\n```\n' + JSON.stringify(details, null, 2) + '\n```';
    }
    
    const fullMessage = formattedMessage + detailsText;
    
    // Escolher chat based on level
    const chatId = level === 'CRITICAL' ? CRITICAL_CHAT_ID : ALERT_CHAT_ID;
    
    if (!chatId) {
      logger.warn('Alert chat ID not configured');
      return;
    }
    
    // Usar circuit breaker para enviar
    const response = await telegramBreaker.fire(
      chatId,
      fullMessage,
      { parseMode: 'Markdown' }
    );
    
    logger.info('Alert sent', { message, level, chatId });
    return response;
    
  } catch (error) {
    logger.error('Failed to send alert', { error });
  }
}

// ============ SEMANTIC ALERTS ============

async function alertCircuitBreakerOpen(breakerName, reason) {
  await sendAlert(
    `Circuit Breaker: ${breakerName} abriu!`,
    'ERROR',
    { reason, time: new Date().toISOString() }
  );
}

async function alertDatabaseDown() {
  await sendAlert(
    `Database desconectou!`,
    'CRITICAL',
    { service: 'database', action: 'reconectar manualmente se necessário' }
  );
}

async function alertHighErrorRate(errorRate, threshold) {
  await sendAlert(
    `Taxa de erro alto: ${(errorRate * 100).toFixed(2)}% (threshold: ${(threshold * 100).toFixed(2)}%)`,
    'ERROR',
    { errorRate, threshold, timestamp: new Date().toISOString() }
  );
}

async function alertHighMemoryUsage(usage, limit) {
  await sendAlert(
    `Uso de memória alto: ${usage}MB / ${limit}MB`,
    'WARN',
    { usageMB: usage, limitMB: limit }
  );
}

async function alertLongQueueBacklog(queueSize, maxSize) {
  await sendAlert(
    `Fila de mensagens crescendo: ${queueSize} / ${maxSize}`,
    'WARN',
    { queueSize, maxSize }
  );
}

async function alertServiceUnhealthy(service, reason) {
  await sendAlert(
    `Serviço ${service} ficou unhealthy`,
    'ERROR',
    { service, reason }
  );
}

// ============ MONITORING LOOP ============
function startAlertMonitoring(interval = 60000) {
  setInterval(() => {
    const memUsage = process.memoryUsage().heapUsed / 1024 / 1024;
    const memLimit = parseInt(process.env.MAX_MEMORY_MB || '1000');
    
    // Alert memory
    if (memUsage > memLimit * 0.9) {
      alertHighMemoryUsage(Math.round(memUsage), memLimit);
    }
  }, interval);
}

// ============ EXPORTS ============
module.exports = {
  sendAlert,
  alertCircuitBreakerOpen,
  alertDatabaseDown,
  alertHighErrorRate,
  alertHighMemoryUsage,
  alertLongQueueBacklog,
  alertServiceUnhealthy,
  startAlertMonitoring
};
```

Integrar no seu `src/index.js`:

```javascript
const { startAlertMonitoring } = require('./alerts');

// ============ INICIAR ALERTS ============
startAlertMonitoring(60000); // Check a cada 1 minuto
```

### 🧪 Testar

```bash
# Enviar alerta manualmente
curl -X POST http://localhost:18789/test-alert \
  -H "Content-Type: application/json" \
  -d '{"message":"Test alert", "level":"WARN"}'
```

---

## ✅ CHECKLIST SPRINT 2

- [ ] Litestream instalado e rodando
- [ ] Backup sendo enviado para S3/B2
- [ ] Script de restore funciona
- [ ] Prometheus coletando métricas
- [ ] Dashboard Prometheus mostra dados
- [ ] Winston logging com JSON estruturado
- [ ] Logs sendo escritos em 3 arquivos (combined, errors, critical)
- [ ] Alertas sendo enviados via Telegram
- [ ] Memory monitoring ativo
- [ ] Circuit breaker mudanças aparecem em alertas

---

## 📊 TEMPO REAL

- Task 2.1 (Litestream): 2h
- Task 2.2 (Prometheus): 2h
- Task 2.3 (Winston): 2h
- Task 2.4 (Alerts): 2h
- **TOTAL: 8 horas**

---

## 🎯 O QUE VOCÊ TEM AGORA

✅ Dados sendo backup automáticamente
✅ Métricas sendo coletadas
✅ Logs estruturados e buscáveis
✅ Alertas em tempo real
✅ Visibilidade 24/7

---

## 🚀 PRÓXIMA SPRINT

**→ SPRINT_3_TESTING_E_QUALITY.md**

Lá você implementa:
- Jest testing
- Coverage reports
- CI/CD com GitHub Actions
- Code quality checks
