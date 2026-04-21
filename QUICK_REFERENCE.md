# 🚀 Quick Reference - Cake da Bina CI/CD

## Estrutura de Arquivos

```
Cake da Bina/
├── .github/
│   └── workflows/
│       └── deploy.yml              # Pipeline CI/CD automático
├── Dockerfile                      # Build da imagem Docker
├── docker-compose.yml              # Dev (original)
├── docker-compose.prod.yml         # Prod (novo)
├── .dockerignore                   # Otimização de build
├── DEPLOYMENT.md                   # Documentação completa
├── SETUP_GITHUB_SECRETS.sh         # Script de setup
├── QUICK_REFERENCE.md              # Este arquivo
├── index.html                      # Website
├── styles.css
├── script.js
├── nginx.conf
├── images/
├── assets/
└── ... (outros arquivos)
```

---

## 🔑 Secrets GitHub (obrigatório)

Vá para: **Settings → Secrets and variables → Actions**

```
VPS_HOST          = seu-ip-vps
VPS_USER          = root
VPS_SSH_PORT      = 22
VPS_SSH_KEY       = conteúdo-da-chave-privada
```

---

## 📋 Comandos Comuns

### Gerar SSH Key
```bash
ssh-keygen -t ed25519 -C "xandebre@gmail.com"
```

### Ver chave privada (para GitHub Secret)
```bash
cat ~/.ssh/id_ed25519
```

### Ver chave pública (para VPS)
```bash
cat ~/.ssh/id_ed25519.pub
```

### Adicionar chave à VPS
```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@seu-vps-ip
```

### Testar conexão SSH
```bash
ssh -i ~/.ssh/id_ed25519 root@seu-vps-ip
```

---

## 🐳 Docker - Local

### Build local
```bash
docker build -t cakedabina:test .
```

### Rodar localmente
```bash
docker run -p 8080:80 cakedabina:test
# Acesse: http://localhost:8080
```

### Teste de health check
```bash
curl http://localhost:8080/health
```

---

## 📦 Docker Compose - Produção

### Iniciar
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Parar
```bash
docker-compose -f docker-compose.prod.yml down
```

### Ver logs
```bash
docker-compose -f docker-compose.prod.yml logs -f
```

### Reiniciar
```bash
docker-compose -f docker-compose.prod.yml restart
```

### Status
```bash
docker-compose -f docker-compose.prod.yml ps
```

---

## 📤 Deploy Automático (Recomendado)

Basta fazer push para `master` ou `main`:

```bash
git add .
git commit -m "Update: descrição da mudança"
git push origin main
```

O GitHub Actions fará automaticamente:
1. ✅ Build da imagem Docker
2. ✅ Testes básicos
3. ✅ Deploy na VPS
4. ✅ Validação de saúde

**Tempo**: ~2-3 minutos

---

## 🔧 Deploy Manual (Se necessário)

### Via SSH
```bash
ssh root@seu-vps-ip
cd /home/site-cakedabina
git pull origin main
docker-compose -f docker-compose.prod.yml up -d
docker-compose -f docker-compose.prod.yml logs -f
```

### Verificar website
```bash
curl https://cakedabina.com.br/
```

---

## 📊 Monitorar

### Ver containers
```bash
docker ps
```

### Ver uso de recursos
```bash
docker stats
```

### Ver logs em tempo real
```bash
docker-compose -f docker-compose.prod.yml logs -f
```

### Health check
```bash
curl https://cakedabina.com.br/health
```

---

## 🔍 Troubleshooting

### GitHub Actions falhando?
1. Verifique **Settings → Secrets** - todos os 4 secrets presentes?
2. Verifique IP/porta SSH da VPS
3. Teste SSH manualmente: `ssh -i ~/.ssh/id_ed25519 root@seu-vps-ip`

### Container não inicia?
```bash
docker logs cakedabina-web
docker-compose -f docker-compose.prod.yml config  # Valida YAML
```

### Website 404?
```bash
docker exec cakedabina-web ls -la /usr/share/nginx/html/
curl http://localhost/health
```

### Permissões negadas?
```bash
ssh root@seu-vps-ip
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

---

## 📝 Checklist de Setup

- [ ] SSH key gerada (`~/.ssh/id_ed25519`)
- [ ] Chave pública adicionada à VPS
- [ ] VPS_HOST configurado em GitHub Secrets
- [ ] VPS_USER configurado em GitHub Secrets
- [ ] VPS_SSH_PORT configurado em GitHub Secrets
- [ ] VPS_SSH_KEY configurado em GitHub Secrets
- [ ] Primeiro push feito (`git push origin main`)
- [ ] GitHub Actions executou com sucesso
- [ ] Website acessível em https://cakedabina.com.br
- [ ] Health check respondendo

---

## 🚨 Emergência

### Resetar tudo
```bash
# Na VPS
docker-compose -f docker-compose.prod.yml down
docker system prune -a -f

# No local
rm -rf .git
git init
git add .
git commit -m "Initial commit"
git push -u origin main
```

### Ver o que mudou
```bash
git diff
git status
```

### Desfazer último commit
```bash
git reset --soft HEAD~1
```

### Forçar push (⚠️ cuidado!)
```bash
git push -f origin main
```

---

## 📞 Suporte

- **Email**: xandebre@gmail.com
- **Documentação**: DEPLOYMENT.md
- **GitHub**: https://github.com/AlexandreLima/cakedabina

---

**Última atualização**: 2026-04-21
