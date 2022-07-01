#!/bin/bash
NEW_MASTER=${1:-pg_red}

if [[ "$HOSTNAME" == "$NEW_MASTER" ]]; then
  echo "Master is me: $HOSTNAME == $NEW_MASTER"
  exit
fi

until (pg_isready -h${NEW_MASTER} -Upostgres >/dev/null 2>&1)
do
  echo "Waiting for master ${NEW_MASTER} to be ready..."
  sleep 1s
done

rm -rf ${PGDATA} 2>/dev/null
rm -rf ${PGDATA}/postgresql.auto.conf

echo Executing: pg_basebackup
until (pg_basebackup -h ${NEW_MASTER} -D ${PGDATA} -U ${PG_REP_USER} -vP -R -Xs)
do
  echo "Waiting for master to connect..."
  sleep 5s
done
echo "local all all md5" > "$PGDATA/pg_hba.conf"
echo "host replication all 0.0.0.0/0 trust" >> "$PGDATA/pg_hba.conf"
echo "host all all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
set -e

chown postgres. ${PGDATA} -R
chmod 700 ${PGDATA} -R

echo $NEW_MASTER > /opt/pg_cluster/$HOSTNAME\_master_is

#while pg_isready -Upostgres >/dev/null 2>&1; do sleep 3;done
