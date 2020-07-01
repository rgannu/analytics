#!/bin/bash
set -e

{ echo "host replication services 0.0.0.0/0 trust"; } >> "$PGDATA/pg_hba.conf"
