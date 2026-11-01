#!/bin/bash
# Respaldo periódico de Postgres y storage/. Corre dentro del servicio `backup` de docker-compose.
set -uo pipefail

BACKUP_DIR=/backups
KEEP_DAYS=${BACKUP_KEEP_DAYS:-14}
INTERVAL=${BACKUP_INTERVAL_SECONDS:-86400}

backup_once() {
  local ts db_file storage_file
  ts=$(date +%F_%H%M)
  db_file="$BACKUP_DIR/db-$ts.sql.gz"
  storage_file="$BACKUP_DIR/storage-$ts.tgz"

  if pg_dump -h postgres -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$db_file.part" && gzip -t "$db_file.part"; then
    mv "$db_file.part" "$db_file"
    echo "[backup] OK $db_file ($(du -h "$db_file" | cut -f1))"
  else
    rm -f "$db_file.part"
    echo "[backup] ERROR: fallo el respaldo de la base de datos" >&2
    return 1
  fi

  if tar czf "$storage_file.part" -C /storage . && mv "$storage_file.part" "$storage_file"; then
    echo "[backup] OK $storage_file ($(du -h "$storage_file" | cut -f1))"
  else
    rm -f "$storage_file.part"
    echo "[backup] ERROR: fallo el respaldo de storage" >&2
    return 1
  fi

  find "$BACKUP_DIR" -maxdepth 1 -type f \( -name 'db-*' -o -name 'storage-*' \) -mtime +"$KEEP_DAYS" -delete
}

while true; do
  backup_once
  sleep "$INTERVAL"
done
