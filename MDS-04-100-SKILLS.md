# 🎯 MDS #4: 100 SKILLS SEQUENCIAIS + IMPLEMENTAÇÃO
## 4 Semanas de Build Progressivo (TDAH-Friendly)

**Data:** 30/01/2026 | **Total Horas:** 80-120h | **Resultado:** JARVIS completo

---

## 📊 SEMANA 1: FOUNDATION (15 SKILLS)

### SKILL #1: Instalar Moltbot
**Tempo:** 20 min | **Dependências:** Node.js 22+, npm

```bash
npm install -g @moltbot/cli
moltbot --version  # Deve mostrar v2.x
# ✅ Status: Completo
```

### SKILL #2: Configurar WSL2 (Windows)
**Tempo:** 30 min

```bash
wsl --install Ubuntu-22.04
wsl
sudo apt update && sudo apt upgrade -y
# ✅ Status: Completo
```

### SKILL #3: Inicializar Primeiro Agente
**Tempo:** 15 min

```bash
moltbot agent create --name "clinica-bot"
moltbot agent --message "Olá! Como você se chama?"
# ✅ Status: Completo
```

### SKILL #4: Instalar Ollama (IA Local)
**Tempo:** 15 min

```bash
curl https://ollama.ai/install.sh | sh
ollama pull qwen:7b
ollama serve
# ✅ Status: Completo
```

### SKILL #5: Conectar Telegram
**Tempo:** 20 min

```bash
# 1. Falar com @BotFather
# /start → /newbot → Copiar TOKEN

moltbot channels add telegram \
  --token "123456789:ABCxyz..."
# ✅ Status: Completo
```

### SKILL #6: Conectar WhatsApp (QR Code)
**Tempo:** 30 min

```bash
moltbot channels setup whatsapp
# Scanear QR code com WhatsApp Web
# ✅ Status: Completo
```

### SKILL #7: Configurar Google Calendar
**Tempo:** 25 min

```bash
# 1. Habilitar Google Calendar API
# 2. Criar OAuth credentials (Desktop App)
# 3. Download JSON credentials

moltbot integrations setup google-calendar \
  --credentials ~/Downloads/credentials.json
# ✅ Status: Completo
```

### SKILL #8: Integrar GPT-4 (Optional)
**Tempo:** 10 min

```bash
export OPENAI_API_KEY="sk-..."
moltbot agent --model gpt-4 --message "Qual é 2+2?"
# ✅ Status: Completo
```

### SKILL #9: Configurar Banco de Dados (SQLite)
**Tempo:** 20 min

```sql
sqlite3 ~/.clawd/db/clinica.db << EOF
CREATE TABLE pacientes (
  id INTEGER PRIMARY KEY,
  nome TEXT,
  telefone TEXT UNIQUE,
  email TEXT,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE agendamentos (
  id INTEGER PRIMARY KEY,
  paciente_id INTEGER,
  data_hora TIMESTAMP,
  procedimento TEXT,
  status TEXT DEFAULT 'agendado',
  FOREIGN KEY(paciente_id) REFERENCES pacientes(id)
);
EOF
# ✅ Status: Completo
```

### SKILL #10: Setup Gmail API
**Tempo:** 25 min

```bash
# Similar ao Google Calendar
moltbot integrations setup gmail \
  --credentials ~/Downloads/credentials.json

moltbot agent --message "Resuma meus últimos 5 emails"
# ✅ Status: Completo
```

### SKILL #11: Instalar Dependências Python
**Tempo:** 15 min

```bash
sudo apt-get install python3 python3-pip
pip3 install requests sqlite3 python-dotenv Pillow
# ✅ Status: Completo
```

### SKILL #12: Criar Arquivo .ENV
**Tempo:** 5 min

```bash
cat > ~/.clawd/.env << EOF
OPENAI_API_KEY=sk-...
GMAIL_TOKEN=ya29...
GOOGLE_CALENDAR_ID=primary
CLINIC_NAME=Clínica Estética Premium
CLINIC_PHONE=(11) 99999-9999
EOF
chmod 600 ~/.clawd/.env
# ✅ Status: Completo
```

### SKILL #13: Instalar ngrok (Tunneling)
**Tempo:** 10 min

```bash
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip
unzip ngrok-v3-stable-linux-amd64.zip
sudo mv ngrok /usr/local/bin/
ngrok --version
# ✅ Status: Completo
```

### SKILL #14: Primeira Automação: Briefing Matinal
**Tempo:** 30 min

```bash
cat > ~/.clawd/cron/briefing-matinal.sh << 'EOF'
#!/bin/bash
EVENTOS=$(moltbot calendar list --date today)
EMAILS=$(moltbot email summarize --last 5)
MSG="📅 Bom dia! Resumo do dia:\n\n$EVENTOS\n\n📧 Emails:\n$EMAILS"
moltbot message send --channel telegram --text "$MSG"
EOF

chmod +x ~/.clawd/cron/briefing-matinal.sh
# crontab -e
# 0 8 * * * ~/.clawd/cron/briefing-matinal.sh
# ✅ Status: Completo
```

### SKILL #15: Monitorar Uptime (Daemon)
**Tempo:** 20 min

```bash
sudo cat > /etc/systemd/system/moltbot.service << EOF
[Unit]
Description=Moltbot AI Assistant
After=network.target

[Service]
Type=simple
User=$USER
ExecStart=/usr/local/bin/moltbot gateway --port 18789
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable moltbot
sudo systemctl start moltbot
# ✅ Status: Completo
```

---

## 📋 SEMANA 2: PACIENTES & AGENDAMENTOS (20 SKILLS)

### SKILL #16-18: WhatsApp Advanced (3 skills)
- SKILL #16: Receber mensagens de grupos
- SKILL #17: Enviar imagens/PDFs
- SKILL #18: Webhook para mensagens em tempo real

### SKILL #19-25: Google Calendar (7 skills)
- SKILL #19: Listar disponibilidade
- SKILL #20: Criar eventos automáticos
- SKILL #21: Detectar conflitos
- SKILL #22: Enviar lembretes 24h antes
- SKILL #23: Enviar lembretes 2h antes
- SKILL #24: Atualizar evento (reagendamento)
- SKILL #25: Deletar evento (cancelamento)

### SKILL #26-35: Agendamento Automático (10 skills)
- SKILL #26: Capturar interesse do paciente
- SKILL #27: Perguntar data/hora preferida
- SKILL #28: Validar disponibilidade
- SKILL #29: Confirmar agendamento
- SKILL #30: Enviar comprovante por email
- SKILL #31: Registrar na DB
- SKILL #32: Cancelar agendamento via chat
- SKILL #33: Reagendar automático
- SKILL #34: Notificar clinica (admin)
- SKILL #35: Gerar QR code confirmação

---

## 📋 SEMANA 3: AUTOMAÇÃO (25 SKILLS)

### SKILL #36-45: Follow-ups (10 skills)
- SKILL #36-39: Follow-ups D+1, D+3, D+7, D+15
- SKILL #40: Análise de foto antes/depois
- SKILL #41: Gerar relatório em PDF
- SKILL #42: Se avaliação baixa → Encaminhar médico
- SKILL #43: Se avaliação alta → Oferta desconto
- SKILL #44: Alertas de saúde
- SKILL #45: Integração com prontuário

### SKILL #46-55: Email & CRM (10 skills)
- SKILL #46: Sincronizar leads com Kommo CRM
- SKILL #47: Triage automático de emails
- SKILL #48: Resposta automática para FAQs
- SKILL #49: Sequência de follow-up por email
- SKILL #50: Unsubscribe em massa
- SKILL #51: Gerar templates de email
- SKILL #52: Integração com Todoist
- SKILL #53: Criar tarefas automáticas
- SKILL #54: Atribuir tarefas (equipe)
- SKILL #55: Notificar via Slack (equipe)

### SKILL #56-60: Analytics Básico (5 skills)
- SKILL #56: Contar agendamentos por dia
- SKILL #57: Taxa de conversão
- SKILL #58: Tempo médio resposta
- SKILL #59: Procedimento mais popular
- SKILL #60: Horário mais procurado

---

## 📋 SEMANA 4: ANALYTICS & PREMIUM (40 SKILLS)

### SKILL #61-75: Relatórios (15 skills)
- Relatório diário, semanal, mensal em PDF
- Dashboard web
- Gráficos de receita, agendamentos, retenção
- NPS (satisfaction survey)
- Análise de feedback
- Previsão de faturamento
- Auto-export para Google Sheets
- Alertas se meta abaixo de alvo

### SKILL #76-90: Integrações Premium (15 skills)
- WhatsApp Business API (oficial)
- Integração com Stripe (pagamento)
- PagSeguro, 99Pay
- Automação de invoice/cobrança
- Integração com Asana, Monday.com, Jira, Notion
- Backup automático para Google Drive
- Instagram DM, Facebook Messenger
- Discord (notificações)
- Webhooks para eventos

### SKILL #91-100: IA Avançada (10 skills)
- Análise preditiva de churn
- Lead scoring automático
- Recomendação de procedimento
- Geração de conteúdo (posts)
- Análise de imagem (antes/depois)
- Gerador de landing pages
- Tradução automática
- Análise de sentimento (feedback)
- Previsão de demanda
- Multi-location management

---

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

- [ ] Semana 1: Skills 1-15 (Toda base funcionando 24/7)
- [ ] Semana 2: Skills 16-35 (Agendamentos automáticos)
- [ ] Semana 3: Skills 36-60 (Follow-ups + automação)
- [ ] Semana 4: Skills 61-100 (Analytics + premium)

---

## 🎯 MÉTRICAS ESPERADAS

| Semana | Bot Online | Agendamentos/dia | Automação |
| --- | --- | --- | --- |
| 1 | 99% | 0 (testando) | 0% |
| 2 | 99.5% | 5-8 | 20% |
| 3 | 99.7% | 15-20 | 60% |
| 4 | 99.9% | 25-30 | 80% |

---

## 💡 DICA PARA TDAH

✅ UMA SKILL POR DIA máximo
❌ NÃO fazer 5 skills no mesmo dia
✅ Testar PROFUNDAMENTE antes da próxima
✅ Celebrar cada conclusão

