# 🛠️ MOLTBOT - SKILLS COMPLETAS MAPEADAS

> **Versão:** 2.0 Final  
> **Data:** 30/01/2026  
> **Total de Skills:** 50+  
> **Formato:** Markdown para Notion/Obsidian

---

## 📑 ÍNDICE DE SKILLS

```
CATEGORIA 1: COMUNICAÇÃO & MENSAGENS (10 skills)
CATEGORIA 2: PRODUTIVIDADE & GESTÃO (12 skills)
CATEGORIA 3: AUTOMAÇÃO & AGENDAMENTO (8 skills)
CATEGORIA 4: DESENVOLVIMENTO & CÓDIGO (10 skills)
CATEGORIA 5: IA & ANÁLISE (8 skills)
CATEGORIA 6: INTEGRAÇÃO OBSIDIAN (6 skills)
CATEGORIA 7: REDES SOCIAIS & MARKETING (5 skills)
CATEGORIA 8: CLÍNICA & SAÚDE (8 skills)
```

---

# 📱 CATEGORIA 1: COMUNICAÇÃO & MENSAGENS

## 1.1 telegram-bot

**Descrição:** Integração completa com Telegram para criar bot 24/7

**Funcionalidades:**
- ✅ Recebe e responde mensagens automaticamente
- ✅ Suporta comandos slash (/start, /help, etc)
- ✅ Envia imagens, arquivos e mídia
- ✅ Grupos e canais
- ✅ Inline buttons e keyboards

**Instalação:**
```bash
# Via MoltHub
npx molthub@latest install telegram-bot

# Manual
npm install node-telegram-bot-api
```

**Configuração:**
```json
// moltbot.json
{
  "integrations": {
    "telegram": {
      "botToken": "SEU_TOKEN_AQUI",
      "enabled": true,
      "allowedUsers": ["123456789"],
      "webhook": false
    }
  }
}
```

**Obter Token:**
```
1. Abra Telegram
2. Procure @BotFather
3. Envie: /newbot
4. Escolha nome e username
5. Copie o token fornecido
```

**Comandos Naturais:**
```
"Envie uma mensagem no Telegram para @usuario dizendo..."
"Poste no grupo do Telegram sobre..."
"Configure resposta automática no Telegram para..."
```

**Script de Uso:**
```javascript
// Exemplo de automação
const TelegramBot = require('node-telegram-bot-api');
const bot = new TelegramBot(TOKEN, {polling: true});

bot.onText(/\/status/, (msg) => {
  bot.sendMessage(msg.chat.id, '✅ Sistema operacional!');
});
```

---

## 1.2 whatsapp-bot

**Descrição:** Conecta com WhatsApp via QR code para automação

**Funcionalidades:**
- ✅ Conexão via QR code (como WhatsApp Web)
- ✅ Responde mensagens automaticamente
- ✅ Envia arquivos, imagens, áudios
- ✅ Grupos e listas de transmissão
- ✅ Status online/offline

**Instalação:**
```bash
npx molthub@latest install whatsapp-bot

# Dependências
npm install whatsapp-web.js qrcode-terminal
```

**Configuração:**
```json
{
  "integrations": {
    "whatsapp": {
      "enabled": true,
      "sessionPath": "./whatsapp-session",
      "qrTimeout": 60000,
      "autoRespond": true
    }
  }
}
```

**Primeiro Uso:**
```bash
# Iniciar e escanear QR
moltbot pairing generate whatsapp

# Aparecerá QR code no terminal
# Escaneie com seu WhatsApp (Configurações > Aparelhos conectados)
```

**Comandos Naturais:**
```
"Envie no WhatsApp para [contato]: [mensagem]"
"Responda automaticamente no WhatsApp quando alguém perguntar sobre..."
"Crie grupo no WhatsApp com..."
```

**Script de Automação:**
```javascript
const { Client } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');

const client = new Client();

client.on('qr', qr => {
    qrcode.generate(qr, {small: true});
});

client.on('ready', () => {
    console.log('WhatsApp conectado!');
});

client.on('message', msg => {
    if (msg.body === 'oi') {
        msg.reply('Olá! Como posso ajudar?');
    }
});

client.initialize();
```

---

## 1.3 discord-bot

**Descrição:** Bot Discord para servidores e comunidades

**Funcionalidades:**
- ✅ Comandos slash nativos
- ✅ Mensagens em canais e DMs
- ✅ Embeds ricos com imagens
- ✅ Roles e permissões
- ✅ Voice channels (futuro)

**Instalação:**
```bash
npx molthub@latest install discord-bot
npm install discord.js
```

**Criar Bot Discord:**
```
1. Acesse: https://discord.com/developers/applications
2. Clique "New Application"
3. Dê um nome
4. Vá em "Bot" → "Add Bot"
5. Copie o Token
6. Em "OAuth2" → "URL Generator":
   - Scopes: bot, applications.commands
   - Permissions: Send Messages, Read Messages
7. Acesse URL gerada para adicionar ao servidor
```

**Configuração:**
```json
{
  "integrations": {
    "discord": {
      "token": "SEU_TOKEN",
      "clientId": "SEU_CLIENT_ID",
      "prefix": "!",
      "enabled": true
    }
  }
}
```

**Comandos de Exemplo:**
```javascript
// Comando slash
client.on('interactionCreate', async interaction => {
  if (!interaction.isChatInputCommand()) return;

  if (interaction.commandName === 'status') {
    await interaction.reply('✅ Online!');
  }
});
```

---

## 1.4 slack-bot

**Descrição:** Integração com Slack para equipes

**Funcionalidades:**
- ✅ Responder em canais e DMs
- ✅ Slash commands
- ✅ Interactive buttons
- ✅ File uploads
- ✅ Reactions e threads

**Instalação:**
```bash
npx molthub@latest install slack-bot
npm install @slack/bolt
```

**Criar Slack App:**
```
1. https://api.slack.com/apps → Create New App
2. From scratch
3. Nome + Workspace
4. OAuth & Permissions → Add scopes:
   - chat:write
   - channels:read
   - users:read
5. Install to Workspace
6. Copie Bot User OAuth Token
```

**Configuração:**
```json
{
  "integrations": {
    "slack": {
      "token": "xoxb-...",
      "signingSecret": "...",
      "enabled": true
    }
  }
}
```

---

## 1.5 gmail-integration

**Descrição:** Monitora e responde emails automaticamente

**Funcionalidades:**
- ✅ Ler emails não lidos
- ✅ Responder automaticamente
- ✅ Enviar emails
- ✅ Filtrar por remetente/assunto
- ✅ Anexar arquivos

**Instalação:**
```bash
npx molthub@latest install gmail
npm install googleapis
```

**Setup OAuth Google:**
```
1. https://console.cloud.google.com
2. Criar projeto
3. Ativar Gmail API
4. Credentials → OAuth 2.0 Client ID
5. Download JSON
6. Salvar como: ~/.clawdbot/credentials/gmail.json
```

**Autenticar:**
```bash
moltbot auth gmail
# Abrirá navegador para autorizar
```

**Comandos:**
```
"Leia meus emails não lidos do Gmail"
"Responda ao email de [pessoa] dizendo..."
"Envie email para [destinatário] com assunto..."
```

---

## 1.6 signal-messenger

**Descrição:** Mensagens privadas via Signal

**Instalação:**
```bash
npx molthub@latest install signal
npm install signal-cli-rest-api
```

**Configuração:**
```bash
# Requer signal-cli instalado
docker run -p 8080:8080 bbernhard/signal-cli-rest-api
```

---

## 1.7 mattermost-bot

**Descrição:** Chat corporativo Mattermost

**Instalação:**
```bash
npx molthub@latest install mattermost
```

---

## 1.8 google-chat

**Descrição:** Google Workspace chat

**Instalação:**
```bash
npx molthub@latest install google-chat
```

---

## 1.9 ms-teams

**Descrição:** Microsoft Teams integration

**Instalação:**
```bash
npx molthub@latest install ms-teams
```

---

## 1.10 webchat-widget

**Descrição:** Widget de chat para site

**Instalação:**
```bash
npx molthub@latest install webchat
```

**Implementação:**
```html
<!-- No site -->
<script src="https://localhost:18789/webchat.js"></script>
<script>
  MoltbotChat.init({
    botName: 'Assistente',
    theme: 'light'
  });
</script>
```

---

# 📊 CATEGORIA 2: PRODUTIVIDADE & GESTÃO

## 2.1 google-calendar

**Descrição:** Gerenciar agendamentos no Google Calendar

**Funcionalidades:**
- ✅ Criar eventos
- ✅ Listar próximos compromissos
- ✅ Atualizar/cancelar eventos
- ✅ Definir lembretes
- ✅ Múltiplos calendários

**Instalação:**
```bash
npx molthub@latest install google-calendar
npm install googleapis
```

**Setup:**
```bash
# Autenticar
moltbot auth google-calendar

# Configurar calendário padrão
moltbot config set integrations.calendar.defaultCalendar "primary"
```

**Comandos Naturais:**
```
"Agende reunião para amanhã às 14h com João"
"Quais meus compromissos de hoje?"
"Cancele a reunião das 10h"
"Mude a reunião das 15h para 16h"
```

**Script de Uso:**
```javascript
// Criar evento
const event = {
  summary: 'Reunião com Cliente',
  start: { dateTime: '2026-02-01T14:00:00-03:00' },
  end: { dateTime: '2026-02-01T15:00:00-03:00' },
  attendees: [{ email: 'cliente@email.com' }],
  reminders: {
    useDefault: false,
    overrides: [
      { method: 'email', minutes: 24 * 60 },
      { method: 'popup', minutes: 10 }
    ]
  }
};

calendar.events.insert({
  calendarId: 'primary',
  resource: event
});
```

---

## 2.2 todoist-integration

**Descrição:** Gerenciador de tarefas Todoist

**Funcionalidades:**
- ✅ Criar tarefas
- ✅ Listar pendências
- ✅ Marcar como concluído
- ✅ Prioridades e labels
- ✅ Projetos e seções

**Instalação:**
```bash
npx molthub@latest install todoist
npm install @doist/todoist-api-typescript
```

**Obter API Key:**
```
1. Acesse: https://todoist.com/app/settings/integrations
2. Copie "API token"
3. Configure no moltbot.json
```

**Configuração:**
```json
{
  "integrations": {
    "todoist": {
      "apiToken": "SEU_TOKEN",
      "defaultProject": "Inbox"
    }
  }
}
```

**Comandos:**
```
"Adicione tarefa: Comprar material de escritório"
"Quais minhas tarefas para hoje?"
"Marque como concluída a tarefa X"
```

---

## 2.3 notion-database

**Descrição:** Integração com databases Notion

**Funcionalidades:**
- ✅ Criar páginas
- ✅ Atualizar databases
- ✅ Query com filtros
- ✅ Propriedades customizadas

**Instalação:**
```bash
npx molthub@latest install notion
npm install @notionhq/client
```

**Setup Notion:**
```
1. https://www.notion.so/my-integrations
2. New integration
3. Copie Internal Integration Token
4. Na página Notion: Share → Add integration
```

**Comandos:**
```
"Adicione no Notion database Clientes: Nome João, Telefone..."
"Busque no Notion todos os leads do mês passado"
```

---

## 2.4 trello-boards

**Descrição:** Gerenciar boards Trello

**Instalação:**
```bash
npx molthub@latest install trello
```

---

## 2.5 asana-tasks

**Descrição:** Gestão de projetos Asana

**Instalação:**
```bash
npx molthub@latest install asana
```

---

## 2.6 monday-integration

**Descrição:** Monday.com boards

**Instalação:**
```bash
npx molthub@latest install monday
```

---

## 2.7 clickup-tasks

**Descrição:** ClickUp task management

**Instalação:**
```bash
npx molthub@latest install clickup
```

---

## 2.8 airtable-bases

**Descrição:** Airtable databases

**Instalação:**
```bash
npx molthub@latest install airtable
```

---

## 2.9 coda-docs

**Descrição:** Coda documents integration

**Instalação:**
```bash
npx molthub@latest install coda
```

---

## 2.10 evernote-notes

**Descrição:** Evernote note-taking

**Instalação:**
```bash
npx molthub@latest install evernote
```

---

## 2.11 onenote-integration

**Descrição:** Microsoft OneNote

**Instalação:**
```bash
npx molthub@latest install onenote
```

---

## 2.12 google-drive

**Descrição:** Gerenciar arquivos Google Drive

**Funcionalidades:**
- ✅ Upload de arquivos
- ✅ Download
- ✅ Criar pastas
- ✅ Compartilhar links
- ✅ Buscar arquivos

**Instalação:**
```bash
npx molthub@latest install google-drive
```

**Comandos:**
```
"Faça upload deste arquivo para meu Google Drive"
"Busque no Drive todos os PDFs de janeiro"
"Crie pasta 'Clientes 2026' no Drive"
```

---

# ⚙️ CATEGORIA 3: AUTOMAÇÃO & AGENDAMENTO

## 3.1 cron-scheduler

**Descrição:** Agendamento de tarefas recorrentes

**Funcionalidades:**
- ✅ Cron jobs automáticos
- ✅ Formato cron padrão
- ✅ Tarefas diárias/semanais/mensais
- ✅ Execução em horários específicos

**Instalação:**
```bash
# Já vem integrado no MoltBot core
npm install node-cron
```

**Configuração via CLI:**
```bash
# Listar jobs
moltbot cron list

# Adicionar job
moltbot cron add \
  --schedule "0 8 * * *" \
  --message "Bom dia! Briefing matinal"

# Remover job
moltbot cron remove <job_id>

# Editar job
moltbot cron edit <job_id>
```

**Configuração via HEARTBEAT.md:**
```markdown
# ~/.clawdbot/HEARTBEAT.md

### Segunda a Sexta, 08:00
☀️ Bom dia! Aqui está seu resumo:
- Compromissos do dia
- Tarefas pendentes
- Lembretes importantes

### Segunda a Sexta, 12:00
🍽️ Hora do almoço!

### Segunda a Sexta, 18:00
🌅 Fim do expediente! Resumo:
- [x] Tarefas concluídas hoje
- [ ] Pendências para amanhã

### Todo dia 1, 09:00
📊 Relatório mensal de atividades

### Domingo, 20:00
📅 Preparação da semana:
- Revisar agenda
- Definir 3 prioridades
```

**Formato Cron:**
```
* * * * *
│ │ │ │ │
│ │ │ │ └─── Dia da semana (0-6, 0=Domingo)
│ │ │ └───── Mês (1-12)
│ │ └─────── Dia do mês (1-31)
│ └───────── Hora (0-23)
└─────────── Minuto (0-59)

Exemplos:
0 8 * * *       # Todo dia às 8h
0 8 * * 1-5     # Segunda a sexta às 8h
0 0 1 * *       # Primeiro dia do mês à meia-noite
*/30 * * * *    # A cada 30 minutos
```

**Script Node.js:**
```javascript
const cron = require('node-cron');

// Briefing matinal
cron.schedule('0 8 * * 1-5', () => {
  console.log('Enviando briefing matinal...');
  // Sua lógica aqui
});

// Backup noturno
cron.schedule('0 23 * * *', () => {
  console.log('Executando backup...');
  // Sua lógica aqui
});
```

---

## 3.2 heartbeat-monitor

**Descrição:** Monitor de saúde do sistema

**Funcionalidades:**
- ✅ Ping automático do gateway
- ✅ Alertas de falha
- ✅ Restart automático
- ✅ Logs de uptime

**Instalação:**
```bash
# Core feature - já incluído
```

**Configuração:**
```json
{
  "heartbeat": {
    "enabled": true,
    "interval": 60000,  // 1 minuto
    "alertOnFailure": true,
    "autoRestart": true
  }
}
```

**Comandos:**
```bash
# Verificar status
moltbot health

# Logs de heartbeat
moltbot logs heartbeat

# Forçar restart
moltbot restart
```

---

## 3.3 auto-followup

**Descrição:** Follow-ups automáticos com clientes

**Funcionalidades:**
- ✅ Follow-up D+1, D+3, D+7
- ✅ Templates personalizados
- ✅ Tracking de respostas
- ✅ Escalonamento automático

**Instalação:**
```bash
npx molthub@latest install auto-followup
```

**Configuração:**
```markdown
# ~/.clawdbot/skills/followup/SKILL.md

# Follow-up Automático

## Gatilhos
Quando procedimento concluído:
1. D+1: "Como está se sentindo?"
2. D+3: "Alguma dúvida ou desconforto?"
3. D+7: "Vamos agendar retorno?"

## Templates
**D+1:**
Olá [NOME]! Tudo bem? Como está se sentindo após o procedimento de ontem?

**D+3:**
Oi [NOME]! Passando aqui para saber se está tudo ok. Alguma dúvida?

**D+7:**
Olá [NOME]! Uma semana desde o procedimento. Gostaria de agendar retorno?
```

**Usar:**
```bash
# Marcar procedimento concluído
moltbot followup start --paciente "João Silva" --procedimento "Botox"

# Listar follow-ups ativos
moltbot followup list

# Cancelar follow-up
moltbot followup cancel <id>
```

---

## 3.4 webhook-handler

**Descrição:** Recebe webhooks de serviços externos

**Funcionalidades:**
- ✅ Endpoint HTTP customizado
- ✅ Autenticação por token
- ✅ Processar eventos externos
- ✅ Triggers de automação

**Instalação:**
```bash
npx molthub@latest install webhook-handler
```

**Configuração:**
```json
{
  "webhooks": {
    "enabled": true,
    "port": 18790,
    "endpoints": {
      "/calendly": {
        "secret": "seu_token_secreto",
        "action": "novo_agendamento"
      },
      "/stripe": {
        "secret": "stripe_webhook_secret",
        "action": "pagamento_recebido"
      }
    }
  }
}
```

**Exemplo de Uso:**
```javascript
// Receber webhook do Calendly
// POST http://localhost:18790/webhooks/calendly

{
  "event": "invitee.created",
  "payload": {
    "name": "João Silva",
    "email": "joao@email.com",
    "event_start_time": "2026-02-01T14:00:00Z"
  }
}

// MoltBot processa e:
// 1. Envia confirmação no WhatsApp
// 2. Adiciona no Google Calendar
// 3. Cria tarefa de follow-up
```

---

## 3.5 zapier-integration

**Descrição:** Integração com Zapier

**Instalação:**
```bash
npx molthub@latest install zapier
```

---

## 3.6 ifttt-connector

**Descrição:** IFTTT automations

**Instalação:**
```bash
npx molthub@latest install ifttt
```

---

## 3.7 n8n-workflow

**Descrição:** n8n workflow automation

**Instalação:**
```bash
npx molthub@latest install n8n
```

---

## 3.8 make-scenarios

**Descrição:** Make.com (Integromat) scenarios

**Instalação:**
```bash
npx molthub@latest install make
```

---

# 💻 CATEGORIA 4: DESENVOLVIMENTO & CÓDIGO

## 4.1 code-executor

**Descrição:** Executa código em múltiplas linguagens

**Funcionalidades:**
- ✅ Python, JavaScript, Bash, Ruby
- ✅ Sandbox seguro
- ✅ Instalar pacotes npm/pip
- ✅ Timeout de segurança

**Instalação:**
```bash
npx molthub@latest install code-executor
```

**Comandos:**
```
"Execute este código Python: print('Hello')"
"Rode este script bash para..."
"Instale a biblioteca pandas e execute..."
```

**Segurança:**
```json
{
  "codeExecution": {
    "enabled": true,
    "sandbox": true,
    "timeout": 30000,
    "allowedLanguages": ["python", "javascript", "bash"],
    "maxMemory": "512M"
  }
}
```

---

## 4.2 git-manager

**Descrição:** Gerenciar repositórios Git

**Funcionalidades:**
- ✅ Clone, pull, push
- ✅ Commits automáticos
- ✅ Criar branches
- ✅ Merge requests

**Instalação:**
```bash
npx molthub@latest install git-manager
```

**Comandos:**
```
"Clone o repositório https://github.com/user/repo"
"Faça commit das mudanças com mensagem: 'Fix bug'"
"Crie branch feature/nova-funcionalidade"
```

---

## 4.3 github-integration

**Descrição:** GitHub API integration

**Funcionalidades:**
- ✅ Criar issues
- ✅ Pull requests
- ✅ Comentar em PRs
- ✅ Verificar CI/CD status

**Instalação:**
```bash
npx molthub@latest install github
```

**Setup:**
```bash
# Gerar token: https://github.com/settings/tokens
# Permissions: repo, workflow

moltbot config set integrations.github.token "ghp_..."
```

**Comandos:**
```
"Crie issue no GitHub: Bug no login"
"Liste pull requests abertas"
"Comente na PR #42: LGTM"
```

---

## 4.4 gitlab-integration

**Descrição:** GitLab integration

**Instalação:**
```bash
npx molthub@latest install gitlab
```

---

## 4.5 docker-manager

**Descrição:** Gerenciar containers Docker

**Instalação:**
```bash
npx molthub@latest install docker
```

---

## 4.6 kubernetes-ops

**Descrição:** Kubernetes operations

**Instalação:**
```bash
npx molthub@latest install kubernetes
```

---

## 4.7 terminal-access

**Descrição:** Acesso direto ao terminal

**Funcionalidades:**
- ✅ Executar comandos shell
- ✅ Navegação de diretórios
- ✅ Gerenciar processos

**Instalação:**
```bash
# Core feature
```

**Comandos:**
```
"Execute no terminal: ls -la"
"Mostre uso de disco com df -h"
"Mate processo na porta 3000"
```

---

## 4.8 file-ops

**Descrição:** Operações de arquivos

**Funcionalidades:**
- ✅ Criar/ler/editar arquivos
- ✅ Copiar/mover/deletar
- ✅ Buscar em arquivos
- ✅ Permissões

**Instalação:**
```bash
# Core feature
```

---

## 4.9 vscode-remote

**Descrição:** Controlar VS Code remotamente

**Instalação:**
```bash
npx molthub@latest install vscode-remote
```

---

## 4.10 database-query

**Descrição:** Query SQL databases

**Instalação:**
```bash
npx molthub@latest install database-query
npm install mysql2 pg sqlite3
```

---

# 🤖 CATEGORIA 5: IA & ANÁLISE

## 5.1 web-search

**Descrição:** Busca na web com múltiplos motores

**Funcionalidades:**
- ✅ Google, Bing, DuckDuckGo
- ✅ Scraping de resultados
- ✅ Resumo automático
- ✅ Cache de buscas

**Instalação:**
```bash
npx molthub@latest install web-search
npm install puppeteer cheerio
```

**Comandos:**
```
"Busque na web: últimas notícias sobre IA"
"Pesquise preços de iPhone 15"
"Encontre tutoriais de React hooks"
```

---

## 5.2 image-generation

**Descrição:** Gerar imagens com IA

**Funcionalidades:**
- ✅ DALL-E, Midjourney, Stable Diffusion
- ✅ Múltiplos estilos
- ✅ Edição de imagens

**Instalação:**
```bash
npx molthub@latest install image-gen
```

**Comandos:**
```
"Gere imagem: gato astronauta no espaço"
"Crie logo para clínica de estética"
```

---

## 5.3 image-vision

**Descrição:** Análise de imagens

**Funcionalidades:**
- ✅ Descrever conteúdo
- ✅ OCR (texto em imagens)
- ✅ Detectar objetos
- ✅ Comparar antes/depois

**Instalação:**
```bash
npx molthub@latest install image-vision
```

**Comandos:**
```
"Analise esta imagem e descreva"
"Extraia o texto desta foto"
"Compare estas duas imagens de procedimento"
```

---

## 5.4 pdf-reader

**Descrição:** Ler e extrair conteúdo de PDFs

**Instalação:**
```bash
npx molthub@latest install pdf-reader
npm install pdf-parse
```

---

## 5.5 csv-processor

**Descrição:** Processar planilhas CSV/Excel

**Instalação:**
```bash
npx molthub@latest install csv-processor
npm install csv-parser xlsx
```

---

## 5.6 data-analyzer

**Descrição:** Análise de dados e estatísticas

**Instalação:**
```bash
npx molthub@latest install data-analyzer
```

---

## 5.7 sentiment-analysis

**Descrição:** Análise de sentimento de textos

**Instalação:**
```bash
npx molthub@latest install sentiment-analysis
```

---

## 5.8 translation

**Descrição:** Tradução automática

**Instalação:**
```bash
npx molthub@latest install translation
```

---

# 📝 CATEGORIA 6: INTEGRAÇÃO OBSIDIAN

## 6.1 obsidian-cli

**Descrição:** Controle completo do Obsidian via CLI

**Funcionalidades:**
- ✅ Criar notas
- ✅ Buscar conteúdo
- ✅ Listar arquivos
- ✅ Templates
- ✅ Múltiplos vaults

**Instalação:**
```bash
# Instalar obsidian-cli
npm install -g obsidian-cli

# Instalar skill MoltBot
npx molthub@latest install obsidian
```

**Configuração:**
```bash
# Definir vault padrão
obsidian-cli set-default "MeuVault"

# Verificar
obsidian-cli print-default

# Listar todos os vaults
obsidian-cli list-vaults
```

**Configurar no MoltBot:**
```json
{
  "integrations": {
    "obsidian": {
      "vaultPath": "/Users/voce/Documents/ObsidianVault",
      "enabled": true,
      "multiVault": false
    }
  }
}
```

**Comandos Naturais:**
```
"Crie nota no Obsidian: Ideia para projeto X"
"Busque no Obsidian todas as notas sobre React"
"Adicione à daily note: Reunião com cliente às 15h"
"Mostre minhas tarefas pendentes do Obsidian"
"Liste todas as notas da pasta Projetos"
```

**Comandos CLI Diretos:**
```bash
# Criar nota
obsidian-cli create "Nota Nova" --vault "MeuVault"

# Criar com template
obsidian-cli create "Daily Note" --template "Templates/Daily"

# Buscar
obsidian-cli search "react hooks" --vault "MeuVault"

# Abrir nota
obsidian-cli open "Nota Existente"

# Daily note
obsidian-cli daily create
```

---

## 6.2 obsidian-templates

**Descrição:** Templates automáticos para Obsidian

**Instalação:**
```bash
npx molthub@latest install obsidian-templates
```

**Criar Templates:**
```markdown
# ~/ObsidianVault/Templates/Daily.md

# {{date:YYYY-MM-DD}} - Daily Note

## 🎯 Prioridades do Dia
- [ ] 
- [ ] 
- [ ] 

## 📝 Notas Rápidas


## ✅ Tarefas Concluídas


## 📅 Compromissos
{{calendar:today}}
```

**Usar:**
```
"Crie daily note usando template Daily"
"Crie nota de reunião com template Meeting"
```

---

## 6.3 obsidian-dataview

**Descrição:** Queries Dataview automáticas

**Instalação:**
```bash
npx molthub@latest install obsidian-dataview
```

**Exemplos:**
```
"Mostre todas as tarefas pendentes no Obsidian"
"Liste notas criadas esta semana"
"Agrupe notas por tag"
```

---

## 6.4 obsidian-graph

**Descrição:** Análise de grafo de conhecimento

**Instalação:**
```bash
npx molthub@latest install obsidian-graph
```

---

## 6.5 obsidian-backup

**Descrição:** Backup automático do vault

**Instalação:**
```bash
npx molthub@latest install obsidian-backup
```

**Configuração:**
```bash
# Backup diário às 23h
moltbot cron add \
  --schedule "0 23 * * *" \
  --exec "obsidian-cli backup --vault 'MeuVault' --dest '/backups/obsidian'"
```

---

## 6.6 vault-analyst

**Descrição:** Agente especializado em análise de vault

**Criação:**
```bash
# Criar sub-agente
moltbot agents add vault-analyst
```

**SOUL.md:**
```markdown
# ~/.clawd-vault-analyst/SOUL.md

# Vault Analyst Agent

## Identidade
Analista especializado em dados de Obsidian vault.

## Missão
Analisar padrões, tendências e insights em notas.

## Habilidades Ativas
- obsidian-cli (leitura de vault)
- Análise estatística de padrões
- Detecção de tendências temporais
- Identificação de gaps
- Geração de relatórios estruturados

## Formato de Relatório
1. **Sumário Executivo** (3 pontos principais)
2. **Análise Detalhada** (métricas)
3. **Insights** (descobertas)
4. **Recomendações** (ações)
```

**Usar:**
```
"@vault-analyst Analise meu vault dos últimos 30 dias"
"@vault-analyst Quais são as notas mais conectadas?"
"@vault-analyst Encontre padrões nas minhas daily notes"
```

---

# 📱 CATEGORIA 7: REDES SOCIAIS & MARKETING

## 7.1 instagram-automation

**Descrição:** Automação Instagram

**Instalação:**
```bash
npx molthub@latest install instagram
```

---

## 7.2 facebook-pages

**Descrição:** Gerenciar páginas Facebook

**Instalação:**
```bash
npx molthub@latest install facebook
```

---

## 7.3 twitter-bot

**Descrição:** Automação Twitter/X

**Instalação:**
```bash
npx molthub@latest install twitter
```

---

## 7.4 linkedin-posts

**Descrição:** Postar no LinkedIn

**Instalação:**
```bash
npx molthub@latest install linkedin
```

---

## 7.5 tiktok-manager

**Descrição:** TikTok content management

**Instalação:**
```bash
npx molthub@latest install tiktok
```

---

# 🏥 CATEGORIA 8: CLÍNICA & SAÚDE (ESPECIALIZADA)

## 8.1 clinic-scheduler

**Descrição:** Agendamento especializado para clínicas

**Funcionalidades:**
- ✅ Múltiplos profissionais
- ✅ Salas/recursos
- ✅ Bloqueios de horário
- ✅ Lista de espera
- ✅ Confirmações automáticas

**Instalação:**
```bash
npx molthub@latest install clinic-scheduler
```

**Configuração:**
```json
{
  "clinic": {
    "name": "Clínica Estética Exemplo",
    "professionals": [
      {
        "name": "Dra. Maria",
        "specialty": "Dermatologia",
        "schedule": {
          "monday": ["08:00-12:00", "14:00-18:00"],
          "tuesday": ["08:00-12:00", "14:00-18:00"]
        }
      }
    ],
    "procedures": [
      {
        "name": "Botox",
        "duration": 30,
        "price": 800,
        "professional": "Dra. Maria"
      }
    ]
  }
}
```

**Comandos:**
```
"Agende botox com Dra. Maria para amanhã às 14h"
"Quais horários disponíveis esta semana?"
"Confirme agendamento do João para quinta"
```

---

## 8.2 patient-followup

**Descrição:** Follow-up pós-procedimento

**Templates:**
```markdown
# D+1 Pós-Procedimento
Olá {{nome}}! Como está se sentindo após o {{procedimento}} de ontem?

# D+3
Oi {{nome}}! Algum desconforto ou dúvida sobre o {{procedimento}}?

# D+7
Olá {{nome}}! Gostaria de agendar retorno para avaliar resultados?

# D+30
Olá {{nome}}! Está satisfeito com os resultados? Gostaria de agendar manutenção?
```

**Instalação:**
```bash
npx molthub@latest install patient-followup
```

---

## 8.3 prescription-generator

**Descrição:** Gerador de receitas médicas

**Instalação:**
```bash
npx molthub@latest install prescription-generator
```

---

## 8.4 medical-records

**Descrição:** Prontuário eletrônico básico

**Instalação:**
```bash
npx molthub@latest install medical-records
```

---

## 8.5 consent-forms

**Descrição:** Termos de consentimento automáticos

**Instalação:**
```bash
npx molthub@latest install consent-forms
```

---

## 8.6 before-after-tracker

**Descrição:** Rastreador de fotos antes/depois

**Funcionalidades:**
- ✅ Upload de fotos
- ✅ Comparação lado a lado
- ✅ Timelapses
- ✅ Relatórios visuais

**Instalação:**
```bash
npx molthub@latest install before-after-tracker
```

---

## 8.7 payment-reminders

**Descrição:** Lembretes de pagamento

**Instalação:**
```bash
npx molthub@latest install payment-reminders
```

---

## 8.8 review-collector

**Descrição:** Coletor de avaliações

**Funcionalidades:**
- ✅ Solicitar avaliação após procedimento
- ✅ Links para Google/Facebook reviews
- ✅ Análise de sentimento
- ✅ Dashboard de feedback

**Instalação:**
```bash
npx molthub@latest install review-collector
```

**Automação:**
```bash
# D+7 após procedimento
moltbot cron add \
  --trigger "procedure_completed" \
  --delay "7 days" \
  --message "Olá! Ficamos felizes em ter cuidado de você. Poderia avaliar nosso atendimento? [link]"
```

---

# 📊 RESUMO ESTATÍSTICO

## Por Categoria

| Categoria | Quantidade | Essenciais |
|-----------|------------|------------|
| Comunicação & Mensagens | 10 | 5 |
| Produtividade & Gestão | 12 | 6 |
| Automação & Agendamento | 8 | 4 |
| Desenvolvimento & Código | 10 | 3 |
| IA & Análise | 8 | 4 |
| Integração Obsidian | 6 | 3 |
| Redes Sociais & Marketing | 5 | 2 |
| Clínica & Saúde | 8 | 5 |
| **TOTAL** | **67** | **32** |

---

# 🎯 SKILLS ESSENCIAIS (TOP 20)

Priorize estas skills para começar:

1. ✅ **telegram-bot** - Comunicação principal
2. ✅ **whatsapp-bot** - Essencial para clínicas
3. ✅ **google-calendar** - Agendamentos
4. ✅ **gmail-integration** - Email automático
5. ✅ **cron-scheduler** - Automações
6. ✅ **auto-followup** - Follow-ups
7. ✅ **obsidian-cli** - PKM
8. ✅ **web-search** - Busca inteligente
9. ✅ **code-executor** - Automações custom
10. ✅ **file-ops** - Gestão de arquivos
11. ✅ **webhook-handler** - Integrações
12. ✅ **image-vision** - Análise de imagens
13. ✅ **pdf-reader** - Documentos
14. ✅ **clinic-scheduler** - Agenda clínica
15. ✅ **patient-followup** - Pós-procedimento
16. ✅ **before-after-tracker** - Fotos
17. ✅ **review-collector** - Avaliações
18. ✅ **notion-database** - Base de dados
19. ✅ **slack-bot** - Equipe interna
20. ✅ **git-manager** - Controle versão

---

# 🚀 SCRIPT DE INSTALAÇÃO RÁPIDA

```bash
#!/bin/bash
# install-essential-skills.sh

echo "🚀 Instalando Skills Essenciais do MoltBot..."

# Comunicação
npx molthub@latest install telegram-bot
npx molthub@latest install whatsapp-bot
npx molthub@latest install gmail

# Produtividade
npx molthub@latest install google-calendar
npx molthub@latest install todoist
npx molthub@latest install notion

# Automação
npx molthub@latest install auto-followup
npx molthub@latest install webhook-handler

# Obsidian
npm install -g obsidian-cli
npx molthub@latest install obsidian

# IA & Análise
npx molthub@latest install web-search
npx molthub@latest install image-vision
npx molthub@latest install pdf-reader

# Clínica
npx molthub@latest install clinic-scheduler
npx molthub@latest install patient-followup
npx molthub@latest install before-after-tracker

echo "✅ Instalação concluída!"
echo "📝 Configure cada skill com: moltbot config"
```

---

# 📖 COMO USAR ESTE DOCUMENTO

## No Notion
1. Copie todo o conteúdo markdown
2. No Notion: New Page → Paste
3. Use o índice para navegar
4. Marque skills instaladas com ✅

## No Obsidian
1. Crie arquivo: `MoltBot-Skills.md`
2. Cole o conteúdo
3. Use links internos [[Skill Name]]
4. Adicione tags: #moltbot #skills

## Como Checklist
```markdown
## Minhas Skills Instaladas
- [ ] telegram-bot
- [ ] whatsapp-bot
- [ ] google-calendar
- [ ] obsidian-cli
- [ ] cron-scheduler
...
```

---

**Gerado em:** 30/01/2026  
**Versão:** 2.0 Final  
**Total de Skills:** 67  
**Licença:** MIT
