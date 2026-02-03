#!/bin/bash

# ========================================
# MOLTBOT ROADMAP GENERATOR - LINUX/MAC
# ========================================

echo ""
echo "========================================"
echo "   MOLTBOT ROADMAP GENERATOR"
echo "========================================"
echo ""

# Verificar se Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "[ERRO] Python3 não encontrado!"
    echo "Por favor, instale Python 3.8+ de python.org"
    exit 1
fi

echo "[OK] Python3 encontrado"
echo ""

# Executar o gerador
echo "Gerando roadmap e sprints..."
echo ""

python3 moltbot_roadmap_generator.py --output ./MoltBot-Roadmap --format

if [ $? -ne 0 ]; then
    echo ""
    echo "[ERRO] Falha ao gerar roadmap"
    exit 1
fi

echo ""
echo "========================================"
echo " ROADMAP GERADO COM SUCESSO!"
echo "========================================"
echo ""
echo "Próximo passo:"
echo "1. Abra o Obsidian"
echo "2. Abra o vault em: $(pwd)/MoltBot-Roadmap"
echo "3. Comece pelo Dashboard.md"
echo ""
