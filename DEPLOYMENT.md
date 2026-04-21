# 🚀 Guia de Deploy - Cake da Bina

Este documento explica como configurar e executar o deploy automático do projeto Cake da Bina na VPS Hostinger usando GitHub Actions.

## 📋 Pré-requisitos

1. **Conta GitHub** com repositório criado
2. **VPS Hostinger** ativo com Docker instalado
3. **Chave SSH** para acesso à VPS
4. **Domínio** `cakedabina.com.br` apontando para a VPS

---

## 🔑 Configuração de Secrets do GitHub

Os GitHub Actions precisam de credenciais para acessar sua VPS. Configure os seguintes secrets:

### 1. Acesse o repositório GitHub

```
https://github.com/AlexandreLima/cakedabina
```

### 2. Vá para Settings → Secrets and variables → Actions

### 3. Crie os seguintes secrets:

| Nome | Valor | Descrição |
|------|-------|-----------|
| `VPS_HOST` | `seu-ip-ou-dominio-vps` | IP ou domínio da VPS |
| `VPS_USER` | `root` | Usuário SSH (geralmente root) |
| `VPS_SSH_KEY` | `<chave-privada-ssh>` | Conteúdo da sua chave SSH privada |
| `VPS_SSH_PORT` | `22` | Porta SSH (padrão: 22) |

### Como obter a chave SSH:

**No seu computador local:**

```bash
# Se não tiver uma chave SSH, gere uma
ssh-keygen -t ed25519 -C "xandebre@gmail.com"
# Pressione Enter para usar o local padrão
# Pressione Enter para não usar passphrase

# Copie a chave privada
cat ~/.ssh/id_ed25519
```

**Na VPS Hostinger:**

```bash
# Adicione sua chave pública à VPS
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@seu-vps-ip

# Ou manualmente:
ssh root@seu-vps-ip
mkdir -p ~/.ssh
echo "COLAR_SUA_CHAVE_PUBLICA_AQUI" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

---

## 🏗️ Estrutura do Pipeline CI/CD

### `.github/workflows/deploy.yml`

O arquivo de workflow automático faz o seguinte:

1. **Build** - Constrói a imagem Docker quando há push para master/main
2. **Test** - Executa testes básicos (HTML, nginx config)
3. **Deploy** - Faz deploy automático na VPS se o push for para master/main

### Fluxo de Deploy:

```
Push para GitHub
    ↓
GitHub Actions inicia
    ↓
Build - Cria imagem Docker
    ↓
Test - Valida a imagem
    ↓
Deploy (se master/main)
    ├─ SSH para VPS
    ├─ Git pull do repositório
    ├─ Docker pull da imagem
    ├─ docker-compose up -d
    └─ Verifica saúde do container
    ↓
✅ Website atualizado em produção
```

---

## 🐳 Dockerfile e Build

### `Dockerfile`

- **Multi-stage build** para otimizar tamanho final
- **nginx:alpine** como imagem base (apenas 42MB)
- **Healthcheck** configurado
- **Permissions** ajustadas para segurança
- **Labels** adicionadas para metadata

### Build local (para testes):

```bash
docker build -t cakedabina:test .

docker run -p 8080:80 cakedabina:test

# Acesse: http://localhost:8080
```

---

## 📦 Docker Compose em Produção

### `docker-compose.prod.yml`

```bash
# Iniciar
docker-compose -f docker-compose.prod.yml up -d

# Parar
docker-compose -f docker-compose.prod.yml down

# Ver logs
docker-compose -f docker-compose.prod.yml logs -f

# Ver status
docker-compose -f docker-compose.prod.yml ps
```

---

## 🚀 Deploy Automático (Recomendado)

Após fazer as configurações acima, todo push para `master` ou `main` acionará o deploy automático:

```bash
# Localmente
git add .
git commit -m "Atualizar website"
git push origin main

# No GitHub Actions:
# ✅ Build → Test → Deploy → ✅ Website atualizado
```

**Tempo**: ~2-3 minutos

---

## 🔧 Deploy Manual (Se necessário)

Se o GitHub Actions falhar, deploy manualmente:

### Via SSH direto:

```bash
# 1. Acesse a VPS
ssh root@seu-vps-ip

# 2. Entre no diretório de deployment
cd /home/site-cakedabina

# 3. Atualize o código
git pull origin main

# 4. Reinicie o container
docker-compose -f docker-compose.prod.yml up -d

# 5. Verifique logs
docker-compose -f docker-compose.prod.yml logs -f
```

### Via script local:

```bash
# Use o GO_LIVE.sh (se ainda existir)
./GO_LIVE.sh
```

---

## 📊 Monitoramento

### Ver status dos containers:

```bash
ssh root@seu-vps-ip
docker ps
docker stats
```

### Ver logs em tempo real:

```bash
ssh root@seu-vps-ip
docker-compose -f /home/site-cakedabina/docker-compose.prod.yml logs -f
```

### Verificar saúde do website:

```bash
curl -v https://cakedabina.com.br/
curl -v https://cakedabina.com.br/health
```

---

## 🔐 Segurança

- ✅ Chave SSH privada protegida em GitHub Secrets
- ✅ SSH port padrão (23) pode ser alterado
- ✅ Container roda sem privilégios de root (nginx user)
- ✅ Volumes com permissões read-only onde possível
- ✅ Healthcheck valida container continuamente

---

## 🆘 Troubleshooting

### Pipeline falha no build

```bash
# Verifique erros de sintaxe YAML
github.com/your-repo/actions

# Revise o arquivo deploy.yml
```

### Container não inicia

```bash
ssh root@seu-vps-ip
docker logs cakedabina-web

# Verifique:
docker-compose -f docker-compose.prod.yml config
```

### Website retorna 404

```bash
# Verifique se arquivos estão no lugar certo
ssh root@seu-vps-ip
ls -la /usr/share/nginx/html/

# Reinicie
docker-compose -f docker-compose.prod.yml restart
```

### GitHub Actions não consegue conectar à VPS

- Verifique IP/hostname em `VPS_HOST`
- Verifique porta SSH em `VPS_SSH_PORT`
- Teste conexão manualmente:
  ```bash
  ssh -i ~/.ssh/id_ed25519 root@seu-vps-ip
  ```
- Verifique firewall da VPS:
  ```bash
  ssh root@seu-vps-ip
  ufw status
  ufw allow 22/tcp
  ```

---

## 📝 Próximos Passos

1. ✅ Configurar secrets do GitHub
2. ✅ Fazer push do repositório
3. ✅ Acompanhar primeira execução do workflow
4. ✅ Testar website em https://cakedabina.com.br
5. ✅ Fazer pequenas alterações e verificar auto-deploy

---

## 📚 Referências

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/docs/)
- [Hostinger VPS Docs](https://www.hostinger.com/help/article/how-to-ssh-to-your-vps)

---

**Dúvidas?** Entre em contato: xandebre@gmail.com
