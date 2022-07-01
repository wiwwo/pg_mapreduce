#!/bin/bash

echo "local all all md5" > "$PGDATA/pg_hba.conf"
echo "host replication all 0.0.0.0/0 trust" >> "$PGDATA/pg_hba.conf"
echo "host all all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
CREATE USER $PG_REP_USER REPLICATION LOGIN CONNECTION LIMIT 100 ENCRYPTED PASSWORD '$PG_REP_PASSWORD';
CREATE USER postgres;
EOSQL
cat >> ${PGDATA}/postgresql.conf <<EOF
wal_level = replica
max_wal_senders = 10
wal_keep_size = '1GB'
wal_compression = on
EOF

echo "logging_collector=on" >> $PGDATA/postgresql.conf
echo "log_destination='stderr'" >> $PGDATA/postgresql.conf


echo pg_red > /opt/pg_cluster/0EVERYBODYS_master_is
echo pg_red > /opt/pg_cluster/pg_red_master_is
