#!/bin/bash

# ✅ Script para validar a configuração do CI/CD
# Execute localmente antes de fazer push para GitHub

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "================================================"
echo "✅ Validação de Setup - Cake da Bina CI/CD"
echo "================================================"
echo ""

CHECKS_PASSED=0
CHECKS_FAILED=0

check() {
    local name=$1
    local command=$2

    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $name"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
}

# 1. Git
echo -e "${BLUE}1️⃣  Verificando Git${NC}"
check "Git instalado" "command -v git"
check "Repositório Git inicializado" "git rev-parse --git-dir"
check "Remote 'origin' configurado" "git config --get remote.origin.url"
echo ""

# 2. Docker
echo -e "${BLUE}2️⃣  Verificando Docker${NC}"
check "Docker instalado" "command -v docker"
check "Docker daemon rodando" "docker ps"
check "Dockerfile existe" "[ -f Dockerfile ]"
check ".dockerignore existe" "[ -f .dockerignore ]"
echo ""

# 3. GitHub Actions
echo -e "${BLUE}3️⃣  Verificando GitHub Actions${NC}"
check "Workflow existe" "[ -f .github/workflows/deploy.yml ]"
check "Workflow YAML válido" "grep -q 'name:' .github/workflows/deploy.yml"
check "Testes no workflow" "grep -q 'test:' .github/workflows/deploy.yml"
check "Deploy no workflow" "grep -q 'deploy:' .github/workflows/deploy.yml"
echo ""

# 4. Arquivos do projeto
echo -e "${BLUE}4️⃣  Verificando arquivos do projeto${NC}"
check "index.html existe" "[ -f index.html ]"
check "styles.css existe" "[ -f styles.css ]"
check "script.js existe" "[ -f script.js ]"
check "nginx.conf existe" "[ -f nginx.conf ]"
check "site.webmanifest existe" "[ -f site.webmanifest ]"
check "sitemap.xml existe" "[ -f sitemap.xml ]"
check "robots.txt existe" "[ -f robots.txt ]"
check "images/ existe" "[ -d images ]"
check "assets/ existe" "[ -d assets ]"
echo ""

# 5. Configuração Docker Compose
echo -e "${BLUE}5️⃣  Verificando Docker Compose${NC}"
check "docker-compose.yml existe" "[ -f docker-compose.yml ]"
check "docker-compose.prod.yml existe" "[ -f docker-compose.prod.yml ]"
check "docker-compose.yml YAML válido" "docker-compose -f docker-compose.yml config > /dev/null"
check "docker-compose.prod.yml YAML válido" "docker-compose -f docker-compose.prod.yml config > /dev/null"
echo ""

# 6. Documentação
echo -e "${BLUE}6️⃣  Verificando documentação${NC}"
check "DEPLOYMENT.md existe" "[ -f DEPLOYMENT.md ]"
check "QUICK_REFERENCE.md existe" "[ -f QUICK_REFERENCE.md ]"
check "SETUP_GITHUB_SECRETS.sh existe" "[ -f SETUP_GITHUB_SECRETS.sh ]"
echo ""

# 7. Configuração Git
echo -e "${BLUE}7️⃣  Verificando .gitignore${NC}"
check ".gitignore existe" "[ -f .gitignore ]"
check ".gitignore contém node_modules" "grep -q 'node_modules' .gitignore"
check ".gitignore contém .env" "grep -q '.env' .gitignore"
echo ""

# 8. SSH (Local)
echo -e "${BLUE}8️⃣  Verificando SSH (Local)${NC}"
check "SSH key privada existe" "[ -f ~/.ssh/id_ed25519 ]"
check "SSH key pública existe" "[ -f ~/.ssh/id_ed25519.pub ]"
echo ""

# 9. Syntax checks
echo -e "${BLUE}9️⃣  Verificando sintaxe${NC}"
check "HTML válido (básico)" "grep -q '<!DOCTYPE html>' index.html"
check "Nginx config sintaxe" "nginx -t > /dev/null 2>&1 || echo 'nginx não instalado'"
echo ""

# 10. Informações úteis
echo -e "${BLUE}🔟 Informações importantes${NC}"

# Tamanho dos arquivos
HTML_SIZE=$(du -h index.html | cut -f1)
CSS_SIZE=$(du -h styles.css | cut -f1)
JS_SIZE=$(du -h script.js | cut -f1)

echo -e "   index.html:   $HTML_SIZE"
echo -e "   styles.css:   $CSS_SIZE"
echo -e "   script.js:    $JS_SIZE"

# Contar imagens
IMAGE_COUNT=$(ls images/ | wc -l)
echo -e "   Imagens:      $IMAGE_COUNT arquivos"

# Commits
COMMITS=$(git rev-list --count HEAD 2>/dev/null || echo "0")
echo -e "   Commits:      $COMMITS"

echo ""

# Summary
echo "================================================"
echo -e "${BLUE}📊 Resumo${NC}"
echo "================================================"
echo -e "${GREEN}✓ Passou:  $CHECKS_PASSED${NC}"
echo -e "${RED}✗ Falhou:  $CHECKS_FAILED${NC}"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ Setup validado com sucesso!${NC}"
    echo ""
    echo "Próximos passos:"
    echo "1. Configure os secrets no GitHub:"
    echo "   ./SETUP_GITHUB_SECRETS.sh"
    echo ""
    echo "2. Faça o primeiro push:"
    echo "   git push origin main"
    echo ""
    echo "3. Acompanhe o deploy em:"
    echo "   https://github.com/AlexandreLima/cakedabina/actions"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Existem problemas a resolver${NC}"
    echo ""
    echo "Verifique os itens marcados com ✗ acima"
    echo "Consulte DEPLOYMENT.md para mais informações"
    echo ""
    exit 1
fi
