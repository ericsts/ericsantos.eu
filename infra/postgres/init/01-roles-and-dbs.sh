#!/bin/sh
# Roda uma única vez, no primeiro boot do volume infra_pgdata — cria um
# role + database isolado por projeto. Pra adicionar um projeto novo depois
# que o volume já existe, rode manualmente via:
#   docker exec -it infra_postgres psql -U postgres
set -e

create_role_and_db() {
  name="$1"
  password="$2"

  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE ROLE "$name" WITH LOGIN PASSWORD '$password';
    CREATE DATABASE "$name" OWNER "$name";
    REVOKE ALL ON DATABASE "$name" FROM PUBLIC;
    GRANT ALL PRIVILEGES ON DATABASE "$name" TO "$name";
EOSQL
}

create_role_and_db "icarros" "$ICARROS_DB_PASSWORD"
create_role_and_db "banco" "$BANCO_DB_PASSWORD"
create_role_and_db "schedulesyou" "$SCHEDULESYOU_DB_PASSWORD"
