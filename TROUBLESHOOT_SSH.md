# 🔧 Troubleshoot: GitHub Actions SSH → Hostinger VPS

Se o deploy falha com erro de SSH, use este guia para diagnosticar e resolver.

---

## ❌ Erros Comuns

### Erro 1: "Permission denied (publickey)"
```
ssh: connect to host XXX.XXX.XXX.XXX port 22: Connection refused
```
**Causa**: Chave pública não está em `~/.ssh/authorized_keys` na VPS

### Erro 2: "Could not resolve hostname"
```
getaddrinfo: Name or service not known
```
**Causa**: IP/domínio inválido em `VPS_HOST` secret

### Erro 3: "Connection timed out"
```
ssh: connect to host port 22: Operation timed out
```
**Causa**: Firewall bloqueando porta SSH ou VPS desligada

### Erro 4: "sign_and_send_pubkey: signing failed"
```
sign_and_send_pubkey: signing failed: agent refused operation
```
**Causa**: Chave privada malformada ou com espaços extras

---

## ✅ Solução Passo a Passo

### Passo 1: Gerar SSH Key Local (Corretamente)

```bash
# Generate new key (sem passphrase)
ssh-keygen -t ed25519 -C "xandebre@gmail.com" -f ~/.ssh/id_ed25519 -N ""

# Verificar que foi criada
ls -la ~/.ssh/id_ed25519
ls -la ~/.ssh/id_ed25519.pub

# Copiar chave PRIVADA (para GitHub Secret)
cat ~/.ssh/id_ed25519

# Copiar chave PÚBLICA (para VPS)
cat ~/.ssh/id_ed25519.pub
```

**⚠️ IMPORTANTE**: Copie EXATAMENTE como aparece, sem espaços extras no final!

---

### Passo 2: Adicionar Chave Pública à VPS

**Via SSH (mais fácil):**

```bash
# Copie a chave pública primeiro
cat ~/.ssh/id_ed25519.pub

# Depois, SSH na VPS e adicione:
ssh root@SEU_IP_VPS

# Na VPS:
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Cole a chave pública aqui:
echo "COLE_A_CHAVE_PUBLICA_AQUI" >> ~/.ssh/authorized_keys

chmod 600 ~/.ssh/authorized_keys
exit
```

**Teste acesso:**

```bash
ssh -i ~/.ssh/id_ed25519 root@SEU_IP_VPS
# Deve entrar sem pedir password
```

---

### Passo 3: Configurar GitHub Secrets (Corretamente)

**⚠️ CRÍTICO**: Evite erros comuns!

1. Vá para: `https://github.com/AlexandreLima/cakedabina/settings/secrets/actions`

2. Clique "New repository secret"

3. Configure cada secret:

#### Secret 1: `VPS_HOST`
```
Nome: VPS_HOST
Valor: 123.45.67.89
(seu IP real, sem http://, sem spaces)
```

#### Secret 2: `VPS_USER`
```
Nome: VPS_USER
Valor: root
(ou seu usuário, sem spaces)
```

#### Secret 3: `VPS_SSH_PORT`
```
Nome: VPS_SSH_PORT
Valor: 22
(sua porta SSH, sem quotes)
```

#### Secret 4: `VPS_SSH_KEY` (MAIS IMPORTANTE!)
```
Nome: VPS_SSH_KEY
Valor: (COPIE EXATAMENTE:)
```

Para copiar a chave corretamente:

```bash
# Método 1: Copiar para clipboard (macOS)
cat ~/.ssh/id_ed25519 | pbcopy

# Método 2: Copiar para clipboard (Linux com xclip)
cat ~/.ssh/id_ed25519 | xclip -selection clipboard

# Método 3: Ver na tela e copiar manualmente
cat ~/.ssh/id_ed25519
# (selecione tudo, Ctrl+C)
```

**⚠️ CUIDADOS AO COLAR:**
- Não adicione espaços antes ou depois
- Não quebra linhas extras
- Comece com `-----BEGIN OPENSSH PRIVATE KEY-----`
- Termine com `-----END OPENSSH PRIVATE KEY-----`

---

### Passo 4: Testar SSH Manualmente

Antes de fazer push, teste se consegue SSH:

```bash
# Teste 1: Conexão básica
ssh -i ~/.ssh/id_ed25519 -p 22 root@SEU_IP_VPS whoami
# Deve retornar: root

# Teste 2: Comando docker
ssh -i ~/.ssh/id_ed25519 -p 22 root@SEU_IP_VPS docker ps
# Deve listar containers

# Teste 3: Verificar authorized_keys
ssh -i ~/.ssh/id_ed25519 -p 22 root@SEU_IP_VPS "cat ~/.ssh/authorized_keys"
# Deve mostrar sua chave pública
```

Se algum teste falhar, continue no passo 5.

---

### Passo 5: Verificar VPS

```bash
# SSH na VPS
ssh root@SEU_IP_VPS

# Dentro da VPS, execute:

# Check 1: SSH configurado?
ls -la ~/.ssh/authorized_keys

# Check 2: Permissões corretas?
ls -ld ~/.ssh
# Deve ser: drwx------ (700)

# Check 3: Chave está lá?
grep "ssh-ed25519" ~/.ssh/authorized_keys | wc -l
# Deve retornar: 1 (ou mais)

# Check 4: Docker instalado?
docker --version

# Check 5: Docker rodando?
docker ps

# Sair
exit
```

---

### Passo 6: Testar GitHub Actions

```bash
# Localmente, faça um pequeno commit
git add .
git commit -m "Test SSH deployment"
git push origin main

# Vá para: https://github.com/AlexandreLima/cakedabina/actions
# Clique no workflow em execução
# Veja os logs da tarefa "Deploy"

# Se houver erro SSH, será mostrado aqui
```

---

## 🆘 Se Ainda Não Funcionar

### Opção A: Regenerar Tudo (Nuclear)

```bash
# 1. Local: Delete old keys
rm ~/.ssh/id_ed25519*

# 2. Local: Generate new keys
ssh-keygen -t ed25519 -C "xandebre@gmail.com" -f ~/.ssh/id_ed25519 -N ""

# 3. Local: Verify
cat ~/.ssh/id_ed25519.pub

# 4. VPS: Reset authorized_keys
ssh root@SEU_IP_VPS
> rm ~/.ssh/authorized_keys
> touch ~/.ssh/authorized_keys
> chmod 600 ~/.ssh/authorized_keys
> exit

# 5. VPS: Add key
ssh-copy-id -i ~/.ssh/id_ed25519.pub -p 22 root@SEU_IP_VPS

# 6. Test
ssh -i ~/.ssh/id_ed25519 root@SEU_IP_VPS whoami

# 7. GitHub: Update VPS_SSH_KEY secret with new key content
```

### Opção B: Usar GitHub Actions com SSH Agent

Se o método acima não funcionar, use um action específica:

```yaml
# Adicione isso ao workflow antes do SSH
- uses: shimataro/ssh-key-action@v2
  with:
    key: ${{ secrets.VPS_SSH_KEY }}
    known_hosts: ${{ secrets.VPS_KNOWN_HOSTS }}
```

Mas primeiro gere o `known_hosts`:

```bash
ssh-keyscan -p 22 SEU_IP_VPS >> ~/.ssh/known_hosts
cat ~/.ssh/known_hosts
# Crie um novo secret: VPS_KNOWN_HOSTS com este conteúdo
```

---

## 🔐 Checklist de Segurança

- [ ] Chave privada NUNCA foi compartilhada
- [ ] Chave privada está em `~/.ssh/id_ed25519` (permissões 600)
- [ ] Chave pública está em `~/.ssh/authorized_keys` na VPS (permissões 600)
- [ ] Diretório `~/.ssh` tem permissões 700 (drwx------)
- [ ] Testei SSH manualmente: `ssh -i ~/.ssh/id_ed25519 root@VPS whoami`
- [ ] Secrets do GitHub estão corretos (sem espaços extras)

---

## 📞 Precisa de Ajuda?

Se nada funcionar, forneça:

1. Output do teste:
```bash
ssh -i ~/.ssh/id_ed25519 -vvv root@SEU_IP_VPS
```
(com -vvv mostra detalhes do erro)

2. Output do workflow do GitHub Actions

3. Seu IP da VPS (pode mascarar alguns números)

4. Se usa porta SSH customizada
