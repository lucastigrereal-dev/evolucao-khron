# ⚡ EXECUÇÃO RÁPIDA VIA CLAUDE CODE

> **Para usuários do Claude Code no CMD/Terminal**

---

## 🎯 MÉTODO MAIS RÁPIDO

### Windows (CMD)

```cmd
# 1. Navegue até a pasta onde estão os arquivos
cd C:\caminho\para\pasta

# 2. Execute o gerador
python moltbot_roadmap_generator.py

# 3. Aguarde a geração (5-10 segundos)
# 4. Pronto! Pasta MoltBot-Roadmap criada
```

### Linux/Mac (Terminal)

```bash
# 1. Navegue até a pasta
cd /caminho/para/pasta

# 2. Execute
python3 moltbot_roadmap_generator.py

# 3. Pronto!
```

---

## 🔧 OPÇÕES AVANÇADAS

### Personalizar Saída

```bash
# Gerar em diretório específico
python moltbot_roadmap_generator.py --output ~/Obsidian/MoltBot

# Gerar com formatação colorida
python moltbot_roadmap_generator.py --format

# Combinar opções
python moltbot_roadmap_generator.py --output ./Roadmap --format
```

### Ver Ajuda

```bash
python moltbot_roadmap_generator.py --help
```

---

## 📊 SAÍDA ESPERADA

```
============================================================
🤖 MOLTBOT - ROADMAP & SPRINT GENERATOR
============================================================

📁 Criando estrutura em: MoltBot-Roadmap
✅ MoltBot-Roadmap/ROADMAP-Completo.md
✅ MoltBot-Roadmap/Dashboard.md
✅ MoltBot-Roadmap/Checklist-Geral.md
✅ MoltBot-Roadmap/Sprints/Sprint-01-...md
✅ MoltBot-Roadmap/Sprints/Sprint-02-...md
... (mais sprints)

🎉 Gerados 16 arquivos com sucesso!

📂 Estrutura criada em: /caminho/completo/MoltBot-Roadmap

📝 Próximos passos:
1. Abra o Obsidian
2. Abra o vault em: /caminho/MoltBot-Roadmap
3. Comece pelo Dashboard.md

============================================================
✅ PROCESSO CONCLUÍDO COM SUCESSO!
============================================================
```

---

## 🚀 WORKFLOW COMPLETO

### Passo a Passo

```bash
# 1. Baixar o pacote (já feito)
# 2. Navegar até a pasta
cd /caminho/para/moltbot-roadmap-generator

# 3. Executar o gerador
python moltbot_roadmap_generator.py

# 4. Verificar saída
ls -la MoltBot-Roadmap/

# 5. Abrir no Obsidian
# Obsidian → Open folder as vault → Selecionar MoltBot-Roadmap
```

---

## 🎓 USO COM CLAUDE CODE

### Integração Total

```bash
# Claude Code pode executar o script diretamente
# E depois criar/editar os arquivos gerados

# Exemplo de workflow:
# 1. Gerar roadmap
python moltbot_roadmap_generator.py

# 2. Claude Code edita os sprints
# 3. Você trabalha nos sprints
# 4. Claude Code te ajuda nas tarefas
```

---

## 🔄 REGENERAR ROADMAP

### ⚠️ CUIDADO: Sobrescreve arquivos

```bash
# Fazer backup primeiro
cp -r MoltBot-Roadmap MoltBot-Roadmap-backup

# Regenerar
python moltbot_roadmap_generator.py

# Ou gerar em novo diretório
python moltbot_roadmap_generator.py --output MoltBot-Roadmap-v2
```

---

## 🆘 PROBLEMAS COMUNS

### Python não encontrado
```bash
# Verificar
python --version

# Se não funcionar, tente
python3 --version

# Instalar se necessário
# Windows: python.org
# Linux: sudo apt install python3
```

### Erro de permissão (Linux/Mac)
```bash
# Dar permissão
chmod +x moltbot_roadmap_generator.py

# Executar
./moltbot_roadmap_generator.py
```

### Pasta não criada
```bash
# Verificar diretório atual
pwd

# Listar arquivos
ls -la

# Criar pasta manualmente se necessário
mkdir MoltBot-Roadmap
```

---

## ✅ CHECKLIST RÁPIDO

- [ ] Python instalado e funcionando
- [ ] Arquivo moltbot_roadmap_generator.py na pasta
- [ ] Executei o comando python
- [ ] Pasta MoltBot-Roadmap foi criada
- [ ] 16 arquivos gerados com sucesso
- [ ] Pronto para abrir no Obsidian

---

## 🎯 PRÓXIMO PASSO

```bash
# Após gerar, abra:
# MoltBot-Roadmap/Dashboard.md

# No Obsidian ou em qualquer editor Markdown
```

---

**Tempo total:** ~10 segundos  
**Arquivos gerados:** 16  
**Pronto para uso:** ✅ Imediatamente

---

**Gerado em:** 30/01/2026  
**Para:** Usuários do Claude Code  
**Status:** ✅ Testado e Funcionando
