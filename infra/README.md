# Infraestrutura compartilhada — infra/

Postgres, Redis e RabbitMQ únicos para todos os subprojetos do droplet, com
usuário/database/vhost isolado por projeto. Substitui os containers de
banco/fila/cache que cada projeto (go-icarros, py_banco, schedulesyou) subia
por conta própria — 3 Postgres inteiros rodando ao mesmo tempo num droplet
de 1GB era o motivo mais provável da pressão de memória.

`go-battleship` e `go-pokercards` não usam banco — não são afetados por
nada disso.

## Antes de começar

Todos os dados atuais nos bancos de cada projeto são de teste e serão
destruídos nesta migração (decisão consciente — sem necessidade de backup).
Se isso mudar no futuro, faça `pg_dump` de cada banco antigo antes do
passo 5.

## 0. Swapfile (rede de segurança — faça isso primeiro)

Um droplet de 1GB é extremamente apertado. Um swapfile não substitui RAM,
mas evita que o kernel mate processos (OOM killer) enquanto o resto da
migração acontece.

```bash
free -h
swapon --show
```

Se não aparecer nenhum swap:

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
free -h   # confirma
```

## 1. Rede docker compartilhada

Criada uma vez só — todos os projetos vão referenciar pelo nome:

```bash
docker network create infra_shared
```

## 2. Atualizar o checkout do ericsantos.eu

```bash
cd /opt/ericsantos.eu
git pull origin main
```

## 3. Configurar senhas

```bash
cd /opt/ericsantos.eu/infra
cp .env.example .env
nano .env
```

Gere cada senha com `openssl rand -hex 20` e cole no `.env`. **Nunca
reaproveite senha entre projetos.** Guarde essas senhas em algum lugar (gestor
de senhas) — você vai colar de novo nos `.env` de cada projeto no passo 5.

## 4. Subir a stack compartilhada

```bash
docker compose -f docker-compose.yml up -d
docker compose -f docker-compose.yml ps
```

Verificação:

```bash
# Postgres — deve listar icarros, banco e schedulesyou
docker exec -it infra_postgres psql -U postgres -c '\l'

# Redis
docker exec -it infra_redis redis-cli -a "SENHA_DO_REDIS_PASSWORD" ping

# RabbitMQ
docker exec -it infra_rabbitmq rabbitmq-diagnostics -q ping
```

## 5. Cutover dos projetos (um de cada vez, nessa ordem)

Ordem escolhida por risco: **py_banco** (mais simples) → **schedulesyou**
(tem Redis) → **go-icarros** (schema customizado + RabbitMQ) por último.

Depois de cada projeto, **confirme que a aplicação funciona de verdade**
(login, algum fluxo real) antes de seguir pro próximo — cutover é
sequencial, não em paralelo, justamente pra isolar qualquer problema a um
projeto por vez.

### 5.1 py_banco

```bash
cd /opt/py_banco
git pull origin main
nano .env
```

No `.env`, `POSTGRES_USER`/`POSTGRES_DB` já devem ser `banco`/`banco`
(default do `.env.example`) — só troque `POSTGRES_PASSWORD` pro mesmo valor
de `BANCO_DB_PASSWORD` que você definiu no `infra/.env`.

```bash
docker compose -f docker-compose.prod.yml down -v   # derruba o Postgres antigo dele (dados de teste)
docker compose -f docker-compose.prod.yml up -d --build
docker compose -f docker-compose.prod.yml logs -f backend   # confirma migrations + admin bootstrap
```

Abra `https://banco.ericsantos.eu` e confirme o login.

### 5.2 schedulesyou

```bash
cd /opt/schedulesyou
git pull origin main
nano .env   # (ou o env_file real usado em produção no servidor)
```

Ajuste:
- `DB_HOST=infra_postgres`
- `DB_USERNAME=schedulesyou`
- `DB_PASSWORD=` mesmo valor de `SCHEDULESYOU_DB_PASSWORD` no `infra/.env`
- `REDIS_HOST=infra_redis`
- `REDIS_PASSWORD=` mesmo valor de `REDIS_PASSWORD` no `infra/.env`

```bash
docker compose -f docker-compose.prod.yml down -v
docker compose -f docker-compose.prod.yml up -d --build
docker compose -f docker-compose.prod.yml exec -T app php artisan migrate --force
```

Confirme login de algum tenant.

### 5.3 go-icarros

O database `icarros` já foi criado com o schema (o passo 4 já rodou o
equivalente ao `init.sql` antigo) — não precisa rodar nada de schema
manualmente.

```bash
cd /opt/go-icarros
git pull origin main
nano .env
```

Ajuste:
- `DB_HOST=infra_postgres`
- `DB_USER=icarros`
- `DB_PASSWORD=` mesmo valor de `ICARROS_DB_PASSWORD` no `infra/.env`
- `DB_NAME=icarros`
- `RABBITMQ_URL=amqp://icarros:SENHA_DO_RABBITMQ_ICARROS_PASSWORD@infra_rabbitmq:5672/icarros`

```bash
docker compose -f docker-compose.prod.yml down -v
docker compose -f docker-compose.prod.yml up -d --build
docker compose -f docker-compose.prod.yml logs -f app
```

Confirme que dá pra criar um leilão e que o WebSocket de lances funciona.

## 6. Limpeza

```bash
docker system prune -f
docker volume ls   # confirma que só sobraram os volumes infra_* + uploads do py_banco
free -h            # compara com o baseline do passo 0
```

## Nginx — banco.ericsantos.eu e schedulesyou.com

As confs ficam em `../nginx/banco.ericsantos.eu.conf` e
`../nginx/schedulesyou.com.conf`, aplicação manual (mesmo padrão dos outros
subdomínios — veja o README da raiz do repo):

```bash
sudo cp /opt/ericsantos.eu/nginx/banco.ericsantos.eu.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/banco.ericsantos.eu.conf /etc/nginx/sites-enabled/
sudo certbot --nginx -d banco.ericsantos.eu
sudo nginx -t && sudo systemctl reload nginx
```

`schedulesyou.com` precisa de certificado **wildcard**
(`*.schedulesyou.com`, por causa dos subdomínios dinâmicos por tenant), o
que exige validação DNS-01 — `certbot --nginx` sozinho não serve pra isso.
Veja o comentário no topo de `../nginx/schedulesyou.com.conf` pra mais
detalhes; isso fica como próximo passo separado, não bloqueia o resto desta
migração.

## Adicionando um projeto novo no futuro

1. Adicione o role+database em `postgres/init/01-roles-and-dbs.sh` (só roda
   no primeiro boot do volume — se o volume já existe, rode o `CREATE
   ROLE`/`CREATE DATABASE` manualmente via `docker exec -it infra_postgres
   psql -U postgres`, seguindo o mesmo padrão de REVOKE/GRANT).
2. No `docker-compose.prod.yml` do projeto novo, junte o serviço que
   precisa do banco na rede `infra_shared` (declarada `external: true`).
3. Aponte a connection string / `DB_HOST` pro host `infra_postgres`
   (ou `infra_redis` / `infra_rabbitmq`, conforme o caso).
