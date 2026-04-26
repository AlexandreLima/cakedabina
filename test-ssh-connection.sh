#!/bin/bash

# 🔍 Script para testar conexão SSH com a VPS Hostinger
# Execute antes de fazer deploy

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "================================================"
echo "🔍 SSH Connection Tester - Cake da Bina"
echo "================================================"
echo ""

# Solicitar informações
read -p "IP da VPS (ex: 192.168.1.100): " VPS_HOST
read -p "Usuário SSH (padrão: root): " VPS_USER
VPS_USER=${VPS_USER:-root}
read -p "Porta SSH (padrão: 22): " VPS_SSH_PORT
VPS_SSH_PORT=${VPS_SSH_PORT:-22}

echo ""
echo "================================================"
echo "🧪 Executando Testes"
echo "================================================"
echo ""

# Teste 1: SSH key exists
echo -e "${BLUE}1️⃣  Verificando chave SSH local...${NC}"
if [ -f ~/.ssh/id_ed25519 ]; then
    echo -e "${GREEN}✓ Chave privada encontrada${NC}"
    SSH_KEY="~/.ssh/id_ed25519"
else
    echo -e "${RED}✗ Chave privada NÃO encontrada${NC}"
    echo "Execute: ssh-keygen -t ed25519 -C \"xandebre@gmail.com\" -f ~/.ssh/id_ed25519 -N \"\""
    exit 1
fi

if [ -f ~/.ssh/id_ed25519.pub ]; then
    echo -e "${GREEN}✓ Chave pública encontrada${NC}"
else
    echo -e "${RED}✗ Chave pública NÃO encontrada${NC}"
    exit 1
fi

echo ""

# Teste 2: Conectar SSH simples
echo -e "${BLUE}2️⃣  Testando conexão SSH básica...${NC}"
if timeout 10 ssh -i ~/.ssh/id_ed25519 -p "$VPS_SSH_PORT" -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$VPS_USER@$VPS_HOST" "echo 'OK'" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Conexão SSH bem-sucedida${NC}"
else
    echo -e "${RED}✗ Conexão SSH FALHOU${NC}"
    echo ""
    echo "Diagnóstico:"
    echo "1. Verifique IP: $VPS_HOST"
    echo "2. Verifique usuário: $VPS_USER"
    echo "3. Verifique porta: $VPS_SSH_PORT"
    echo "4. A chave pública está em ~/.ssh/authorized_keys na VPS?"
    echo ""
    echo "Debug com:"
    echo "ssh -i ~/.ssh/id_ed25519 -vvv -p $VPS_SSH_PORT $VPS_USER@$VPS_HOST"
    exit 1
fi

echo ""

# Teste 3: Verificar whoami
echo -e "${BLUE}3️⃣  Verificando usuário remoto...${NC}"
REMOTE_USER=$(ssh -i ~/.ssh/id_ed25519 -p "$VPS_SSH_PORT" -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "whoami" 2>/dev/null)
if [ "$REMOTE_USER" = "$VPS_USER" ]; then
    echo -e "${GREEN}✓ Usuário correto: $REMOTE_USER${NC}"
else
    echo -e "${YELLOW}⚠ Usuário inesperado: $REMOTE_USER${NC}"
fi

echo ""

# Teste 4: Docker
echo -e "${BLUE}4️⃣  Verificando Docker na VPS...${NC}"
if ssh -i ~/.ssh/id_ed25519 -p "$VPS_SSH_PORT" -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "docker --version" > /dev/null 2>&1; then
    DOCKER_VERSION=$(ssh -i ~/.ssh/id_ed25519 -p "$VPS_SSH_PORT" -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "docker --version" 2>/dev/null)
    echo -e "${GREEN}✓ Docker instalado: $DOCKER_VERSION${NC}"
else
    echo -e "${RED}✗ Docker NÃO encontrado na VPS${NC}"
fi

echo ""

# Teste 5: Docker daemon
echo -e "${BLUE}5️⃣  Verificando Docker daemon...${NC}"
if ssh -i ~/.ssh/id_ed25519 -p "$VPS_SSH_PORT" -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "docker ps" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Docker daemon rodando${NC}"
else
    echo -e "${RED}✗ Docker daemon NÃO está rodando${NC}"
    echo "Conecte na VPS e execute: docker start"
fi

echo ""

# Teste 6: Authorized keys
echo -e "${BLUE}6️⃣  Verificando authorized_keys na VPS...${NC}"
if ssh -i ~/.ssh/id_ed25519 -p "$VPS_SSH_PORT" -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "grep -q 'ssh-ed25519' ~/.ssh/authorized_keys" 2>/dev/null; then
    KEY_COUNT=$(ssh -i ~/.ssh/id_ed25519 -p "$VPS_SSH_PORT" -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "grep -c 'ssh-ed25519' ~/.ssh/authorized_keys" 2>/dev/null || echo "0")
    echo -e "${GREEN}✓ Chaves SSH encontradas: $KEY_COUNT${NC}"
else
    echo -e "${RED}✗ Nenhuma chave SSH em authorized_keys${NC}"
    echo ""
    echo "Adicione a chave pública:"
    echo "ssh-copy-id -i ~/.ssh/id_ed25519.pub -p $VPS_SSH_PORT $VPS_USER@$VPS_HOST"
fi

echo ""

# Teste 7: SSH config file
echo -e "${BLUE}7️⃣  Verificando permissões SSH na VPS...${NC}"
SSH_PERMS=$(ssh -i ~/.ssh/id_ed25519 -p "$VPS_SSH_PORT" -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "ls -ld ~/.ssh" 2>/dev/null | awk '{print $1}')
if [ "$SSH_PERMS" = "drwx------" ]; then
    echo -e "${GREEN}✓ Permissões ~/.ssh corretas: $SSH_PERMS${NC}"
else
    echo -e "${YELLOW}⚠ Permissões ~/.ssh: $SSH_PERMS (deveria ser drwx------)${NC}"
fi

AUTH_KEYS_PERMS=$(ssh -i ~/.ssh/id_ed25519 -p "$VPS_SSH_PORT" -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "ls -l ~/.ssh/authorized_keys" 2>/dev/null | awk '{print $1}')
if [ "$AUTH_KEYS_PERMS" = "-rw-------" ]; then
    echo -e "${GREEN}✓ Permissões authorized_keys corretas: $AUTH_KEYS_PERMS${NC}"
else
    echo -e "${YELLOW}⚠ Permissões authorized_keys: $AUTH_KEYS_PERMS (deveria ser -rw-------)${NC}"
fi

echo ""

# Teste 8: Caminho de deploy
echo -e "${BLUE}8️⃣  Verificando caminho de deploy...${NC}"
if ssh -i ~/.ssh/id_ed25519 -p "$VPS_SSH_PORT" -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "[ -d /home/site-cakedabina ]" 2>/dev/null; then
    echo -e "${GREEN}✓ Diretório /home/site-cakedabina existe${NC}"
    DIR_SIZE=$(ssh -i ~/.ssh/id_ed25519 -p "$VPS_SSH_PORT" -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "du -sh /home/site-cakedabina" 2>/dev/null | awk '{print $1}')
    echo "   Tamanho: $DIR_SIZE"
else
    echo -e "${YELLOW}⚠ Diretório /home/site-cakedabina NÃO existe${NC}"
    echo "   Será criado no primeiro deploy"
fi

echo ""

# Summary
echo "================================================"
echo -e "${BLUE}📊 Resumo${NC}"
echo "================================================"
echo ""
echo -e "${GREEN}✅ Todos os testes passaram!${NC}"
echo ""
echo "Próximos passos:"
echo "1. Copiar chave privada para GitHub Secret VPS_SSH_KEY:"
echo "   cat ~/.ssh/id_ed25519"
echo ""
echo "2. Configurar GitHub Secrets:"
echo "   VPS_HOST = $VPS_HOST"
echo "   VPS_USER = $VPS_USER"
echo "   VPS_SSH_PORT = $VPS_SSH_PORT"
echo "   VPS_SSH_KEY = (conteúdo de ~/.ssh/id_ed25519)"
echo ""
echo "3. Fazer push:"
echo "   git push origin main"
echo ""
echo "4. Acompanhar deploy em:"
echo "   https://github.com/AlexandreLima/cakedabina/actions"
echo ""
