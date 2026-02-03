# OpenClaw Fix Script

## Uso Rápido

Para consertar e configurar o OpenClaw com Gateway + Telegram:

```bash
bash scripts/fix_openclaw.sh
```

## O que o script faz

1. ✅ Valida pré-requisitos (docker, docker-compose, .env)
2. ✅ Para containers existentes
3. ✅ Corrige permissões de volume (chmod 700)
4. ✅ Sincroniza tokens do gateway
5. ✅ Inicia containers
6. ✅ Aplica `openclaw doctor --fix`
7. ✅ Valida definição de pronto:
   - Gateway reachable
   - Health sem EACCES
   - UI acessível em http://127.0.0.1:18789/
   - Canal Telegram enabled

## Requisitos

- WSL2 com Ubuntu
- Docker e Docker Compose instalados
- Arquivo `.env` configurado com:
  - `OPENCLAW_CONFIG_DIR`
  - `OPENCLAW_GATEWAY_TOKEN`
  - `TELEGRAM_BOT_TOKEN` (opcional)

## Próximos Passos Após Sucesso

1. Abra a UI: http://127.0.0.1:18789/
2. Cole o token do gateway nas configurações da UI
   - Token está em `.env` como `OPENCLAW_GATEWAY_TOKEN`
3. Para testar Telegram:
   ```bash
   docker compose run --rm openclaw-cli channels list
   ```

## Troubleshooting

Se o script falhar, verifique:

```bash
# Logs do gateway
docker compose logs openclaw-gateway --tail=50

# Status completo
docker compose run --rm openclaw-cli status

# Doctor diagnóstico
docker compose run --rm openclaw-cli doctor
```

## Arquivos Modificados

O script faz backup automático de:
- `docker-compose.yml.bak`
- `/home/node/.openclaw/openclaw.json.bak.*`

## Idempotência

O script é idempotente - você pode executá-lo múltiplas vezes sem problemas.
