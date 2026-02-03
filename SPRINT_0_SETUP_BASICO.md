# 🚀 SPRINT 0: SETUP BÁSICO (2H)

> **Objetivo:** Deixar seu ambiente pronto com PM2, Docker e health checks funcionando
> **Duração:** 2 horas
> **Seu TDAH:** Cada step é independente, pode parar e voltar

---

## 📋 TAREFAS SPRINT 0

### TASK 0.1: Instalar PM2 Globalmente (10 min)
**Status:** ⬜ Não iniciado

```bash
# 1. Instalar globalmente
npm install -g pm2

# 2. Verificar instalação
pm2 -v
# Deve retornar versão (ex: 5.3.1)

# 3. Instalar auto-pull (opcional)
pm2 install pm2-auto-pull

# 4. Ativar startup
pm2 startup
pm2 save
```

**Validação:**
- [ ] `pm2 -v` retorna versão
- [ ] `which pm2` mostra `/usr/local/bin/pm2` ou similar
- [ ] `pm2 list` retorna lista vazia

---

### TASK 0.2: Instalar Dependências NPM (15 min)
**Status:** ⬜ Não iniciado

```bash
# Navegar para projeto
cd /seu/projeto

# Instalar production dependencies
npm install \
  pm2 \
  ioredis \
  bottleneck \
  winston \
  winston-daily-rotate-file \
  telegraf \
  opossum \
  helmet \
  zod \
  express-rate-limit

# Instalar dev dependencies
npm install --save-dev \
  nodemon \
  jest \
  supertest \
  @types/node
```

**Validação:**
- [ ] `npm list pm2` mostra versão instalada
- [ ] `ls node_modules/ioredis` existe
- [ ] Sem erros no console

---

### TASK 0.3: Criar Estrutura de Pastas (5 min)
**Status:** ⬜ Não iniciado

```bash
cd /seu/projeto

# Criar pastas
mkdir -p src logs config tests .github/workflows

# Estrutura esperada
tree -L 2
# src/
# ├── index.js (seu app principal)
# ├── logger.js
# ├── redis.js
# ├── limiter.js
# └── graceful-shutdown.js
# logs/
# config/
# tests/
# ecosystem.config.js
# package.json
```

**Validação:**
- [ ] Pasta `src` existe
- [ ] Pasta `logs` existe
- [ ] Pasta `tests` existe

---

### TASK 0.4: Criar ecosystem.config.js (10 min)
**Status:** ⬜ Não iniciado

Na raiz do seu projeto, crie `ecosystem.config.js`:

```javascript
module.exports = {
  apps: [
    {
      // ============ IDENTIFICAÇÃO ============
      name: "khronos",
      script: "./src/index.js",
      description: "Khronos - Multi-channel AI Bot Framework",
      
      // ============ CLUSTERING ============
      instances: "max",           // Usa todos os cores
      exec_mode: "cluster",       // Load balancing automático
      
      // ============ AUTO-RESTART ============
      autorestart: true,          // Reinicia quando crasha
      max_restarts: 10,           // Max 10 tentativas
      min_uptime: "10s",          // Uptime mín antes de considerar "success"
      restart_delay: 4000,        // Espera 4s entre restarts
      
      // ============ MEMORY ============
      max_memory_restart: "1G",   // Reinicia se usar >1GB RAM
      
      // ============ WATCH (DEV) ============
      watch: ["src"],             // Restarta se mudar arquivos em src
      ignore_watch: [
        "node_modules",
        "logs",
        ".git",
        "tests"
      ],
      
      // ============ ENVIRONMENT ============
      env: {
        NODE_ENV: "production",
        PORT: 18789,
        LOG_LEVEL: "info"
      },
      env_development: {
        NODE_ENV: "development",
        PORT: 18789,
        LOG_LEVEL: "debug"
      },
      
      // ============ GRACEFUL SHUTDOWN ============
      kill_timeout: 5000,         // Espera 5s antes de matar processo
      wait_ready: true,           // Aguarda ready event
      listen_timeout: 3000,       // Timeout para listen
      
      // ============ LOGS ============
      error_file: "./logs/error.log",
      out_file: "./logs/out.log",
      log_file: "./logs/combined.log",
      log_date_format: "YYYY-MM-DD HH:mm:ss Z",
      
      // ============ SOURCE MAP ============
      source_map_support: true,
      
      // ============ MERGE LOGS ============
      merge_logs: false,
      
      // ============ ARGS ============
      args: "",
      
      // ============ CRON RESTART ============
      cron_restart: "0 0 * * *",  // Restart todos os dias à meia-noite
      
      // ============ IGNORE PATTERNS ============
      ignore_patterns: ["node_modules"],
    }
  ],
  
  // ============ DEPLOY CONFIG ============
  deploy: {
    production: {
      user: "node",
      host: "your-server.com",
      ref: "origin/main",
      repo: "git@github.com:your-repo.git",
      path: "/var/www/khronos",
      "post-deploy": "npm install && npm run build && pm2 restart ecosystem.config.js",
      "pre-deploy-local": "echo 'Deploying to production...'"
    },
    staging: {
      user: "node",
      host: "staging-server.com",
      ref: "origin/develop",
      repo: "git@github.com:your-repo.git",
      path: "/var/www/khronos-staging",
      "post-deploy": "npm install && npm run build && pm2 restart ecosystem.config.js"
    }
  }
};
```

**Validação:**
- [ ] Arquivo `ecosystem.config.js` criado
- [ ] Sem erros de sintaxe: `pm2 validate ecosystem.config.js`
- [ ] `pm2 list` reconhece a config

---

### TASK 0.5: Criar Logger Module (15 min)
**Status:** ⬜ Não iniciado

Criar `src/logger.js`:

```javascript
const winston = require('winston');
require('winston-daily-rotate-file');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.errors({ stack: true }),
    winston.format.splat(),
    winston.format.json()
  ),
  defaultMeta: {
    service: 'khronos-gateway',
    pid: process.pid,
    version: process.env.npm_package_version || '1.0.0'
  },
  
  transports: [
    // ============ CONSOLE (Development) ============
    new winston.transports.Console({
      level: process.env.NODE_ENV === 'production' ? 'warn' : 'debug',
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.printf(({ level, message, timestamp, ...meta }) => {
          return `${timestamp} [${level}] ${message} ${
            Object.keys(meta).length ? JSON.stringify(meta, null, 2) : ''
          }`;
        })
      )
    }),
    
    // ============ FILE - All Logs ============
    new winston.transports.DailyRotateFile({
      filename: 'logs/application-%DATE%.log',
      datePattern: 'YYYY-MM-DD',
      maxSize: '20m',
      maxDays: '14d',
      format: winston.format.json()
    }),
    
    // ============ FILE - Errors Only ============
    new winston.transports.DailyRotateFile({
      filename: 'logs/error-%DATE%.log',
      datePattern: 'YYYY-MM-DD',
      level: 'error',
      maxSize: '20m',
      maxDays: '30d',
      format: winston.format.json()
    }),
    
    // ============ FILE - Critical Only ============
    new winston.transports.File({
      filename: 'logs/critical.log',
      level: 'error',
      maxsize: 5242880, // 5MB
      maxFiles: 5
    })
  ],
  
  // ============ Handle Uncaught Exceptions ============
  exceptionHandlers: [
    new winston.transports.File({
      filename: 'logs/exceptions.log'
    })
  ],
  
  // ============ Handle Unhandled Rejections ============
  rejectionHandlers: [
    new winston.transports.File({
      filename: 'logs/rejections.log'
    })
  ]
});

// ============ Custom Methods ============
logger.debug = function(message, meta = {}) {
  this.log('debug', message, meta);
};

logger.info = function(message, meta = {}) {
  this.log('info', message, meta);
};

logger.warn = function(message, meta = {}) {
  this.log('warn', message, meta);
};

logger.error = function(message, meta = {}) {
  this.log('error', message, meta);
};

logger.critical = function(message, meta = {}) {
  this.log('error', `🚨 CRITICAL: ${message}`, meta);
};

module.exports = logger;
```

**Validação:**
- [ ] Arquivo `src/logger.js` criado
- [ ] Sem erros de sintaxe
- [ ] Pode ser importado: `node -e "require('./src/logger')"`

---

### TASK 0.6: Criar Redis Module (10 min)
**Status:** ⬜ Não iniciado

Criar `src/redis.js`:

```javascript
const Redis = require('ioredis');
const logger = require('./logger');

const redis = new Redis({
  // ============ CONNECTION ============
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD || undefined,
  db: parseInt(process.env.REDIS_DB || '0'),
  
  // ============ RETRY STRATEGY ============
  retryStrategy: (times) => {
    const delay = Math.min(times * 50, 2000);
    logger.warn('Redis retry', { attempt: times, delayMs: delay });
    return delay;
  },
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
  enableOfflineQueue: true,
  
  // ============ TIMEOUTS ============
  connectTimeout: 10000,
  commandTimeout: 5000,
  
  // ============ RECONNECT ============
  reconnectOnError: (err) => {
    const targetError = 'READONLY';
    if (err.message.includes(targetError)) {
      logger.error('Redis READONLY, attempting reconnect', { error: err.message });
      return true;
    }
    return false;
  },
  
  // ============ LOGGING ============
  lazyConnect: false,
  
  // ============ POOL ============
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
});

// ============ EVENT HANDLERS ============
redis.on('error', (err) => {
  logger.error('Redis error', { error: err.message, code: err.code });
});

redis.on('connect', () => {
  logger.info('Redis connected', { host: process.env.REDIS_HOST || 'localhost' });
});

redis.on('ready', () => {
  logger.info('Redis ready');
});

redis.on('reconnecting', () => {
  logger.warn('Redis reconnecting...');
});

redis.on('close', () => {
  logger.warn('Redis connection closed');
});

redis.on('end', () => {
  logger.info('Redis connection ended');
});

// ============ HEALTH CHECK ============
redis.ping()
  .then(() => logger.info('Redis ping successful'))
  .catch(err => logger.error('Redis ping failed', { error: err.message }));

module.exports = redis;
```

**Validação:**
- [ ] Arquivo `src/redis.js` criado
- [ ] Pode ser importado
- [ ] Se Redis está rodando localmente, conecta automaticamente

---

### TASK 0.7: Criar Health Endpoint (15 min)
**Status:** ⬜ Não iniciado

Adicionar ao seu `src/index.js` (ou criar `src/health.js`):

```javascript
const logger = require('./logger');
const redis = require('./redis');

// ============ HEALTH ENDPOINT ============
function setupHealthEndpoints(app) {
  
  // GET /health - Status básico
  app.get('/health', (req, res) => {
    try {
      const health = {
        status: 'UP',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: process.env.NODE_ENV,
        memory: {
          heapUsed: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
          heapTotal: Math.round(process.memoryUsage().heapTotal / 1024 / 1024),
          external: Math.round(process.memoryUsage().external / 1024 / 1024),
          rss: Math.round(process.memoryUsage().rss / 1024 / 1024)
        },
        cpu: process.cpuUsage(),
        pid: process.pid
      };
      
      res.status(200).json(health);
      logger.debug('Health check', health);
      
    } catch (error) {
      logger.error('Health check failed', { error: error.message });
      res.status(503).json({
        status: 'DOWN',
        error: error.message,
        timestamp: new Date().toISOString()
      });
    }
  });
  
  // GET /ready - Readiness probe
  app.get('/ready', async (req, res) => {
    try {
      const checks = {};
      
      // Check Redis
      try {
        await redis.ping();
        checks.redis = { status: 'OK' };
      } catch (error) {
        checks.redis = { status: 'ERROR', error: error.message };
      }
      
      // Check Memory
      const memUsage = process.memoryUsage().heapUsed / 1024 / 1024;
      checks.memory = {
        status: memUsage < 1000 ? 'OK' : 'WARNING',
        heapUsedMB: Math.round(memUsage)
      };
      
      // Check Uptime
      checks.uptime = {
        status: process.uptime() > 10 ? 'OK' : 'INITIALIZING',
        seconds: Math.round(process.uptime())
      };
      
      const allOk = Object.values(checks).every(c => c.status === 'OK' || c.status === 'INITIALIZING');
      
      res.status(allOk ? 200 : 503).json({
        ready: allOk,
        timestamp: new Date().toISOString(),
        checks
      });
      
      if (!allOk) {
        logger.warn('Readiness check failed', checks);
      }
      
    } catch (error) {
      logger.error('Readiness check error', { error: error.message });
      res.status(503).json({
        ready: false,
        error: error.message
      });
    }
  });
  
  // GET /metrics - Prometheus-like metrics
  app.get('/metrics', (req, res) => {
    const metrics = {
      timestamp: new Date().toISOString(),
      uptime_seconds: process.uptime(),
      memory_heap_used_bytes: process.memoryUsage().heapUsed,
      memory_heap_total_bytes: process.memoryUsage().heapTotal,
      memory_external_bytes: process.memoryUsage().external,
      memory_rss_bytes: process.memoryUsage().rss,
      cpu_user_ms: process.cpuUsage().user,
      cpu_system_ms: process.cpuUsage().system,
      process_id: process.pid,
      environment: process.env.NODE_ENV
    };
    
    res.status(200).json(metrics);
  });
}

module.exports = { setupHealthEndpoints };
```

No seu `src/index.js`, use assim:

```javascript
const express = require('express');
const { setupHealthEndpoints } = require('./health');

const app = express();

// ... suas outras configs ...

// Setup health endpoints
setupHealthEndpoints(app);

// ... resto do seu código ...
```

**Validação:**
- [ ] Endpoints adicionados ao seu app
- [ ] Sem erros de sintaxe
- [ ] Pode testar: `curl http://localhost:18789/health`

---

### TASK 0.8: Criar Docker Healthcheck (10 min)
**Status:** ⬜ Não iniciado

Adicionar ao seu `docker-compose.yml`:

```yaml
version: '3.9'

services:
  openclaw-gateway:
    build: .
    container_name: openclaw-gateway
    ports:
      - "18789:18789"
    
    environment:
      NODE_ENV: production
      PORT: 18789
      LOG_LEVEL: info
    
    volumes:
      - /home/lucas/.openclaw:/home/node/.openclaw
      - ./logs:/home/node/logs
    
    # ============ HEALTHCHECK ============
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:18789/health || exit 1"]
      interval: 30s          # Check a cada 30 segundos
      timeout: 10s           # Falha se demorar >10s
      retries: 3             # 3 falhas = unhealthy
      start_period: 40s      # Grace period para startup
    
    # ============ RESTART POLICY ============
    restart: unless-stopped
    
    # ============ RESOURCE LIMITS ============
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
    
    # ============ LOGGING ============
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    
    networks:
      - openclaw-network

  redis:
    image: redis:7-alpine
    container_name: openclaw-redis
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3
    restart: unless-stopped
    networks:
      - openclaw-network

networks:
  openclaw-network:
    driver: bridge
```

**Validação:**
- [ ] Arquivo `docker-compose.yml` atualizado
- [ ] Sintaxe YAML válida: `docker-compose config`
- [ ] Sem erros ao fazer build

---

### TASK 0.9: Criar .env.example (5 min)
**Status:** ⬜ Não iniciado

Criar `.env.example` na raiz:

```bash
# ============ ENVIRONMENT ============
NODE_ENV=production
PORT=18789
LOG_LEVEL=info

# ============ TELEGRAM ============
TELEGRAM_BOT_TOKEN=your_telegram_token_here
TELEGRAM_CHAT_ID=your_chat_id_here

# ============ ANTHROPIC (Claude) ============
ANTHROPIC_API_KEY=sk-ant-v7-xxxxx

# ============ OPENAI ============
OPENAI_API_KEY=sk-xxxxx

# ============ DATABASE ============
DATABASE_URL=sqlite:///home/node/.openclaw/state.db

# ============ REDIS ============
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# ============ MONITORING ============
SENTRY_DSN=https://key@sentry.io/projectid
GRAFANA_URL=http://localhost:3000
PROMETHEUS_URL=http://localhost:9090

# ============ BACKUP ============
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=us-east-1
BACKUP_BUCKET=your-bucket

# ============ LOGGING ============
LOG_FILE_MAX_SIZE=20m
LOG_FILE_MAX_DAYS=14
```

**Validação:**
- [ ] Arquivo `.env.example` criado
- [ ] Adicionar à `.gitignore`: `.env` (NÃO commitar senhas!)
- [ ] Copiar para `.env` e preencher com valores reais

---

### TASK 0.10: Primeiro Start com PM2 (15 min)
**Status:** ⬜ Não iniciado

```bash
# 1. Validar config
pm2 validate ecosystem.config.js
# Saída esperada: "Config file is valid"

# 2. Starta a aplicação
pm2 start ecosystem.config.js

# 3. Ver status
pm2 status
# Deve mostrar "khronos" online

# 4. Ver logs
pm2 logs khronos
# Deve mostrar logs normais

# 5. Testar health endpoint
curl http://localhost:18789/health
# Deve retornar JSON com status UP

# 6. Salvar configuração
pm2 save

# 7. Ativar auto-start ao reboot
pm2 startup
# Seguir instruções na tela

# 8. Verificar monitoramento
pm2 monit
```

**Validação:**
- [ ] `pm2 list` mostra "khronos" como "online"
- [ ] `curl http://localhost:18789/health` retorna status UP
- [ ] `pm2 logs` mostra logs sem erros críticos
- [ ] Healthcheck Docker passa

---

## ✅ CHECKLIST SPRINT 0

- [ ] PM2 instalado globalmente
- [ ] Dependências NPM instaladas
- [ ] Pastas criadas (src, logs, config, tests)
- [ ] ecosystem.config.js criado
- [ ] src/logger.js criado e funcionando
- [ ] src/redis.js criado e conectando
- [ ] Health endpoints funcionando
- [ ] Docker healthcheck configurado
- [ ] .env.example criado
- [ ] App startando com PM2 sem erros
- [ ] Health endpoint retorna status UP
- [ ] Logs sendo escritos em src/logs/

---

## 📊 ESTIMATIVA DE TEMPO

| Task | Tempo | Status |
|------|-------|--------|
| 0.1 - PM2 | 10 min | ⬜ |
| 0.2 - NPM Deps | 15 min | ⬜ |
| 0.3 - Folders | 5 min | ⬜ |
| 0.4 - ecosystem.config | 10 min | ⬜ |
| 0.5 - Logger | 15 min | ⬜ |
| 0.6 - Redis | 10 min | ⬜ |
| 0.7 - Health | 15 min | ⬜ |
| 0.8 - Docker | 10 min | ⬜ |
| 0.9 - .env | 5 min | ⬜ |
| 0.10 - Start | 15 min | ⬜ |
| **TOTAL** | **115 min** | ⬜ |

---

## 🎯 O QUE VOCÊ TEM AGORA

✅ Bot com auto-restart automático (PM2)
✅ Health endpoints monitoráveis
✅ Logging estruturado
✅ Redis conectado e pronto
✅ Docker com healthcheck
✅ Pronto para próxima sprint

---

## 🚀 PRÓXIMA SPRINT

Depois de completar essa sprint, vá para:
**→ SPRINT_1_RESILIENCIA.md**

Lá você vai implementar:
- Circuit Breaker (Opossum)
- Rate Limiting (Bottleneck)
- Graceful Shutdown
- WebSocket Reconnect
