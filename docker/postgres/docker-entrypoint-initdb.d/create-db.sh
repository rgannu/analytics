#!/bin/bash

PGPASSWORD=postgres
psql -U postgres <<EOSQL
    CREATE USER ${DB_NAME} WITH PASSWORD 'skybridge';
    CREATE DATABASE ${DB_NAME} OWNER ${DB_NAME};
    \connect ${DB_NAME}
    CREATE SCHEMA ${DB_NAME} AUTHORIZATION ${DB_NAME};

    CREATE EXTENSION postgis;
    CREATE EXTENSION postgis_topology;
    CREATE EXTENSION postgis_sfcgal;
    CREATE EXTENSION btree_gist;
    CREATE EXTENSION pg_trgm schema public;
    CREATE EXTENSION "uuid-ossp";
    CREATE LANGUAGE plpython3u;
    UPDATE pg_language SET lanpltrusted = true WHERE lanname = 'plpython3u';

    -- Roles needed for replication
    CREATE ROLE analytics REPLICATION LOGIN;
    ALTER USER analytics WITH PASSWORD 'analytics';

    -- ALTER analytics role add the search path
    ALTER ROLE analytics SET SEARCH_PATH TO ${DB_NAME}, public;

    -- GRANT privileges to analytics user
    GRANT CONNECT ON DATABASE ${DB_NAME} TO analytics;

    -- Analytics DB
    CREATE DATABASE analytics OWNER analytics;
    \connect analytics
    CREATE SCHEMA analytics AUTHORIZATION analytics;

    CREATE EXTENSION postgis;
    CREATE EXTENSION postgis_topology;
    CREATE EXTENSION postgis_sfcgal;
    CREATE EXTENSION btree_gist;
    CREATE EXTENSION pg_trgm schema public;
    CREATE EXTENSION "uuid-ossp";
    CREATE LANGUAGE plpython3u;
    UPDATE pg_language SET lanpltrusted = true WHERE lanname = 'plpython3u';
EOSQL
