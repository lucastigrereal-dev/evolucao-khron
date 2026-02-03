@echo off
REM ========================================
REM MOLTBOT ROADMAP GENERATOR - WINDOWS
REM ========================================

echo.
echo ========================================
echo    MOLTBOT ROADMAP GENERATOR
echo ========================================
echo.

REM Verificar se Python está instalado
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERRO] Python nao encontrado!
    echo Por favor, instale Python 3.8+ de python.org
    pause
    exit /b 1
)

echo [OK] Python encontrado
echo.

REM Executar o gerador
echo Gerando roadmap e sprints...
echo.

python moltbot_roadmap_generator.py --output ./MoltBot-Roadmap --format

if errorlevel 1 (
    echo.
    echo [ERRO] Falha ao gerar roadmap
    pause
    exit /b 1
)

echo.
echo ========================================
echo  ROADMAP GERADO COM SUCESSO!
echo ========================================
echo.
echo Proximo passo:
echo 1. Abra o Obsidian
echo 2. Abra o vault em: %CD%\MoltBot-Roadmap
echo 3. Comece pelo Dashboard.md
echo.

pause
