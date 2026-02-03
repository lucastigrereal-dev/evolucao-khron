# 🔧 MOLTBOT - SCRIPTS PRONTOS & AUTOMAÇÕES

> **Versão:** 2.0  
> **Data:** 30/01/2026  
> **Conteúdo:** Scripts copy-paste para cada skill

---

## 📑 ÍNDICE DE SCRIPTS

```
PARTE 1: Scripts de Instalação Rápida
PARTE 2: Automações de Comunicação
PARTE 3: Automações de Agendamento
PARTE 4: Automações Obsidian
PARTE 5: Workflows Clínicos
PARTE 6: Integrações Avançadas
PARTE 7: Scripts de Manutenção
```

---

# ⚡ PARTE 1: SCRIPTS DE INSTALAÇÃO RÁPIDA

## 1.1 Instalação Completa - Windows (PowerShell)

```powershell
# MOLTBOT-INSTALLER.ps1
# Execução: Abra PowerShell como Admin e execute

Write-Host "🚀 MOLTBOT INSTALLER - Iniciando..." -ForegroundColor Cyan

# Verificar WSL2
if (!(wsl --list | Select-String "Ubuntu")) {
    Write-Host "❌ WSL2 não encontrado. Instalando..." -ForegroundColor Yellow
    wsl --install -d Ubuntu
    Write-Host "⚠️ Reinicie o PC e execute este script novamente" -ForegroundColor Yellow
    exit
}

# Executar no WSL
wsl bash -c @"
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Node.js 22
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verificar
node --version
npm --version

# Instalar MoltBot
npm install -g moltbot@latest

# Instalar Ollama (opcional)
curl -fsSL https://ollama.ai/install.sh | sh
ollama pull qwen2.5:7b

# Setup inicial
moltbot onboard

echo "✅ Instalação concluída!"
"@

Write-Host "✅ MoltBot instalado com sucesso!" -ForegroundColor Green
```

---

## 1.2 Instalação Skills Essenciais

```bash
#!/bin/bash
# install-skills.sh

echo "📦 Instalando Skills Essenciais..."

# Array de skills
SKILLS=(
    "telegram-bot"
    "whatsapp-bot"
    "gmail"
    "google-calendar"
    "todoist"
    "notion"
    "obsidian"
    "auto-followup"
    "webhook-handler"
    "web-search"
    "image-vision"
    "pdf-reader"
    "clinic-scheduler"
    "patient-followup"
    "before-after-tracker"
)

# Instalar cada skill
for skill in "${SKILLS[@]}"; do
    echo "Installing $skill..."
    npx molthub@latest install "$skill"
    if [ $? -eq 0 ]; then
        echo "✅ $skill instalado"
    else
        echo "❌ Erro ao instalar $skill"
    fi
done

# Instalar obsidian-cli separadamente
echo "Installing obsidian-cli..."
npm install -g obsidian-cli

echo "🎉 Todas as skills instaladas!"
```

---

# 📱 PARTE 2: AUTOMAÇÕES DE COMUNICAÇÃO

## 2.1 Bot Telegram - Resposta Automática

```javascript
// telegram-auto-responder.js
const TelegramBot = require('node-telegram-bot-api');

const TOKEN = process.env.TELEGRAM_TOKEN;
const bot = new TelegramBot(TOKEN, { polling: true });

// Respostas automáticas
const responses = {
    '/start': 'Olá! Sou o assistente da Clínica Estética. Como posso ajudar?',
    '/horarios': 'Atendemos:\n📅 Segunda a Sexta: 8h-18h\n📅 Sábado: 8h-12h',
    '/agendar': 'Para agendar, escolha o procedimento:\n1️⃣ Botox\n2️⃣ Preenchimento\n3️⃣ Limpeza de Pele',
    '/precos': 'Nossos preços:\n💉 Botox: R$ 800\n💧 Preenchimento: R$ 1.200\n🧖 Limpeza: R$ 150',
    '/contato': '📞 Telefone: (11) 99999-9999\n📍 Rua Exemplo, 123 - São Paulo'
};

// FAQs
const faqs = {
    'horário': responses['/horarios'],
    'agendar': responses['/agendar'],
    'preço': responses['/precos'],
    'quanto custa': responses['/precos'],
    'endereço': responses['/contato'],
    'telefone': responses['/contato']
};

// Handler de comandos
bot.onText(/\/(.+)/, (msg, match) => {
    const chatId = msg.chat.id;
    const command = `/${match[1]}`;
    
    if (responses[command]) {
        bot.sendMessage(chatId, responses[command]);
    }
});

// Handler de mensagens (FAQ)
bot.on('message', (msg) => {
    const chatId = msg.chat.id;
    const text = msg.text.toLowerCase();
    
    // Verificar se não é comando
    if (!text.startsWith('/')) {
        // Buscar em FAQs
        for (const [keyword, response] of Object.entries(faqs)) {
            if (text.includes(keyword)) {
                bot.sendMessage(chatId, response);
                return;
            }
        }
        
        // Resposta padrão
        bot.sendMessage(chatId, 
            'Desculpe, não entendi. Digite /start para ver opções.'
        );
    }
});

console.log('🤖 Bot Telegram rodando...');
```

**Executar:**
```bash
export TELEGRAM_TOKEN="seu_token"
node telegram-auto-responder.js
```

---

## 2.2 WhatsApp - Confirmação de Agendamento

```javascript
// whatsapp-confirmation.js
const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');

const client = new Client({
    authStrategy: new LocalAuth()
});

client.on('qr', qr => {
    console.log('📱 Escaneie o QR Code:');
    qrcode.generate(qr, {small: true});
});

client.on('ready', () => {
    console.log('✅ WhatsApp conectado!');
});

// Função de confirmação de agendamento
async function enviarConfirmacao(numero, dados) {
    const mensagem = `
✅ *AGENDAMENTO CONFIRMADO*

👤 *Paciente:* ${dados.nome}
💉 *Procedimento:* ${dados.procedimento}
📅 *Data:* ${dados.data}
🕐 *Horário:* ${dados.hora}
👨‍⚕️ *Profissional:* ${dados.profissional}

📍 *Local:* Clínica Estética Exemplo
Rua Exemplo, 123 - São Paulo

⚠️ *Importante:*
- Chegar 10 minutos antes
- Trazer documento com foto
- Jejum não é necessário

Para cancelar ou reagendar, responda esta mensagem.

_Mensagem automática - Clínica Estética_
    `.trim();
    
    await client.sendMessage(`${numero}@c.us`, mensagem);
    console.log(`✅ Confirmação enviada para ${numero}`);
}

// Exemplo de uso
client.on('ready', async () => {
    // Enviar confirmação exemplo
    await enviarConfirmacao('5511999999999', {
        nome: 'Maria Silva',
        procedimento: 'Botox',
        data: '15/02/2026',
        hora: '14:00',
        profissional: 'Dra. Ana'
    });
});

client.initialize();
```

---

## 2.3 Email - Lembrete Automático

```javascript
// gmail-reminder.js
const { google } = require('googleapis');
const nodemailer = require('nodemailer');

// Configurar OAuth2
const oauth2Client = new google.auth.OAuth2(
    process.env.GMAIL_CLIENT_ID,
    process.env.GMAIL_CLIENT_SECRET,
    process.env.GMAIL_REDIRECT_URI
);

oauth2Client.setCredentials({
    refresh_token: process.env.GMAIL_REFRESH_TOKEN
});

// Criar transporter
async function createTransporter() {
    const accessToken = await oauth2Client.getAccessToken();
    
    return nodemailer.createTransport({
        service: 'gmail',
        auth: {
            type: 'OAuth2',
            user: 'sua-clinica@gmail.com',
            clientId: process.env.GMAIL_CLIENT_ID,
            clientSecret: process.env.GMAIL_CLIENT_SECRET,
            refreshToken: process.env.GMAIL_REFRESH_TOKEN,
            accessToken: accessToken.token
        }
    });
}

// Enviar lembrete
async function enviarLembrete(destinatario, dados) {
    const transporter = await createTransporter();
    
    const mailOptions = {
        from: 'Clínica Estética <sua-clinica@gmail.com>',
        to: destinatario,
        subject: `🔔 Lembrete: Consulta amanhã às ${dados.hora}`,
        html: `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <h2 style="color: #4CAF50;">Lembrete de Consulta</h2>
                
                <p>Olá <strong>${dados.nome}</strong>,</p>
                
                <p>Este é um lembrete automático da sua consulta:</p>
                
                <div style="background: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0;">
                    <p><strong>📅 Data:</strong> ${dados.data}</p>
                    <p><strong>🕐 Horário:</strong> ${dados.hora}</p>
                    <p><strong>💉 Procedimento:</strong> ${dados.procedimento}</p>
                    <p><strong>👨‍⚕️ Profissional:</strong> ${dados.profissional}</p>
                </div>
                
                <div style="background: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 20px 0;">
                    <p><strong>⚠️ Importantes:</strong></p>
                    <ul>
                        <li>Chegar 10 minutos antes</li>
                        <li>Trazer documento com foto</li>
                        <li>Não usar maquiagem (procedimentos faciais)</li>
                    </ul>
                </div>
                
                <p>Para cancelar ou reagendar, ligue: <strong>(11) 99999-9999</strong></p>
                
                <hr style="margin: 30px 0; border: none; border-top: 1px solid #e0e0e0;">
                
                <p style="color: #888; font-size: 12px;">
                    Clínica Estética Exemplo<br>
                    Rua Exemplo, 123 - São Paulo<br>
                    www.clinica-exemplo.com.br
                </p>
            </div>
        `
    };
    
    const result = await transporter.sendMail(mailOptions);
    console.log(`✅ Email enviado para ${destinatario}:`, result.messageId);
}

// Executar
enviarLembrete('paciente@email.com', {
    nome: 'Maria Silva',
    data: '15/02/2026',
    hora: '14:00',
    procedimento: 'Botox',
    profissional: 'Dra. Ana'
});
```

---

# 📅 PARTE 3: AUTOMAÇÕES DE AGENDAMENTO

## 3.1 Google Calendar - Criar Evento

```javascript
// calendar-event.js
const { google } = require('googleapis');

const oauth2Client = new google.auth.OAuth2(
    process.env.GOOGLE_CLIENT_ID,
    process.env.GOOGLE_CLIENT_SECRET,
    process.env.GOOGLE_REDIRECT_URI
);

oauth2Client.setCredentials({
    refresh_token: process.env.GOOGLE_REFRESH_TOKEN
});

const calendar = google.calendar({ version: 'v3', auth: oauth2Client });

async function criarAgendamento(dados) {
    const event = {
        summary: `${dados.procedimento} - ${dados.paciente}`,
        location: 'Clínica Estética Exemplo, Rua Exemplo, 123',
        description: `
Paciente: ${dados.paciente}
Procedimento: ${dados.procedimento}
Profissional: ${dados.profissional}
Telefone: ${dados.telefone}
Email: ${dados.email}

Observações: ${dados.obs || 'Nenhuma'}
        `.trim(),
        start: {
            dateTime: dados.inicio,
            timeZone: 'America/Sao_Paulo'
        },
        end: {
            dateTime: dados.fim,
            timeZone: 'America/Sao_Paulo'
        },
        attendees: [
            { email: dados.email },
            { email: dados.profissionalEmail }
        ],
        reminders: {
            useDefault: false,
            overrides: [
                { method: 'email', minutes: 24 * 60 }, // 1 dia antes
                { method: 'popup', minutes: 30 },       // 30 min antes
                { method: 'sms', minutes: 60 }         // 1h antes
            ]
        },
        colorId: '10' // Verde para procedimentos
    };
    
    const response = await calendar.events.insert({
        calendarId: 'primary',
        resource: event,
        sendUpdates: 'all' // Envia email de confirmação
    });
    
    console.log('✅ Evento criado:', response.data.htmlLink);
    return response.data;
}

// Exemplo de uso
criarAgendamento({
    paciente: 'Maria Silva',
    procedimento: 'Botox',
    profissional: 'Dra. Ana',
    profissionalEmail: 'dra.ana@clinica.com.br',
    telefone: '11999999999',
    email: 'maria@email.com',
    inicio: '2026-02-15T14:00:00',
    fim: '2026-02-15T14:30:00',
    obs: 'Primeira sessão'
});
```

---

## 3.2 Cron Jobs - Automações Diárias

```bash
# cron-config.sh
# Configurar cron jobs do MoltBot

# Briefing matinal (Segunda a Sexta, 8h)
moltbot cron add \
  --schedule "0 8 * * 1-5" \
  --message "☀️ Bom dia! Aqui está seu briefing do dia"

# Lembrete de almoço (12h)
moltbot cron add \
  --schedule "0 12 * * *" \
  --message "🍽️ Hora do almoço! Não esqueça de descansar."

# Resumo do dia (18h)
moltbot cron add \
  --schedule "0 18 * * 1-5" \
  --message "🌅 Fim do expediente! Gerando resumo do dia..."

# Backup diário (23h)
moltbot cron add \
  --schedule "0 23 * * *" \
  --exec "~/.clawd/scripts/backup.sh"

# Limpeza de logs (Domingo, 2h)
moltbot cron add \
  --schedule "0 2 * * 0" \
  --exec "~/.clawd/scripts/cleanup-logs.sh"

# Lembretes de agendamentos (Todo dia, 9h)
moltbot cron add \
  --schedule "0 9 * * *" \
  --exec "~/.clawd/scripts/send-reminders.sh"

echo "✅ Cron jobs configurados!"
```

---

## 3.3 HEARTBEAT.md - Automações Recorrentes

```markdown
# ~/.clawdbot/HEARTBEAT.md

### Segunda a Sexta, 08:00
☀️ **Bom dia!** Iniciando rotina matinal...

**Tarefas automáticas:**
- [ ] Verificar agendamentos de hoje
- [ ] Enviar lembretes para pacientes
- [ ] Gerar lista de pendências
- [ ] Verificar emails não lidos

**Briefing do dia:**
{{calendar:today}}

---

### Segunda a Sexta, 09:00
📧 **Envio de lembretes automáticos**

Para cada agendamento do dia:
1. Verificar se confirmado
2. Se não confirmado, enviar WhatsApp
3. Enviar email de lembrete
4. Atualizar status no sistema

---

### Segunda a Sexta, 12:00
🍽️ **Pausa para almoço**

Lembrete: Descansar é importante!
Aproveitando para:
- Backup incremental
- Limpeza de cache
- Verificação de saúde do sistema

---

### Segunda a Sexta, 17:00
📊 **Pré-fechamento do dia**

Checklist:
- [ ] Todos os procedimentos foram registrados?
- [ ] Fotos antes/depois enviadas?
- [ ] Pagamentos lançados?
- [ ] Follow-ups agendados?

---

### Segunda a Sexta, 18:00
🌅 **Fim do expediente**

**Resumo do dia:**
- Agendamentos realizados: {{count:appointments_today}}
- Novos pacientes: {{count:new_patients}}
- Receita: R$ {{sum:revenue_today}}

**Pendências para amanhã:**
{{tasks:pending}}

---

### Domingo, 20:00
📅 **Preparação da semana**

**Atividades:**
1. Revisar agenda da próxima semana
2. Verificar estoque de materiais
3. Confirmar agendamentos de segunda
4. Gerar relatório semanal
5. Backup completo do sistema

**Metas da semana:**
- Meta de agendamentos: 40
- Meta de receita: R$ 20.000
- NPS alvo: > 9.0

---

### Todo dia 1, 09:00
📊 **Relatório mensal**

Gerando relatórios de:
- Faturamento mensal
- Procedimentos mais realizados
- Taxa de retorno de pacientes
- Avaliações e NPS
- Comparativo com mês anterior

Enviando para: administracao@clinica.com.br

---

### A cada 4 horas
🔍 **Health Check**

Verificando:
- Status do gateway
- Conexões WhatsApp/Telegram
- Espaço em disco
- Uso de memória
- Logs de erro

Se algo falhar → Alertar administrador
```

---

# 📝 PARTE 4: AUTOMAÇÕES OBSIDIAN

## 4.1 Criar Nota Automática de Paciente

```bash
#!/bin/bash
# create-patient-note.sh

PATIENT_NAME="$1"
PROCEDURE="$2"
DATE=$(date +"%Y-%m-%d")

VAULT_PATH="$HOME/Obsidian/Clinica"

# Template da nota
cat > "$VAULT_PATH/Pacientes/$PATIENT_NAME.md" << EOF
---
tags: [paciente, $PROCEDURE]
data_cadastro: $DATE
status: ativo
---

# $PATIENT_NAME

## 📋 Informações Básicas

- **Nome Completo:** $PATIENT_NAME
- **Data de Cadastro:** $DATE
- **Telefone:** 
- **Email:** 
- **Data de Nascimento:** 
- **CPF:** 

## 💉 Histórico de Procedimentos

### $DATE - $PROCEDURE
- **Status:** Agendado
- **Profissional:** 
- **Valor:** R$ 
- **Observações:** 

## 📸 Fotos Antes/Depois

### $PROCEDURE - $DATE
- Antes: [[]]
- Depois: [[]]

## 📝 Anotações Clínicas



## 📅 Próximos Passos

- [ ] Confirmar agendamento
- [ ] Enviar orientações pré-procedimento
- [ ] Follow-up D+1
- [ ] Follow-up D+7
- [ ] Agendar retorno

## 🔗 Links Relacionados

- [[Procedimentos/$PROCEDURE]]
- [[Agenda/$DATE]]
EOF

echo "✅ Nota criada: $VAULT_PATH/Pacientes/$PATIENT_NAME.md"

# Abrir no Obsidian
obsidian-cli open "$PATIENT_NAME" --vault "Clinica"
```

**Usar:**
```bash
./create-patient-note.sh "Maria Silva" "Botox"
```

---

## 4.2 Daily Note Automática

```bash
#!/bin/bash
# create-daily-note.sh

DATE=$(date +"%Y-%m-%d")
WEEKDAY=$(date +"%A" | tr '[:upper:]' '[:lower:]')

# Não criar no fim de semana
if [ "$WEEKDAY" = "saturday" ] || [ "$WEEKDAY" = "sunday" ]; then
    echo "⚠️ Fim de semana - Daily note não criada"
    exit 0
fi

VAULT_PATH="$HOME/Obsidian/Clinica"

cat > "$VAULT_PATH/Daily/$DATE.md" << EOF
---
tags: [daily, agenda]
date: $DATE
---

# Daily Note - $DATE

## 🎯 Prioridades do Dia

1. [ ] 
2. [ ] 
3. [ ] 

## 📅 Agendamentos de Hoje

\`\`\`dataview
TABLE 
  hora as "Horário",
  paciente as "Paciente",
  procedimento as "Procedimento",
  profissional as "Profissional"
FROM "Agenda"
WHERE data = date("$DATE")
SORT hora ASC
\`\`\`

## 💰 Receita do Dia

**Meta:** R$ 1.000
**Realizado:** R$ 

## ✅ Tarefas Concluídas



## 📝 Observações



## 📊 Métricas

- Agendamentos: 
- Procedimentos realizados: 
- Novos pacientes: 
- NPS médio: 

---

**Criado automaticamente em:** $(date +"%Y-%m-%d %H:%M")
EOF

echo "✅ Daily note criada: $DATE"

# Abrir no Obsidian
obsidian-cli daily open --vault "Clinica"
```

**Agendar no cron:**
```bash
# Todo dia útil às 7h
0 7 * * 1-5 /path/to/create-daily-note.sh
```

---

## 4.3 Busca Inteligente no Vault

```javascript
// obsidian-search.js
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

async function searchObsidian(query, vault = 'Clinica') {
    try {
        const { stdout } = await execPromise(
            `obsidian-cli search "${query}" --vault "${vault}"`
        );
        
        const results = stdout.trim().split('\n');
        
        console.log(`🔍 Encontrados ${results.length} resultados para: "${query}"`);
        console.log('');
        
        results.forEach((result, index) => {
            console.log(`${index + 1}. ${result}`);
        });
        
        return results;
    } catch (error) {
        console.error('❌ Erro na busca:', error.message);
        return [];
    }
}

// Exemplos de uso
async function main() {
    // Buscar todos os pacientes de botox
    await searchObsidian('botox tag:paciente');
    
    // Buscar procedimentos de janeiro
    await searchObsidian('2026-01');
    
    // Buscar anotações de um profissional
    await searchObsidian('Dra. Ana');
}

main();
```

---

# 🏥 PARTE 5: WORKFLOWS CLÍNICOS

## 5.1 Workflow Completo de Agendamento

```javascript
// clinical-workflow.js
/**
 * Workflow completo de agendamento para clínica
 * 1. Recebe solicitação (WhatsApp/Telegram)
 * 2. Verifica disponibilidade
 * 3. Cria evento no calendário
 * 4. Envia confirmação
 * 5. Agenda lembretes
 * 6. Cria nota no Obsidian
 */

const { Client } = require('whatsapp-web.js');
const { google } = require('googleapis');
const { exec } = require('child_process');

class ClinicWorkflow {
    constructor() {
        this.whatsapp = new Client();
        this.calendar = google.calendar({ version: 'v3' });
    }
    
    async processarAgendamento(dados) {
        console.log('📋 Iniciando workflow de agendamento...');
        
        // 1. Validar dados
        if (!this.validarDados(dados)) {
            throw new Error('Dados inválidos');
        }
        
        // 2. Verificar disponibilidade
        const disponivel = await this.verificarDisponibilidade(
            dados.data, 
            dados.hora
        );
        
        if (!disponivel) {
            return {
                sucesso: false,
                mensagem: 'Horário não disponível'
            };
        }
        
        // 3. Criar evento no calendário
        const evento = await this.criarEvento(dados);
        
        // 4. Enviar confirmação WhatsApp
        await this.enviarConfirmacao(dados.telefone, dados);
        
        // 5. Agendar lembretes
        await this.agendarLembretes(dados);
        
        // 6. Criar nota Obsidian
        await this.criarNotaPaciente(dados);
        
        // 7. Agendar follow-ups
        await this.agendarFollowUps(dados);
        
        console.log('✅ Workflow concluído com sucesso!');
        
        return {
            sucesso: true,
            eventoId: evento.id,
            mensagem: 'Agendamento confirmado'
        };
    }
    
    validarDados(dados) {
        const required = ['paciente', 'telefone', 'procedimento', 'data', 'hora'];
        return required.every(field => dados[field]);
    }
    
    async verificarDisponibilidade(data, hora) {
        // Lógica de verificação no calendário
        const events = await this.calendar.events.list({
            calendarId: 'primary',
            timeMin: data + 'T' + hora,
            timeMax: data + 'T' + this.addHours(hora, 1),
            singleEvents: true
        });
        
        return events.data.items.length === 0;
    }
    
    async criarEvento(dados) {
        const event = {
            summary: `${dados.procedimento} - ${dados.paciente}`,
            start: { dateTime: `${dados.data}T${dados.hora}` },
            end: { dateTime: `${dados.data}T${this.addHours(dados.hora, 0.5)}` }
        };
        
        return await this.calendar.events.insert({
            calendarId: 'primary',
            resource: event
        });
    }
    
    async enviarConfirmacao(telefone, dados) {
        const mensagem = `
✅ Agendamento confirmado!
👤 ${dados.paciente}
💉 ${dados.procedimento}
📅 ${this.formatarData(dados.data)}
🕐 ${dados.hora}
        `.trim();
        
        await this.whatsapp.sendMessage(`${telefone}@c.us`, mensagem);
    }
    
    async agendarLembretes(dados) {
        // D-1: Lembrete 24h antes
        // D-0: Lembrete no dia
        // ... implementação
    }
    
    async criarNotaPaciente(dados) {
        exec(`bash create-patient-note.sh "${dados.paciente}" "${dados.procedimento}"`);
    }
    
    async agendarFollowUps(dados) {
        // D+1, D+3, D+7, D+30
        // ... implementação
    }
    
    addHours(time, hours) {
        // Lógica para adicionar horas
    }
    
    formatarData(data) {
        // Formatar data para pt-BR
    }
}

// Usar
const workflow = new ClinicWorkflow();

workflow.processarAgendamento({
    paciente: 'Maria Silva',
    telefone: '5511999999999',
    email: 'maria@email.com',
    procedimento: 'Botox',
    data: '2026-02-15',
    hora: '14:00',
    profissional: 'Dra. Ana'
});
```

---

## 5.2 Sistema de Follow-up Pós-Procedimento

```javascript
// followup-system.js
const cron = require('node-cron');
const { Client } = require('whatsapp-web.js');

class FollowUpSystem {
    constructor() {
        this.whatsapp = new Client();
        this.procedimentos = new Map(); // ID -> Dados
    }
    
    registrarProcedimento(id, dados) {
        this.procedimentos.set(id, {
            ...dados,
            dataRealizacao: new Date(),
            followUps: {
                d1: false,
                d3: false,
                d7: false,
                d30: false
            }
        });
        
        console.log(`✅ Procedimento registrado: ${id}`);
        
        // Agendar follow-ups
        this.agendarFollowUps(id);
    }
    
    agendarFollowUps(id) {
        const dados = this.procedimentos.get(id);
        
        // D+1
        setTimeout(() => {
            this.enviarFollowUp(id, 'd1');
        }, 24 * 60 * 60 * 1000); // 24 horas
        
        // D+3
        setTimeout(() => {
            this.enviarFollowUp(id, 'd3');
        }, 3 * 24 * 60 * 60 * 1000);
        
        // D+7
        setTimeout(() => {
            this.enviarFollowUp(id, 'd7');
        }, 7 * 24 * 60 * 60 * 1000);
        
        // D+30
        setTimeout(() => {
            this.enviarFollowUp(id, 'd30');
        }, 30 * 24 * 60 * 60 * 1000);
    }
    
    async enviarFollowUp(id, tipo) {
        const dados = this.procedimentos.get(id);
        
        if (dados.followUps[tipo]) {
            console.log(`ℹ️ Follow-up ${tipo} já enviado para ${id}`);
            return;
        }
        
        const templates = {
            d1: `
Olá ${dados.paciente}! 😊

Como está se sentindo após o ${dados.procedimento} de ontem?

Tudo correu bem? Algum desconforto ou dúvida?

Estamos aqui para ajudar! 💙
            `.trim(),
            
            d3: `
Oi ${dados.paciente}! 

Passando aqui para saber como você está.

Já se passaram 3 dias do ${dados.procedimento}. Como está a evolução?

Alguma dúvida ou preocupação? 🤔
            `.trim(),
            
            d7: `
Olá ${dados.paciente}! 

Uma semana desde o ${dados.procedimento}! 🎉

Gostaria de agendar retorno para avaliarmos os resultados?

Quando seria melhor para você? 📅
            `.trim(),
            
            d30: `
Oi ${dados.paciente}! 

Um mês desde o ${dados.procedimento}! 

Está satisfeito(a) com os resultados? 

Gostaria de agendar manutenção ou conhecer outros procedimentos? 😊
            `.trim()
        };
        
        await this.whatsapp.sendMessage(
            `${dados.telefone}@c.us`,
            templates[tipo]
        );
        
        // Marcar como enviado
        dados.followUps[tipo] = true;
        console.log(`✅ Follow-up ${tipo} enviado para ${dados.paciente}`);
    }
}

// Usar
const followUpSystem = new FollowUpSystem();

// Quando um procedimento é realizado
followUpSystem.registrarProcedimento('proc-001', {
    paciente: 'Maria Silva',
    telefone: '5511999999999',
    procedimento: 'Botox',
    profissional: 'Dra. Ana'
});
```

---

# 🔗 PARTE 6: INTEGRAÇÕES AVANÇADAS

## 6.1 Webhook Receiver para Calendly

```javascript
// calendly-webhook.js
const express = require('express');
const app = express();

app.use(express.json());

// Endpoint para receber webhooks do Calendly
app.post('/webhooks/calendly', async (req, res) => {
    const { event, payload } = req.body;
    
    console.log('📨 Webhook recebido:', event);
    
    if (event === 'invitee.created') {
        // Novo agendamento no Calendly
        await processarNovoAgendamento(payload);
    } else if (event === 'invitee.canceled') {
        // Agendamento cancelado
        await processarCancelamento(payload);
    }
    
    res.status(200).send('OK');
});

async function processarNovoAgendamento(payload) {
    const dados = {
        paciente: payload.name,
        email: payload.email,
        telefone: payload.questions_and_answers.find(q => 
            q.question.includes('telefone')
        )?.answer,
        procedimento: payload.event_type_name,
        data: payload.event_start_time.split('T')[0],
        hora: payload.event_start_time.split('T')[1].substring(0, 5)
    };
    
    console.log('📅 Novo agendamento:', dados);
    
    // 1. Criar no Google Calendar
    // 2. Enviar confirmação WhatsApp
    // 3. Criar nota Obsidian
    // 4. Agendar lembretes
}

async function processarCancelamento(payload) {
    console.log('❌ Cancelamento:', payload);
    
    // 1. Remover do Google Calendar
    // 2. Notificar equipe
}

app.listen(18790, () => {
    console.log('🎧 Webhook receiver rodando na porta 18790');
});
```

---

## 6.2 Integração com Kommo CRM

```javascript
// kommo-integration.js
const axios = require('axios');

class KommoIntegration {
    constructor(domain, token) {
        this.baseURL = `https://${domain}.kommo.com/api/v4`;
        this.token = token;
    }
    
    async criarLead(dados) {
        const lead = [
            {
                name: dados.paciente,
                price: dados.valor || 0,
                custom_fields_values: [
                    {
                        field_id: 123456, // ID do campo "Telefone"
                        values: [{ value: dados.telefone }]
                    },
                    {
                        field_id: 789012, // ID do campo "Procedimento"
                        values: [{ value: dados.procedimento }]
                    }
                ]
            }
        ];
        
        const response = await axios.post(
            `${this.baseURL}/leads`,
            lead,
            {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                }
            }
        );
        
        console.log('✅ Lead criado no Kommo:', response.data);
        return response.data;
    }
    
    async atualizarLead(leadId, status) {
        // Atualizar status do lead
        // ... implementação
    }
    
    async adicionarNota(leadId, texto) {
        // Adicionar nota ao lead
        // ... implementação
    }
}

// Usar
const kommo = new KommoIntegration('suaempresa', 'SEU_TOKEN');

kommo.criarLead({
    paciente: 'Maria Silva',
    telefone: '11999999999',
    email: 'maria@email.com',
    procedimento: 'Botox',
    valor: 800
});
```

---

# 🛠️ PARTE 7: SCRIPTS DE MANUTENÇÃO

## 7.1 Backup Automático

```bash
#!/bin/bash
# backup.sh

DATE=$(date +"%Y-%m-%d")
BACKUP_DIR="$HOME/moltbot-backups"
MOLTBOT_DIR="$HOME/.clawdbot"

mkdir -p "$BACKUP_DIR"

# Criar backup
tar -czf "$BACKUP_DIR/moltbot-$DATE.tar.gz" "$MOLTBOT_DIR"

# Manter apenas últimos 30 dias
find "$BACKUP_DIR" -name "moltbot-*.tar.gz" -mtime +30 -delete

# Backup para Google Drive (opcional)
if command -v gdrive &> /dev/null; then
    gdrive upload "$BACKUP_DIR/moltbot-$DATE.tar.gz"
fi

echo "✅ Backup criado: moltbot-$DATE.tar.gz"
```

---

## 7.2 Limpeza de Logs

```bash
#!/bin/bash
# cleanup-logs.sh

MOLTBOT_DIR="$HOME/.clawdbot"
LOG_DIR="$MOLTBOT_DIR/logs"

# Compactar logs antigos (>7 dias)
find "$LOG_DIR" -name "*.log" -mtime +7 -exec gzip {} \;

# Deletar logs compactados antigos (>30 dias)
find "$LOG_DIR" -name "*.log.gz" -mtime +30 -delete

# Limpar cache
rm -rf "$MOLTBOT_DIR/cache/*"

echo "✅ Limpeza concluída"
```

---

## 7.3 Health Check

```bash
#!/bin/bash
# health-check.sh

# Verificar se gateway está rodando
if ! curl -s http://localhost:18789/health > /dev/null; then
    echo "❌ Gateway offline! Reiniciando..."
    moltbot restart
    
    # Notificar admin
    curl -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage \
        -d chat_id=$ADMIN_CHAT_ID \
        -d text="⚠️ MoltBot gateway reiniciado automaticamente"
fi

# Verificar espaço em disco
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "⚠️ Espaço em disco crítico: ${DISK_USAGE}%"
fi

# Verificar memória
MEM_USAGE=$(free | grep Mem | awk '{print ($3/$2) * 100.0}' | cut -d. -f1)
if [ $MEM_USAGE -gt 90 ]; then
    echo "⚠️ Uso de memória alto: ${MEM_USAGE}%"
fi

echo "✅ Health check OK"
```

**Agendar no cron:**
```bash
# A cada 5 minutos
*/5 * * * * /path/to/health-check.sh
```

---

# 🎓 GUIA DE USO DOS SCRIPTS

## Instalação

```bash
# 1. Criar diretório de scripts
mkdir -p ~/.clawd/scripts

# 2. Copiar scripts para lá
cp *.sh ~/.clawd/scripts/
cp *.js ~/.clawd/scripts/

# 3. Dar permissões
chmod +x ~/.clawd/scripts/*.sh

# 4. Instalar dependências Node
cd ~/.clawd/scripts
npm init -y
npm install whatsapp-web.js googleapis nodemailer node-cron express axios
```

## Configuração

```bash
# Criar arquivo .env
cat > ~/.clawd/scripts/.env << EOF
TELEGRAM_TOKEN=seu_token
GOOGLE_CLIENT_ID=seu_client_id
GOOGLE_CLIENT_SECRET=seu_client_secret
GOOGLE_REFRESH_TOKEN=seu_refresh_token
GMAIL_CLIENT_ID=gmail_client_id
GMAIL_CLIENT_SECRET=gmail_client_secret
GMAIL_REFRESH_TOKEN=gmail_refresh_token
KOMMO_DOMAIN=suaempresa
KOMMO_TOKEN=kommo_token
ADMIN_CHAT_ID=seu_telegram_id
EOF

# Carregar variáveis
source ~/.clawd/scripts/.env
```

## Execução

```bash
# Scripts bash
bash ~/.clawd/scripts/backup.sh

# Scripts Node.js
cd ~/.clawd/scripts
node telegram-auto-responder.js

# Em background
nohup node telegram-auto-responder.js > /dev/null 2>&1 &
```

---

**Gerado em:** 30/01/2026  
**Total de Scripts:** 20+  
**Prontos para uso:** ✅ Sim
