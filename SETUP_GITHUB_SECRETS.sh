#!/bin/bash

# 🔐 Script para configurar GitHub Secrets para o Cake da Bina CI/CD
# Este script ajuda a extrair as informações necessárias para configurar
# os secrets no GitHub Actions

set -e

echo "================================================"
echo "🔐 Setup GitHub Secrets - Cake da Bina"
echo "================================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. Verificar chave SSH
echo -e "${BLUE}1️⃣  Verificando chave SSH...${NC}"
if [ -f "$HOME/.ssh/id_ed25519" ]; then
    echo -e "${GREEN}✓ Chave SSH encontrada${NC}"
    SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
    echo -e "${YELLOW}Caminho: $SSH_KEY_PATH${NC}"
else
    echo -e "${RED}✗ Chave SSH não encontrada${NC}"
    echo "Gerando nova chave SSH..."
    ssh-keygen -t ed25519 -C "xandebre@gmail.com" -f "$HOME/.ssh/id_ed25519" -N ""
    echo -e "${GREEN}✓ Chave SSH criada${NC}"
fi

echo ""

# 2. Solicitar informações da VPS
echo -e "${BLUE}2️⃣  Informações da VPS Hostinger${NC}"
read -p "IP ou domínio da VPS (ex: 192.168.1.100): " VPS_HOST
read -p "Usuário SSH (padrão: root): " VPS_USER
VPS_USER=${VPS_USER:-root}
read -p "Porta SSH (padrão: 22): " VPS_SSH_PORT
VPS_SSH_PORT=${VPS_SSH_PORT:-22}

echo ""

# 3. Preparar chave SSH privada
echo -e "${BLUE}3️⃣  Preparando chave SSH privada${NC}"
echo -e "${YELLOW}⚠️  IMPORTANTE: Não compartilhe essa chave com ninguém!${NC}"
echo ""

SSH_KEY_CONTENT=$(cat "$SSH_KEY_PATH")

echo -e "${GREEN}✓ Chave SSH privada pronta${NC}"
echo ""

# 4. Mostrar instruções
echo -e "${BLUE}4️⃣  Próximas etapas:${NC}"
echo ""
echo "1. Acesse seu repositório GitHub:"
echo "   https://github.com/AlexandreLima/cakedabina"
echo ""
echo "2. Vá para Settings → Secrets and variables → Actions"
echo ""
echo "3. Clique em 'New repository secret' e adicione:"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}Secret 1:${NC} VPS_HOST"
echo "Valor: $VPS_HOST"
echo ""
echo -e "${YELLOW}Secret 2:${NC} VPS_USER"
echo "Valor: $VPS_USER"
echo ""
echo -e "${YELLOW}Secret 3:${NC} VPS_SSH_PORT"
echo "Valor: $VPS_SSH_PORT"
echo ""
echo -e "${YELLOW}Secret 4:${NC} VPS_SSH_KEY"
echo "Valor: (copie todo o conteúdo abaixo)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "$SSH_KEY_CONTENT"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 5. Preparar chave pública para VPS
echo -e "${BLUE}5️⃣  Chave pública para adicionar à VPS${NC}"
echo ""
echo "Execute na sua VPS ou adicione este conteúdo a ~/.ssh/authorized_keys:"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    cat "$HOME/.ssh/id_ed25519.pub"
else
    echo "Chave pública não encontrada. Gere a chave SSH primeiro."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 6. Copiar para clipboard (opcional)
echo -e "${BLUE}6️⃣  Copiar informações?${NC}"
if command -v xclip &> /dev/null; then
    read -p "Copiar chave SSH privada para clipboard? (s/n): " COPY_SSH
    if [ "$COPY_SSH" = "s" ] || [ "$COPY_SSH" = "S" ]; then
        echo "$SSH_KEY_CONTENT" | xclip -selection clipboard
        echo -e "${GREEN}✓ Chave copiada para clipboard${NC}"
    fi
elif command -v pbcopy &> /dev/null; then
    read -p "Copiar chave SSH privada para clipboard? (s/n): " COPY_SSH
    if [ "$COPY_SSH" = "s" ] || [ "$COPY_SSH" = "S" ]; then
        echo "$SSH_KEY_CONTENT" | pbcopy
        echo -e "${GREEN}✓ Chave copiada para clipboard${NC}"
    fi
else
    echo "xclip não disponível. Copie manualmente o conteúdo acima."
fi

echo ""
echo "================================================"
echo -e "${GREEN}✓ Setup concluído!${NC}"
echo "================================================"
echo ""
echo "Próximos passos:"
echo "1. Configure os 4 secrets no GitHub"
echo "2. Faça o teste adicionar a chave pública à VPS"
echo "3. Execute: git push origin main"
echo "4. Acompanhe o deploy em: github.com/AlexandreLima/cakedabina/actions"
echo ""
