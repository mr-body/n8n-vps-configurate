# n8n-vps-configurate

Configuração pronta para subir o **n8n** em uma **VPS Linux** usando **Docker + Docker Compose**, com **Nginx** como reverse proxy e **TLS/SSL (Let’s Encrypt / Certbot)**.

> Estado atual do repo (24/04/2026): a stack está definida em `docker-compose.yml` com serviços `n8n`, `nginx` e `certbot`.

## O que vem neste repositório

- `docker-compose.yml`: sobe o n8n e o Nginx; inclui um container de `certbot` para renovar certificados.
- `nginx/nginx.conf`: configuração do reverse proxy (HTTP → HTTPS e proxy para o n8n).
- `Makefile`: atalhos para subir/parar stack e para gerar/renovar certificados.

## Pré-requisitos

- VPS com Linux (Ubuntu/Debian recomendado)
- Docker e Docker Compose instalados
- Um domínio apontado para o IP da VPS (registro **A/AAAA**)
- Portas liberadas no firewall/security group:
  - 80/tcp (HTTP)
  - 443/tcp (HTTPS)

## Configuração (passo a passo)

### 1) Clone o projeto

```bash
git clone https://github.com/mr-body/n8n-vps-configurate.git
cd n8n-vps-configurate
```

### 2) Ajuste o domínio (Nginx + n8n)

Este repositório vem com placeholders (`seudomain.com`, `seudomain`, etc). Você precisa trocar para o seu domínio.

**Edite `nginx/nginx.conf`** e substitua:

- `server_name seudomain.com;` → `server_name SEU_DOMINIO;`

**Edite `docker-compose.yml`** e ajuste as variáveis:

- `N8N_HOST` (ex.: `n8n.seudominio.com`)
- `WEBHOOK_URL` (ex.: `https://n8n.seudominio.com/`)
- `TZ` (timezone)

> Dica: Se você usar subdomínio (recomendado), use algo como `n8n.seudominio.com` em `N8N_HOST`/`WEBHOOK_URL` e também no `server_name` do Nginx.

### 3) Certificado SSL (Let’s Encrypt)

Há duas abordagens possíveis:

#### Opção A) Gerar certificado via Makefile (certbot standalone)

No `Makefile`, defina:

- `DOMAIN=seudomain` → seu domínio (ex.: `n8n.seudominio.com`)
- `EMAIL=seuemail@exemplo.com` → seu email

Depois rode:

```bash
make certbot
```

Isso executa o `certbot` e copia os `.pem` para a pasta `./cert/`.

#### Opção B) Usar certbot do próprio compose (renovação)

O `docker-compose.yml` tem um serviço `certbot` configurado para renovar e copiar certificados para `./cert/`.

**Importante:** a primeira emissão do certificado normalmente é mais simples via **Opção A** (standalone). Depois disso, a renovação pode ficar automatizada.

## Subir a stack

```bash
make up
```

Verifique os containers:

```bash
make ps
```

Logs:

```bash
make logs
```

Parar/remover (mantendo dados se não usar `-v`):

```bash
make down
```

Limpar tudo (inclusive volumes):

```bash
make clean
```

## Acessando o n8n

- Se você publicou via domínio/HTTPS, acesse: `https://SEU_DOMINIO/`
- No compose atual, o n8n também expõe a porta `4040:5678` (acesso direto): `http://IP_DA_VPS:4040`

> Recomenda-se usar apenas o acesso via Nginx/HTTPS em produção.

## Persistência de dados

Os dados do n8n ficam persistidos em:

- `./n8n_data` → mapeado para `/home/node/.n8n` dentro do container.

Faça backup dessa pasta.

## Segurança (recomendações)

- Troque o acesso direto por porta (remova `4040:5678` do compose) quando estiver pronto para produção.
- Use firewall (UFW/iptables) liberando apenas 80 e 443.
- Considere adicionar autenticação extra (Basic Auth no Nginx, VPN, allowlist de IP, etc.) dependendo do seu caso.

## Troubleshooting

- **HTTPS não sobe / certificado inválido**: confirme se os arquivos existem em `./cert/fullchain.pem` e `./cert/privkey.pem` e se o `server_name` bate com o domínio do certificado.
- **Webhook não funciona**: confirme `WEBHOOK_URL` com `https://SEU_DOMINIO/` (incluindo barra final, como no compose).
- **Permissão em `n8n_data`**: o container está usando `user: "1000:1000"`. Garanta que a pasta `./n8n_data` pertença ao UID/GID 1000 no host.

## Licença

Ainda não definida.
