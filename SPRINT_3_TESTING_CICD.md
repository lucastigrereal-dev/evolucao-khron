# ✅ SPRINT 3: TESTING & CI/CD (6H)

> **Objetivo:** Código confiável + deploys automáticos
> **Duração:** 6 horas (3 tasks de 2h cada)
> **Pré-requisito:** SPRINT 0 + SPRINT 1 + SPRINT 2

---

## TASK 3.1: Jest Testing Setup (2H)

### 📝 Implementação

Criar `tests/health.test.js`:

```javascript
const request = require('supertest');
const app = require('../src/index');
const redis = require('../src/redis');

describe('Health Endpoints', () => {
  afterAll(async () => {
    await redis.quit();
  });

  describe('GET /health', () => {
    it('should return status UP', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.body.status).toBe('UP');
      expect(response.body.uptime).toBeGreaterThan(0);
      expect(response.body.memory).toBeDefined();
    });

    it('should have required fields', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.body).toHaveProperty('status');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('uptime');
      expect(response.body).toHaveProperty('memory');
      expect(response.body).toHaveProperty('pid');
    });

    it('should return valid memory stats', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      const { memory } = response.body;
      expect(memory.heapUsed).toBeGreaterThan(0);
      expect(memory.heapTotal).toBeGreaterThan(memory.heapUsed);
    });
  });

  describe('GET /ready', () => {
    it('should return ready status', async () => {
      const response = await request(app)
        .get('/ready')
        .expect(200);

      expect(response.body.ready).toBe(true);
      expect(response.body.checks).toBeDefined();
    });

    it('should check Redis', async () => {
      const response = await request(app)
        .get('/ready')
        .expect(200);

      expect(response.body.checks.redis).toBeDefined();
      expect(response.body.checks.redis.status).toBe('OK');
    });

    it('should check memory', async () => {
      const response = await request(app)
        .get('/ready')
        .expect(200);

      expect(response.body.checks.memory).toBeDefined();
      expect(['OK', 'WARNING']).toContain(response.body.checks.memory.status);
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

Criar `tests/circuit-breaker.test.js`:

```javascript
const { createBreaker } = require('../src/circuit-breaker');

describe('Circuit Breaker', () => {
  it('should execute function successfully', async () => {
    const breaker = createBreaker('test', async () => {
      return { success: true };
    });

    const result = await breaker.fire();
    expect(result.success).toBe(true);
    expect(breaker.getState()).toBe('closed');
  });

  it('should fail fast after threshold', async () => {
    let callCount = 0;
    const breaker = createBreaker(
      'test-fail',
      async () => {
        callCount++;
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
    for (let i = 0; i < 3; i++) {
      try {
        await breaker.fire();
      } catch (e) {
        // Expected
      }
    }

    // Wait for state change
    await new Promise(r => setTimeout(r, 100));

    // Should be open now
    expect(breaker.getState()).toBe('open');

    // Next call should use fallback
    const result = await breaker.fire();
    expect(result.fallback).toBe(true);
  });

  it('should recover after reset timeout', async (done) => {
    const breaker = createBreaker(
      'test-recover',
      async () => {
        throw new Error('Fail');
      },
      {
        resetTimeout: 500,
        fallback: () => ({ fallback: true })
      }
    );

    // Trigger failure
    try {
      await breaker.fire();
    } catch (e) {
      // Expected
    }

    // Wait for recovery
    setTimeout(() => {
      expect(breaker.getState()).toMatch(/open|half-open/);
      done();
    }, 600);
  });
});
```

Criar `tests/rate-limiter.test.js`:

```javascript
const { telegramLimiter } = require('../src/rate-limiter');

describe('Rate Limiter', () => {
  it('should queue requests', async () => {
    const results = [];
    
    const promises = Array(5).fill(null).map((_, i) => 
      telegramLimiter.schedule({ id: 'user-1' }, async () => {
        results.push(i);
        return i;
      })
    );

    await Promise.all(promises);
    expect(results).toHaveLength(5);
  });

  it('should respect minTime', async () => {
    const times = [];
    
    const promises = Array(3).fill(null).map((_, i) => 
      telegramLimiter.schedule({ id: 'user-2' }, async () => {
        times.push(Date.now());
      })
    );

    await Promise.all(promises);
    
    // Check time gaps (should be at least minTime apart)
    for (let i = 1; i < times.length; i++) {
      const gap = times[i] - times[i-1];
      expect(gap).toBeGreaterThanOrEqual(30); // minTime is 35ms
    }
  });
});
```

Atualizar `package.json`:

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

### 🧪 Testar

```bash
# Rodar testes
npm test

# Watch mode
npm run test:watch

# Coverage
npm run test:coverage
```

---

## TASK 3.2: GitHub Actions CI/CD (2H)

Criar `.github/workflows/test.yml`:

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
        name: codecov-umbrella

  security:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Run Snyk
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high

  build:
    runs-on: ubuntu-latest
    needs: [test, security]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Build
      run: npm run build --if-present
    
    - name: Docker build test
      run: docker build -t khronos:test .
```

Criar `.github/workflows/deploy.yml`:

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
    
    - name: Deploy to server
      uses: appleboy/ssh-action@master
      with:
        host: ${{ secrets.DEPLOY_HOST }}
        username: ${{ secrets.DEPLOY_USER }}
        key: ${{ secrets.DEPLOY_KEY }}
        script: |
          cd ~/khronos
          git pull origin main
          npm install
          pm2 stop khronos
          npm run build
          pm2 start ecosystem.config.js
          pm2 save
```

---

## TASK 3.3: Code Quality & Documentation (2H)

Criar `CONTRIBUTING.md`:

```markdown
# Contribuindo para Khronos

## Setup Local

```bash
npm install
npm run dev
```

## Testing

```bash
npm test              # Rodar testes
npm run test:watch   # Watch mode
npm run test:coverage # Com coverage
```

## Code Standards

- ESLint config: `.eslintrc.js`
- Min coverage: 70%
- No console.log (usar logger)
- Async/await preferred

## Commit Messages

```
type(scope): description

[optional body]
[optional footer]
```

Types: feat, fix, docs, style, refactor, perf, test, chore

## PR Process

1. Fork repository
2. Create feature branch: `git checkout -b feat/my-feature`
3. Commit: `git commit -am 'feat: add my feature'`
4. Push: `git push origin feat/my-feature`
5. Create Pull Request
6. Wait for CI/CD to pass
7. Request review

## Code Review

- All PRs require review before merge
- CI/CD must pass
- Coverage must stay >= 70%
- No security issues (Snyk)
```

Criar `.eslintrc.js`:

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

Adicionar ao `package.json`:

```json
{
  "scripts": {
    "lint": "eslint src tests",
    "lint:fix": "eslint src tests --fix",
    "docs": "jsdoc -c jsdoc.json"
  }
}
```

---

## ✅ CHECKLIST SPRINT 3

- [ ] Jest tests criados para health, circuit breaker, rate limiter
- [ ] Coverage >= 70%
- [ ] GitHub Actions workflows criados
- [ ] Tests rodam em CI/CD
- [ ] ESLint configurado
- [ ] CONTRIBUTING.md criado
- [ ] Deploy workflow criado

---

## 🚀 PRÓXIMA SPRINT

**→ SPRINT_4_ESCALABILIDADE.md**

Clustering, load balancing, horizontal scaling!
