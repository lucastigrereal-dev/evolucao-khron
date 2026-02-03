#!/usr/bin/env python3
"""
MOLTBOT ROADMAP & SPRINT GENERATOR
Gera roadmap completo e sprints do MoltBot em formato Obsidian
Autor: Claude AI
Data: 30/01/2026
"""

import json
import os
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Any
import argparse


class MoltBotRoadmapGenerator:
    """Gerador de Roadmap e Sprints do MoltBot"""
    
    def __init__(self, output_dir: str = "./MoltBot-Roadmap"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.start_date = datetime.now()
        
        # Estrutura completa do roadmap baseada no manual
        self.roadmap_structure = {
            "Semana 1": {
                "titulo": "FUNDAMENTOS & CONFIGURAÇÃO CORE",
                "duração": "7 dias",
                "sprints": [
                    {
                        "nome": "Sprint 1.1 - Setup Inicial",
                        "dias": 3,
                        "tarefas": [
                            "Instalar Node.js e npm",
                            "Clonar repositório do Moltbot",
                            "Instalar dependências (npm install)",
                            "Verificar pré-requisitos do sistema",
                            "Criar estrutura de pastas"
                        ],
                        "entregaveis": [
                            "Moltbot instalado e funcionando",
                            "Primeiro teste de execução bem-sucedido"
                        ],
                        "comandos": [
                            "git clone https://github.com/user/moltbot",
                            "cd moltbot",
                            "npm install",
                            "npm start"
                        ]
                    },
                    {
                        "nome": "Sprint 1.2 - Configuração Core",
                        "dias": 4,
                        "tarefas": [
                            "Criar arquivo moltbot.json",
                            "Configurar chaves de API (Claude/OpenAI)",
                            "Definir personalidade do bot",
                            "Configurar arquivos de sistema",
                            "Testar comunicação básica"
                        ],
                        "entregaveis": [
                            "moltbot.json configurado",
                            "Bot respondendo comandos básicos"
                        ],
                        "arquivos": [
                            "moltbot.json",
                            "personality.md",
                            "system-prompt.md"
                        ]
                    }
                ]
            },
            "Semana 2": {
                "titulo": "CANAIS DE COMUNICAÇÃO",
                "duração": "7 dias",
                "sprints": [
                    {
                        "nome": "Sprint 2.1 - Telegram Bot",
                        "dias": 3,
                        "tarefas": [
                            "Criar bot no BotFather",
                            "Obter token de API",
                            "Configurar webhook/polling",
                            "Testar envio e recebimento",
                            "Configurar comandos básicos"
                        ],
                        "entregaveis": [
                            "Bot Telegram funcionando",
                            "Responde mensagens em tempo real"
                        ],
                        "skills": ["telegram-bot"]
                    },
                    {
                        "nome": "Sprint 2.2 - WhatsApp & Discord",
                        "dias": 4,
                        "tarefas": [
                            "Configurar WhatsApp Web API",
                            "Criar bot Discord",
                            "Configurar webhooks",
                            "Testar multi-canal",
                            "Sincronizar conversas"
                        ],
                        "entregaveis": [
                            "WhatsApp integrado",
                            "Discord bot ativo",
                            "Multi-canal funcionando"
                        ],
                        "skills": ["whatsapp-bot", "discord-bot"]
                    }
                ]
            },
            "Semana 3": {
                "titulo": "INTEGRAÇÕES ESSENCIAIS",
                "duração": "7 dias",
                "sprints": [
                    {
                        "nome": "Sprint 3.1 - Google Calendar & Email",
                        "dias": 3,
                        "tarefas": [
                            "Configurar OAuth Google",
                            "Integrar Google Calendar API",
                            "Configurar Gmail API",
                            "Criar comandos de agendamento",
                            "Testar criação de eventos"
                        ],
                        "entregaveis": [
                            "Bot cria eventos no Calendar",
                            "Envia emails automaticamente"
                        ],
                        "skills": ["google-calendar", "gmail"]
                    },
                    {
                        "nome": "Sprint 3.2 - Obsidian Integration",
                        "dias": 4,
                        "tarefas": [
                            "Instalar obsidian-cli",
                            "Configurar vaults",
                            "Criar skill de criação de notas",
                            "Implementar templates",
                            "Testar workflows PKM"
                        ],
                        "entregaveis": [
                            "Bot cria notas no Obsidian",
                            "Templates funcionando",
                            "Vault-Analyst operacional"
                        ],
                        "skills": ["obsidian-cli", "vault-analyst"]
                    }
                ]
            },
            "Semana 4": {
                "titulo": "AUTOMAÇÕES INTELIGENTES",
                "duração": "7 dias",
                "sprints": [
                    {
                        "nome": "Sprint 4.1 - Cron Jobs & Heartbeats",
                        "dias": 3,
                        "tarefas": [
                            "Configurar cron jobs",
                            "Criar heartbeats automáticos",
                            "Implementar briefings matinais",
                            "Configurar alertas",
                            "Testar agendamentos"
                        ],
                        "entregaveis": [
                            "Briefings automáticos funcionando",
                            "Alertas configurados",
                            "Sistema de heartbeats ativo"
                        ],
                        "arquivos": ["cron-jobs.json", "heartbeats.json"]
                    },
                    {
                        "nome": "Sprint 4.2 - Follow-ups Automáticos",
                        "dias": 4,
                        "tarefas": [
                            "Criar sistema de follow-ups",
                            "Implementar tracking de tarefas",
                            "Configurar lembretes inteligentes",
                            "Testar workflows completos"
                        ],
                        "entregaveis": [
                            "Follow-ups automáticos",
                            "Sistema de lembretes funcionando"
                        ],
                        "skills": ["task-tracker", "auto-followup"]
                    }
                ]
            },
            "Semana 5-6": {
                "titulo": "SKILLS & PLUGINS AVANÇADOS",
                "duração": "14 dias",
                "sprints": [
                    {
                        "nome": "Sprint 5.1 - ClawdHub Skills",
                        "dias": 5,
                        "tarefas": [
                            "Explorar repositório ClawdHub",
                            "Instalar skills essenciais",
                            "Testar cada skill",
                            "Documentar uso de cada skill"
                        ],
                        "entregaveis": [
                            "Lista de skills instaladas",
                            "Documentação de uso"
                        ],
                        "skills": [
                            "web-search",
                            "file-manager",
                            "code-executor",
                            "image-gen"
                        ]
                    },
                    {
                        "nome": "Sprint 5.2 - Skills Customizadas",
                        "dias": 9,
                        "tarefas": [
                            "Estudar estrutura de skills",
                            "Criar primeira skill custom",
                            "Testar e debugar",
                            "Documentar skill",
                            "Publicar no ClawdHub (opcional)"
                        ],
                        "entregaveis": [
                            "Mínimo 2 skills customizadas",
                            "Documentação completa"
                        ],
                        "arquivos": ["custom-skills/"]
                    }
                ]
            },
            "Semana 7-8": {
                "titulo": "MULTI-AGENTES & ARQUITETURA AVANÇADA",
                "duração": "14 dias",
                "sprints": [
                    {
                        "nome": "Sprint 6.1 - Sub-agentes Especializados",
                        "dias": 7,
                        "tarefas": [
                            "Criar agente especializado em código",
                            "Criar agente de análise de dados",
                            "Criar agente de redação",
                            "Implementar roteamento inteligente",
                            "Testar comunicação entre agentes"
                        ],
                        "entregaveis": [
                            "Mínimo 3 sub-agentes funcionando",
                            "Sistema de roteamento operacional"
                        ],
                        "arquivos": ["agents/", "routing.json"]
                    },
                    {
                        "nome": "Sprint 6.2 - Otimização & Performance",
                        "dias": 7,
                        "tarefas": [
                            "Otimizar uso de tokens",
                            "Implementar cache",
                            "Melhorar tempos de resposta",
                            "Monitorar performance",
                            "Documentar arquitetura final"
                        ],
                        "entregaveis": [
                            "Sistema otimizado",
                            "Documentação completa da arquitetura",
                            "Relatório de performance"
                        ],
                        "metricas": [
                            "Tempo médio de resposta < 2s",
                            "Uso de memória < 500MB",
                            "Taxa de sucesso > 95%"
                        ]
                    }
                ]
            }
        }
        
        # Skills essenciais do MoltBot
        self.essential_skills = {
            "Comunicação": [
                "telegram-bot",
                "whatsapp-bot",
                "discord-bot",
                "gmail",
                "slack-bot"
            ],
            "Produtividade": [
                "google-calendar",
                "obsidian-cli",
                "notion",
                "task-manager",
                "vault-analyst"
            ],
            "Automação": [
                "cron-scheduler",
                "heartbeat-monitor",
                "auto-followup",
                "webhook-handler"
            ],
            "Desenvolvimento": [
                "code-executor",
                "git-manager",
                "file-ops",
                "terminal-access"
            ],
            "IA & Análise": [
                "web-search",
                "data-analyzer",
                "image-gen",
                "pdf-reader",
                "csv-processor"
            ]
        }
        
    def gerar_roadmap_completo(self) -> str:
        """Gera arquivo markdown com roadmap completo"""
        md = f"""# 🚀 MOLTBOT - ROADMAP COMPLETO
        
> **Gerado em:** {datetime.now().strftime('%d/%m/%Y %H:%M')}  
> **Duração Total:** 8 semanas  
> **Objetivo:** Implementação completa do MoltBot Enterprise

---

## 📊 VISÃO GERAL

```mermaid
gantt
    title Roadmap MoltBot - 8 Semanas
    dateFormat YYYY-MM-DD
    section Fundamentos
    Setup Inicial           :s1, {self._format_date(0)}, 3d
    Configuração Core       :s2, after s1, 4d
    section Comunicação
    Telegram Bot           :s3, after s2, 3d
    WhatsApp & Discord     :s4, after s3, 4d
    section Integrações
    Calendar & Email       :s5, after s4, 3d
    Obsidian Integration   :s6, after s5, 4d
    section Automações
    Cron & Heartbeats      :s7, after s6, 3d
    Follow-ups Auto        :s8, after s7, 4d
    section Skills
    ClawdHub Skills        :s9, after s8, 5d
    Skills Custom          :s10, after s9, 9d
    section Avançado
    Multi-agentes          :s11, after s10, 7d
    Otimização             :s12, after s11, 7d
```

---

## 🎯 OBJETIVO POR SEMANA

"""
        
        # Adicionar cada semana
        for semana, dados in self.roadmap_structure.items():
            md += f"### {semana}: {dados['titulo']}\n\n"
            md += f"**Duração:** {dados['duração']}\n\n"
            
            for sprint in dados['sprints']:
                md += f"#### {sprint['nome']} ({sprint['dias']} dias)\n\n"
                
                # Tarefas
                md += "**📋 Tarefas:**\n"
                for tarefa in sprint['tarefas']:
                    md += f"- [ ] {tarefa}\n"
                md += "\n"
                
                # Entregáveis
                md += "**✅ Entregáveis:**\n"
                for entregavel in sprint['entregaveis']:
                    md += f"- {entregavel}\n"
                md += "\n"
                
                # Comandos (se houver)
                if 'comandos' in sprint:
                    md += "**💻 Comandos:**\n```bash\n"
                    for cmd in sprint['comandos']:
                        md += f"{cmd}\n"
                    md += "```\n\n"
                
                # Skills (se houver)
                if 'skills' in sprint:
                    md += "**🔧 Skills necessárias:**\n"
                    for skill in sprint['skills']:
                        md += f"- `{skill}`\n"
                    md += "\n"
                
                # Arquivos (se houver)
                if 'arquivos' in sprint:
                    md += "**📁 Arquivos a criar:**\n"
                    for arquivo in sprint['arquivos']:
                        md += f"- `{arquivo}`\n"
                    md += "\n"
                
                # Métricas (se houver)
                if 'metricas' in sprint:
                    md += "**📈 Métricas de sucesso:**\n"
                    for metrica in sprint['metricas']:
                        md += f"- {metrica}\n"
                    md += "\n"
                
                md += "---\n\n"
        
        # Skills essenciais
        md += "\n## 🛠️ SKILLS ESSENCIAIS\n\n"
        for categoria, skills in self.essential_skills.items():
            md += f"### {categoria}\n\n"
            for skill in skills:
                md += f"- [ ] `{skill}`\n"
            md += "\n"
        
        # Checklist geral
        md += self._gerar_checklist_geral()
        
        return md
    
    def gerar_sprints_detalhados(self) -> Dict[str, str]:
        """Gera arquivos individuais para cada sprint"""
        sprints_files = {}
        sprint_numero = 1
        
        for semana, dados in self.roadmap_structure.items():
            for sprint in dados['sprints']:
                filename = f"Sprint-{sprint_numero:02d}-{self._slug(sprint['nome'])}.md"
                
                md = f"""# {sprint['nome']}

> **Semana:** {semana}  
> **Duração:** {sprint['dias']} dias  
> **Data Início:** {self._calcular_data_sprint(sprint_numero)}

---

## 📋 TAREFAS

"""
                # Tarefas com checkboxes
                for i, tarefa in enumerate(sprint['tarefas'], 1):
                    md += f"{i}. [ ] {tarefa}\n"
                
                md += "\n---\n\n## ✅ ENTREGÁVEIS\n\n"
                for entregavel in sprint['entregaveis']:
                    md += f"- [ ] {entregavel}\n"
                
                # Seções adicionais
                if 'comandos' in sprint:
                    md += "\n---\n\n## 💻 COMANDOS\n\n```bash\n"
                    for cmd in sprint['comandos']:
                        md += f"{cmd}\n"
                    md += "```\n"
                
                if 'skills' in sprint:
                    md += "\n---\n\n## 🔧 SKILLS NECESSÁRIAS\n\n"
                    for skill in sprint['skills']:
                        md += f"- [ ] `{skill}`\n"
                
                if 'arquivos' in sprint:
                    md += "\n---\n\n## 📁 ARQUIVOS A CRIAR\n\n"
                    for arquivo in sprint['arquivos']:
                        md += f"- [ ] `{arquivo}`\n"
                
                if 'metricas' in sprint:
                    md += "\n---\n\n## 📈 MÉTRICAS DE SUCESSO\n\n"
                    for metrica in sprint['metricas']:
                        md += f"- [ ] {metrica}\n"
                
                # Notas e observações
                md += "\n---\n\n## 📝 NOTAS\n\n<!-- Adicione suas observações aqui -->\n\n"
                md += "---\n\n## ⏭️ PRÓXIMO SPRINT\n\n"
                
                if sprint_numero < self._contar_total_sprints():
                    md += f"[[Sprint-{sprint_numero+1:02d}]]\n"
                else:
                    md += "✅ **Roadmap completo!**\n"
                
                sprints_files[filename] = md
                sprint_numero += 1
        
        return sprints_files
    
    def gerar_dashboard_obsidian(self) -> str:
        """Gera dashboard principal para Obsidian"""
        md = f"""# 🎛️ MOLTBOT - DASHBOARD PRINCIPAL

> **Última Atualização:** {datetime.now().strftime('%d/%m/%Y %H:%M')}

---

## 📊 PROGRESSO GERAL

```dataview
TABLE
  file.name as "Sprint",
  length(filter(file.tasks.text, (t) => t.completed)) as "Concluídas",
  length(file.tasks.text) as "Total",
  round((length(filter(file.tasks.text, (t) => t.completed)) / length(file.tasks.text)) * 100, 1) + "%" as "Progresso"
FROM "Sprints"
WHERE file.name != "Dashboard"
SORT file.name ASC
```

---

## 🚦 STATUS RÁPIDO

### ✅ Concluído
<!-- Adicionar sprints concluídos aqui -->

### 🔄 Em Progresso
<!-- Sprint atual -->

### 📅 Planejado
<!-- Próximos sprints -->

---

## 🎯 OBJETIVOS DA SEMANA

- [ ] 
- [ ] 
- [ ] 

---

## 📌 LINKS RÁPIDOS

### Documentação
- [[ROADMAP-Completo]]
- [[Skills-Essenciais]]
- [[Checklist-Geral]]

### Sprints
"""
        # Adicionar links para todos os sprints
        sprint_num = 1
        for semana, dados in self.roadmap_structure.items():
            md += f"\n#### {semana}\n"
            for sprint in dados['sprints']:
                md += f"- [[Sprint-{sprint_num:02d}-{self._slug(sprint['nome'])}]]\n"
                sprint_num += 1
        
        md += """

---

## 📈 MÉTRICAS

### Esta Semana
- **Tarefas Concluídas:** 0
- **Horas Trabalhadas:** 0
- **Skills Instaladas:** 0

### Total
- **Progresso Geral:** 0%
- **Sprints Concluídos:** 0 / """ + str(self._contar_total_sprints()) + """

---

## 🔔 ALERTAS

<!-- Observações importantes -->

"""
        return md
    
    def gerar_checklist_geral(self) -> str:
        """Gera checklist completo de implementação"""
        md = """# ✅ CHECKLIST GERAL - IMPLEMENTAÇÃO MOLTBOT

> Use este documento para acompanhar todo o progresso

---

## 🔧 SETUP INICIAL

- [ ] Node.js instalado (v18+)
- [ ] npm instalado
- [ ] Git instalado
- [ ] Repositório clonado
- [ ] Dependências instaladas
- [ ] Primeiro teste executado

---

## 🔑 CONFIGURAÇÕES

- [ ] moltbot.json criado
- [ ] API Key Claude configurada
- [ ] API Key OpenAI configurada (opcional)
- [ ] Personalidade definida
- [ ] System prompt configurado

---

## 📱 CANAIS

- [ ] Telegram Bot criado
- [ ] WhatsApp conectado
- [ ] Discord Bot criado
- [ ] Gmail integrado
- [ ] Webhooks configurados

---

## 🔗 INTEGRAÇÕES

- [ ] Google Calendar
- [ ] Obsidian CLI
- [ ] CRM (Kommo)
- [ ] Notion (opcional)
- [ ] Slack (opcional)

---

## ⚙️ AUTOMAÇÕES

- [ ] Cron jobs configurados
- [ ] Heartbeats ativos
- [ ] Briefings matinais
- [ ] Follow-ups automáticos
- [ ] Alertas inteligentes

---

## 🛠️ SKILLS

"""
        for categoria, skills in self.essential_skills.items():
            md += f"\n### {categoria}\n\n"
            for skill in skills:
                md += f"- [ ] {skill}\n"
        
        md += """

---

## 🤖 MULTI-AGENTES

- [ ] Agente de código
- [ ] Agente de análise
- [ ] Agente de redação
- [ ] Sistema de roteamento
- [ ] Comunicação entre agentes

---

## 📊 OTIMIZAÇÃO

- [ ] Cache implementado
- [ ] Performance monitorada
- [ ] Tokens otimizados
- [ ] Logs configurados
- [ ] Backup automático

"""
        return md
    
    def _gerar_checklist_geral(self) -> str:
        """Wrapper interno"""
        return "\n---\n\n" + self.gerar_checklist_geral()
    
    def salvar_todos_arquivos(self):
        """Salva todos os arquivos gerados"""
        print(f"📁 Criando estrutura em: {self.output_dir}")
        
        # Criar subpastas
        sprints_dir = self.output_dir / "Sprints"
        sprints_dir.mkdir(exist_ok=True)
        
        # 1. Roadmap completo
        roadmap_file = self.output_dir / "ROADMAP-Completo.md"
        with open(roadmap_file, 'w', encoding='utf-8') as f:
            f.write(self.gerar_roadmap_completo())
        print(f"✅ {roadmap_file}")
        
        # 2. Dashboard
        dashboard_file = self.output_dir / "Dashboard.md"
        with open(dashboard_file, 'w', encoding='utf-8') as f:
            f.write(self.gerar_dashboard_obsidian())
        print(f"✅ {dashboard_file}")
        
        # 3. Checklist geral
        checklist_file = self.output_dir / "Checklist-Geral.md"
        with open(checklist_file, 'w', encoding='utf-8') as f:
            f.write(self.gerar_checklist_geral())
        print(f"✅ {checklist_file}")
        
        # 4. Sprints individuais
        sprints = self.gerar_sprints_detalhados()
        for filename, content in sprints.items():
            sprint_file = sprints_dir / filename
            with open(sprint_file, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ {sprint_file}")
        
        # 5. README
        readme_file = self.output_dir / "README.md"
        with open(readme_file, 'w', encoding='utf-8') as f:
            f.write(self._gerar_readme())
        print(f"✅ {readme_file}")
        
        print(f"\n🎉 Gerados {len(sprints) + 4} arquivos com sucesso!")
        print(f"\n📂 Estrutura criada em: {self.output_dir.absolute()}")
        print("\n📝 Próximos passos:")
        print("1. Abra o Obsidian")
        print(f"2. Abra o vault em: {self.output_dir.absolute()}")
        print("3. Comece pelo Dashboard.md")
    
    def _gerar_readme(self) -> str:
        """Gera README do roadmap"""
        return f"""# 🚀 MoltBot - Roadmap de Implementação

Este vault contém o roadmap completo para implementação do MoltBot Enterprise.

## 📁 Estrutura

```
MoltBot-Roadmap/
├── Dashboard.md              # Dashboard principal
├── ROADMAP-Completo.md      # Roadmap detalhado
├── Checklist-Geral.md       # Checklist de progresso
├── README.md                # Este arquivo
└── Sprints/                 # Sprints individuais
    ├── Sprint-01-...md
    ├── Sprint-02-...md
    └── ...
```

## 🎯 Como Usar

1. **Comece pelo Dashboard.md**
   - Visão geral do progresso
   - Links rápidos para todos os sprints

2. **Consulte o ROADMAP-Completo.md**
   - Visão estratégica completa
   - Timeline e dependências

3. **Trabalhe nos Sprints**
   - Execute cada sprint em ordem
   - Marque as tarefas conforme completa

4. **Acompanhe no Checklist-Geral.md**
   - Visão macro do progresso
   - Items essenciais

## 📊 Progresso

- **Total de Sprints:** {self._contar_total_sprints()}
- **Duração:** 8 semanas
- **Data de Início:** {self.start_date.strftime('%d/%m/%Y')}
- **Data Prevista de Conclusão:** {(self.start_date + timedelta(weeks=8)).strftime('%d/%m/%Y')}

## 🛠️ Ferramentas Necessárias

- Node.js v18+
- Obsidian (para visualizar este roadmap)
- Git
- Claude API Key ou OpenAI API Key

## 📞 Suporte

- Documentação: [MoltBot Docs]
- Issues: [GitHub Issues]
- Comunidade: [Discord/Telegram]

---

**Gerado em:** {datetime.now().strftime('%d/%m/%Y %H:%M')}
**Versão:** 2.0
"""
    
    # Métodos auxiliares
    def _format_date(self, days_offset: int) -> str:
        """Formata data para o gantt chart"""
        date = self.start_date + timedelta(days=days_offset)
        return date.strftime('%Y-%m-%d')
    
    def _calcular_data_sprint(self, sprint_num: int) -> str:
        """Calcula data de início do sprint"""
        dias_acumulados = 0
        sprint_atual = 1
        
        for semana, dados in self.roadmap_structure.items():
            for sprint in dados['sprints']:
                if sprint_atual == sprint_num:
                    data = self.start_date + timedelta(days=dias_acumulados)
                    return data.strftime('%d/%m/%Y')
                dias_acumulados += sprint['dias']
                sprint_atual += 1
        
        return "Data não encontrada"
    
    def _contar_total_sprints(self) -> int:
        """Conta total de sprints"""
        total = 0
        for semana, dados in self.roadmap_structure.items():
            total += len(dados['sprints'])
        return total
    
    def _slug(self, text: str) -> str:
        """Converte texto em slug"""
        import re
        text = text.lower()
        text = re.sub(r'[^\w\s-]', '', text)
        text = re.sub(r'[-\s]+', '-', text)
        return text.strip('-')


def main():
    """Função principal"""
    parser = argparse.ArgumentParser(
        description='MoltBot Roadmap & Sprint Generator',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemplos de uso:
  python moltbot_roadmap_generator.py
  python moltbot_roadmap_generator.py --output ~/Obsidian/MoltBot
  python moltbot_roadmap_generator.py --output ./Roadmap --format
        """
    )
    
    parser.add_argument(
        '--output', '-o',
        default='./MoltBot-Roadmap',
        help='Diretório de saída (padrão: ./MoltBot-Roadmap)'
    )
    
    parser.add_argument(
        '--format', '-f',
        action='store_true',
        help='Formata saída com cores e emojis'
    )
    
    args = parser.parse_args()
    
    # Banner
    print("=" * 60)
    print("🤖 MOLTBOT - ROADMAP & SPRINT GENERATOR")
    print("=" * 60)
    print()
    
    # Criar gerador
    generator = MoltBotRoadmapGenerator(output_dir=args.output)
    
    # Gerar arquivos
    generator.salvar_todos_arquivos()
    
    print("\n" + "=" * 60)
    print("✅ PROCESSO CONCLUÍDO COM SUCESSO!")
    print("=" * 60)


if __name__ == "__main__":
    main()
