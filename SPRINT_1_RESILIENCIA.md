# 🛡️ SPRINT 1: RESILIÊNCIA & PROTEÇÃO (6H)

> **Objetivo:** Deixar o bot blindado contra falhas em cascata, rate limit e queries longas
> **Duração:** 6 horas (3 tasks de 2h cada)
> **Pré-requisito:** Completar SPRINT 0
> **Seu TDAH:** Cada task é independente - faça UM por dia se quiser

---

## 📋 TAREFAS SPRINT 1

---

## TASK 1.1: Circuit Breaker com Opossum (2H)

### 🎯 O Problema
Uma API externa (Anthropic, Telegram, OpenAI) cai, e toda a sua aplicação trava esperando resposta.

### 💡 A Solução
Circuit Breaker detecta falhas rapidamente e **falha rápido** (fast fail), sem derrubar o servidor.

### 📝 Implementação

Criar `src/circuit-breaker.js`:

```javascript
const CircuitBreaker = require('opossum');
const logger = require('./logger');

// ============ CIRCUIT BREAKER CONFIG ============
const breakers = {};

function createBreaker(name, fn, options = {}) {
  const defaultOptions = {
    timeout: 10000,              // 10s timeout
    errorThresholdPercentage: 50, // 50% fail = open
    resetTimeout: 30000,         // Tenta recoverar após 30s
    name: name,
    healthCheckInterval: 5000,   // Health check a cada 5s
    healthCheck: async () => {
      logger.debug(`Health check for ${name}`);
      return true;
    },
    ...options
  };

  const breaker = new CircuitBreaker(fn, defaultOptions);

  // ============ FALLBACK ============
  if (options.fallback) {
    breaker.fallback(options.fallback);
  }

  // ============ EVENT HANDLERS ============
  breaker.on('success', (result) => {
    logger.debug(`Circuit ${name}: SUCCESS`, { duration: result.duration });
  });

  breaker.on('failure', (error) => {
    logger.warn(`Circuit ${name}: FAILURE`, {
      error: error.message,
      state: breaker.getState()
    });
  });

  breaker.on('timeout', () => {
    logger.error(`Circuit ${name}: TIMEOUT`);
  });

  breaker.on('open', () => {
    logger.error(`🚨 Circuit ${name}: OPEN (failing fast now)`, {
      failureRate: breaker.stats().failureRate
    });
  });

  breaker.on('halfOpen', () => {
    logger.warn(`Circuit ${name}: HALF-OPEN (testing recovery)`);
  });

  breaker.on('close', () => {
    logger.info(`✅ Circuit ${name}: CLOSED (recovered)`, {
      stats: breaker.stats()
    });
  });

  breakers[name] = breaker;
  return breaker;
}

// ============ ANTHROPIC API CIRCUIT BREAKER ============
const anthropicBreaker = createBreaker(
  'anthropic-api',
  async (message, options = {}) => {
    // Aqui vai sua chamada à API
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': process.env.ANTHROPIC_API_KEY,
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        model: options.model || 'claude-3-5-sonnet-20241022',
        max_tokens: options.max_tokens || 1024,
        messages: [{ role: 'user', content: message }]
      })
    });

    if (!response.ok) {
      throw new Error(`Anthropic API error: ${response.status}`);
    }

    return await response.json();
  },
  {
    timeout: 15000,
    fallback: () => ({
      content: [{
        type: 'text',
        text: '❌ IA indisponível agora. Tente novamente em alguns segundos.'
      }],
      usage: { input_tokens: 0, output_tokens: 0 }
    })
  }
);

// ============ TELEGRAM API CIRCUIT BREAKER ============
const telegramBreaker = createBreaker(
  'telegram-api',
  async (chatId, text, options = {}) => {
    const token = process.env.TELEGRAM_BOT_TOKEN;
    const response = await fetch(`https://api.telegram.org/bot${token}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: chatId,
        text: text,
        parse_mode: options.parseMode || 'Markdown',
        reply_to_message_id: options.replyTo
      })
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(`Telegram error: ${error.description}`);
    }

    return await response.json();
  },
  {
    timeout: 5000,
    fallback: () => ({
      ok: false,
      error_code: 503,
      description: 'Telegram API unavailable'
    })
  }
);

// ============ OPENAI API CIRCUIT BREAKER ============
const openaiBreaker = createBreaker(
  'openai-api',
  async (prompt, options = {}) => {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: options.model || 'gpt-4',
        messages: [{ role: 'user', content: prompt }],
        max_tokens: options.max_tokens || 1024
      })
    });

    if (!response.ok) {
      throw new Error(`OpenAI error: ${response.status}`);
    }

    return await response.json();
  },
  {
    timeout: 10000,
    fallback: () => ({
      error: 'OpenAI service unavailable',
      message: 'Please try again later'
    })
  }
);

// ============ DATABASE CIRCUIT BREAKER ============
const dbBreaker = createBreaker(
  'database',
  async (query, params = []) => {
    // Seu código de DB aqui
    return await db.execute(query, params);
  },
  {
    timeout: 5000,
    resetTimeout: 15000,
    errorThresholdPercentage: 30,
    fallback: () => {
      throw new Error('Database temporarily unavailable');
    }
  }
);

// ============ PUBLIC FUNCTIONS ============
async function callAnthropicSafely(message, options = {}) {
  try {
    const result = await anthropicBreaker.fire(message, options);
    logger.info('Anthropic call successful');
    return result;
  } catch (error) {
    logger.error('Anthropic call failed', {
      error: error.message,
      state: anthropicBreaker.getState()
    });
    throw error;
  }
}

async function callTelegramSafely(chatId, text, options = {}) {
  try {
    const result = await telegramBreaker.fire(chatId, text, options);
    logger.info('Telegram call successful');
    return result;
  } catch (error) {
    logger.error('Telegram call failed', {
      error: error.message,
      state: telegramBreaker.getState()
    });
    throw error;
  }
}

async function callOpenAISafely(prompt, options = {}) {
  try {
    const result = await openaiBreaker.fire(prompt, options);
    logger.info('OpenAI call successful');
    return result;
  } catch (error) {
    logger.error('OpenAI call failed', {
      error: error.message,
      state: openaiBreaker.getState()
    });
    throw error;
  }
}

// ============ MONITORING ============
function getCircuitBreakerStatus() {
  const status = {};
  for (const [name, breaker] of Object.entries(breakers)) {
    status[name] = {
      state: breaker.getState(),
      stats: breaker.stats()
    };
  }
  return status;
}

// ============ EXPORTS ============
module.exports = {
  createBreaker,
  anthropicBreaker,
  telegramBreaker,
  openaiBreaker,
  dbBreaker,
  callAnthropicSafely,
  callTelegramSafely,
  callOpenAISafely,
  getCircuitBreakerStatus,
  breakers
};
```

### 🧪 Testar

Adicionar ao seu `src/index.js`:

```javascript
const express = require('express');
const { getCircuitBreakerStatus } = require('./circuit-breaker');

const app = express();

// ============ CIRCUIT BREAKER STATUS ENDPOINT ============
app.get('/breakers/status', (req, res) => {
  const status = getCircuitBreakerStatus();
  res.json(status);
});

// ============ USAR NO SEU HANDLER ============
app.post('/chat', async (req, res) => {
  const { message } = req.body;
  
  try {
    // Chamar com circuit breaker (ao invés de direto)
    const response = await callAnthropicSafely(message);
    res.json(response);
  } catch (error) {
    res.status(503).json({
      error: 'Service temporarily unavailable',
      message: error.message
    });
  }
});
```

### ✅ Validação

```bash
# 1. Verificar que não quebra
curl http://localhost:18789/breakers/status
# Deve mostrar todos os breakers com estado "closed"

# 2. Simular falha (parar a API)
# O circuit breaker detecta e muda para "open"

# 3. Recuperação automática
# Após 30s, tenta novamente (half-open state)
```

---

## TASK 1.2: Rate Limiting com Bottleneck (2H)

### 🎯 O Problema
Usuários spammam o bot, Telegram te bane, muita carga desnecessária.

### 💡 A Solução
Rate limiter controla fluxo de requisições por usuário.

### 📝 Implementação

Criar `src/rate-limiter.js`:

```javascript
const Bottleneck = require('bottleneck');
const logger = require('./logger');
const redis = require('./redis');

// ============ TELEGRAM RATE LIMITER ============
// Telegram limit: 30 requests/second (per user ~1 req/sec)
const telegramLimiter = new Bottleneck({
  // Executa 1 por vez
  maxConcurrent: 1,
  
  // 35ms = ~28-29 req/sec
  minTime: 35,
  
  // Agrupa por userId
  groupKey: 'userId',
  
  // Retry se pronto
  retryIfReady: true,
  
  // Usar Redis para persistência (cluster-safe)
  datastore: 'redis',
  clientOptions: {
    host: process.env.REDIS_HOST || 'localhost',
    port: process.env.REDIS_PORT || 6379,
    password: process.env.REDIS_PASSWORD
  }
});

// ============ GLOBAL LIMITER ============
// Máximo 100 requests simultâneos em tudo
const globalLimiter = new Bottleneck({
  maxConcurrent: 100,
  minTime: 10
});

// ============ API-SPECIFIC LIMITERS ============
const anthropicLimiter = new Bottleneck({
  maxConcurrent: 3,        // Max 3 calls simultâneos
  minTime: 500,            // Min 500ms entre calls
  maxQueued: 50,           // Max 50 na fila
  groupKey: 'userId'
});

const whisperLimiter = new Bottleneck({
  maxConcurrent: 2,        // Max 2 transcriptions
  minTime: 1000,           // Min 1s entre calls
  maxQueued: 10
});

// ============ EVENT HANDLERS ============
telegramLimiter.on('error', (error) => {
  logger.error('Telegram limiter error', { error: error.message });
});

telegramLimiter.on('queued', (info) => {
  logger.debug('Telegram request queued', {
    priority: info.priority,
    queued: info.queued
  });
});

telegramLimiter.on('dropped', (info) => {
  logger.warn('Telegram request dropped (max queue exceeded)', {
    jobId: info.jobId
  });
});

// ============ RATE LIMIT MIDDLEWARE ============
function createRateLimitMiddleware(limiter, maxQueueSize = 50) {
  return async (req, res, next) => {
    try {
      const userId = req.user?.id || req.ip;
      const remaining = limiter.counts().queued;
      
      // Rejeitar se fila muito grande
      if (remaining > maxQueueSize) {
        logger.warn('Rate limit exceeded', {
          userId,
          queued: remaining,
          maxQueue: maxQueueSize
        });
        return res.status(429).json({
          error: 'Too many requests',
          retryAfter: 60
        });
      }
      
      // Agendar execução
      await limiter.schedule({ id: userId }, async () => {
        next();
      });
      
    } catch (error) {
      logger.error('Rate limit middleware error', { error });
      res.status(500).json({ error: 'Internal server error' });
    }
  };
}

// ============ SCHEDULE SAFE FUNCTION ============
async function scheduleTelegramMessage(userId, fn, priority = 0) {
  try {
    return await telegramLimiter.schedule(
      { id: userId, priority },
      fn
    );
  } catch (error) {
    logger.error('Failed to schedule telegram message', {
      userId,
      error: error.message
    });
    throw error;
  }
}

async function scheduleAnthropicCall(userId, fn, priority = 0) {
  try {
    return await anthropicLimiter.schedule(
      { id: userId, priority },
      fn
    );
  } catch (error) {
    logger.error('Failed to schedule anthropic call', {
      userId,
      error: error.message
    });
    throw error;
  }
}

// ============ MONITORING ============
function getLimiterStats() {
  return {
    telegram: {
      executing: telegramLimiter.counts().executing,
      queued: telegramLimiter.counts().queued
    },
    global: {
      executing: globalLimiter.counts().executing,
      queued: globalLimiter.counts().queued
    },
    anthropic: {
      executing: anthropicLimiter.counts().executing,
      queued: anthropicLimiter.counts().queued
    }
  };
}

// ============ EXPORTS ============
module.exports = {
  telegramLimiter,
  globalLimiter,
  anthropicLimiter,
  whisperLimiter,
  createRateLimitMiddleware,
  scheduleTelegramMessage,
  scheduleAnthropicCall,
  getLimiterStats
};
```

### 🧪 Testar

Adicionar ao seu `src/index.js`:

```javascript
const { createRateLimitMiddleware, getLimiterStats } = require('./rate-limiter');

// ============ APLICAR RATE LIMIT ============
app.post('/messages', createRateLimitMiddleware(telegramLimiter), async (req, res) => {
  // Seu handler aqui
});

// ============ MONITORAR STATS ============
app.get('/limiter/stats', (req, res) => {
  res.json(getLimiterStats());
});
```

### ✅ Validação

```bash
# Ver stats em tempo real
while true; do curl http://localhost:18789/limiter/stats | jq; sleep 1; done
```

---

## TASK 1.3: Graceful Shutdown (2H)

### 🎯 O Problema
Quando o bot morre, interrompe operações em andamento, perde dados, conexões abertas.

### 💡 A Solução
Graceful shutdown fecha tudo organizadamente antes de morrer.

### 📝 Implementação

Criar `src/graceful-shutdown.js`:

```javascript
const logger = require('./logger');

let isShuttingDown = false;
const activeConnections = new Set();
const activeJobs = new Set();

// ============ TRACK CONNECTIONS ============
function trackConnection(socket) {
  activeConnections.add(socket);
  socket.on('close', () => activeConnections.delete(socket));
}

function closeAllConnections() {
  logger.info('Closing active connections', { count: activeConnections.size });
  activeConnections.forEach(socket => {
    socket.destroy();
  });
  activeConnections.clear();
}

// ============ TRACK JOBS ============
function trackJob(jobId, job) {
  activeJobs.add({ id: jobId, job, startTime: Date.now() });
}

function jobCompleted(jobId) {
  activeJobs.forEach(j => {
    if (j.id === jobId) activeJobs.delete(j);
  });
}

async function waitForJobs(maxWaitMs = 5000) {
  const startTime = Date.now();
  
  while (activeJobs.size > 0) {
    if (Date.now() - startTime > maxWaitMs) {
      logger.warn(`Max wait time exceeded, killing ${activeJobs.size} jobs`);
      activeJobs.clear();
      break;
    }
    
    await new Promise(r => setTimeout(r, 100));
  }
  
  logger.info('All jobs completed');
}

// ============ GRACEFUL SHUTDOWN SEQUENCE ============
async function gracefulShutdown(signal, server, redis, bot, queue) {
  if (isShuttingDown) {
    logger.warn('Shutdown already in progress, ignoring signal');
    return;
  }
  
  isShuttingDown = true;
  logger.warn(`\n\n${'='.repeat(50)}`);
  logger.warn(`🛑 ${signal} RECEIVED - GRACEFUL SHUTDOWN`);
  logger.warn(`${'='.repeat(50)}\n`);
  
  const shutdownTimeout = setTimeout(() => {
    logger.error('🚨 GRACEFUL SHUTDOWN TIMEOUT - FORCING EXIT');
    process.exit(1);
  }, 30000); // 30 segundo timeout

  try {
    // ============ STEP 1: STOP ACCEPTING NEW REQUESTS ============
    logger.info('Step 1/7: Stopping HTTP server');
    if (server) {
      server.close(() => {
        logger.info('HTTP server closed');
      });
    }

    // ============ STEP 2: STOP BOT ============
    logger.info('Step 2/7: Stopping Telegram bot');
    if (bot && bot.stop) {
      await bot.stop(signal);
      logger.info('Telegram bot stopped');
    }

    // ============ STEP 3: WAIT FOR ACTIVE JOBS ============
    logger.info(`Step 3/7: Waiting for ${activeJobs.size} active jobs`);
    await waitForJobs(10000);
    logger.info('All jobs completed');

    // ============ STEP 4: CLOSE QUEUE ============
    logger.info('Step 4/7: Closing message queue');
    if (queue) {
      await queue.close();
      logger.info('Queue closed');
    }

    // ============ STEP 5: CLOSE DATABASE ============
    logger.info('Step 5/7: Closing database connections');
    // Se usar DB: await db.close();
    logger.info('Database connections closed');

    // ============ STEP 6: CLOSE REDIS ============
    logger.info('Step 6/7: Closing Redis');
    if (redis) {
      await redis.quit();
      logger.info('Redis connection closed');
    }

    // ============ STEP 7: CLOSE SOCKET CONNECTIONS ============
    logger.info('Step 7/7: Closing socket connections');
    closeAllConnections();
    logger.info('Socket connections closed');

    clearTimeout(shutdownTimeout);
    logger.warn('\n✅ GRACEFUL SHUTDOWN COMPLETED\n');
    process.exit(0);

  } catch (error) {
    clearTimeout(shutdownTimeout);
    logger.error('❌ ERROR DURING GRACEFUL SHUTDOWN', { error });
    process.exit(1);
  }
}

// ============ SETUP SIGNAL HANDLERS ============
function setupGracefulShutdown(server, redis, bot, queue) {
  process.on('SIGTERM', () => gracefulShutdown('SIGTERM', server, redis, bot, queue));
  process.on('SIGINT', () => gracefulShutdown('SIGINT', server, redis, bot, queue));

  // Handle uncaught exceptions
  process.on('uncaughtException', (error) => {
    logger.error('🚨 UNCAUGHT EXCEPTION', { error });
    gracefulShutdown('UNCAUGHT_EXCEPTION', server, redis, bot, queue);
  });

  // Handle unhandled rejections
  process.on('unhandledRejection', (reason, promise) => {
    logger.error('🚨 UNHANDLED REJECTION', { reason, promise });
    gracefulShutdown('UNHANDLED_REJECTION', server, redis, bot, queue);
  });
}

// ============ EXPORTS ============
module.exports = {
  gracefulShutdown,
  setupGracefulShutdown,
  trackConnection,
  closeAllConnections,
  trackJob,
  jobCompleted,
  waitForJobs
};
```

### 🧪 Testar

No seu `src/index.js`:

```javascript
const { setupGracefulShutdown } = require('./graceful-shutdown');

const app = express();
const server = app.listen(18789);

// Setup graceful shutdown
setupGracefulShutdown(server, redis, bot, messageQueue);

// Logar quando servidor escuta
server.on('listening', () => {
  logger.info('Server listening on port 18789');
});
```

Para testar:

```bash
# Terminal 1: Rodar o app
pm2 start ecosystem.config.js

# Terminal 2: Enviar SIGTERM
pm2 stop khronos
# Deve ver a sequência de shutdown completa

# Ou forçar SIGINT
pkill -SIGINT node
# Ctrl+C também funciona
```

### ✅ Validação

- [ ] Ao parar o bot, vê "GRACEFUL SHUTDOWN" nos logs
- [ ] Sem erros de conexão aberta
- [ ] Jobs são aguardados
- [ ] Database/Redis são fechados corretamente
- [ ] Process sai com código 0

---

## ✅ CHECKLIST SPRINT 1

- [ ] Circuit Breaker implementado (Opossum)
- [ ] Todos os breakers testados (/breakers/status retorna tudo "closed")
- [ ] Rate Limiter implementado (Bottleneck)
- [ ] Limiter stats monitoráveis (/limiter/stats)
- [ ] Graceful Shutdown implementado
- [ ] SIGTERM/SIGINT testados manualmente
- [ ] Sem erros ao parar o serviço
- [ ] Logs mostram sequência completa de shutdown

---

## 📊 TEMPO REAL

- Task 1.1 (Circuit Breaker): ~2h
- Task 1.2 (Rate Limiter): ~2h
- Task 1.3 (Graceful Shutdown): ~2h
- **TOTAL: 6 horas**

---

## 🎯 O QUE VOCÊ TEM AGORA

✅ Bot protegido contra cascata de falhas (circuit breaker)
✅ Bot protegido contra spam (rate limiting)
✅ Bot fecha elegantemente sem perder dados (graceful shutdown)
✅ Pronto para SPRINT 2 (Backup & Monitoring)

---

## 🚀 PRÓXIMA SPRINT

**→ SPRINT_2_BACKUP_E_MONITORING.md**

Lá você implementa:
- Backup automático (Litestream)
- Prometheus metrics
- Winston logging avançado
- Alertas via Telegram
