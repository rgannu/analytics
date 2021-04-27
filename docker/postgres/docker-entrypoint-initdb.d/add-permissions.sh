#!/bin/bash
set -e

{ echo "local replication analytics    trust"; } >> "${PGDATA}/pg_hba.conf"
{ echo "host replication analytics 172.22.0.1/16 trust"; } >> "${PGDATA}/pg_hba.conf"
{ echo "host replication analytics 172.22.0.1/16 md5"; } >> "${PGDATA}/pg_hba.conf"
{ echo "host replication all all md5"; } >> "${PGDATA}/pg_hba.conf"
{ echo "host replication all ::1/128 trust"; } >> "${PGDATA}/pg_hba.conf"
