
CREATE USER services WITH PASSWORD 'services';
CREATE DATABASE services OWNER services;
\connect services
CREATE SCHEMA services AUTHORIZATION services;

CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
CREATE EXTENSION postgis_sfcgal;
CREATE EXTENSION btree_gist;
CREATE EXTENSION pg_trgm schema public;
CREATE EXTENSION "uuid-ossp";
CREATE LANGUAGE plpython3u;
UPDATE pg_language SET lanpltrusted = true WHERE lanname = 'plpython3u';

-- Roles needed for replication
ALTER USER services WITH REPLICATION;
ALTER USER services WITH LOGIN;

-- Analytics DB
CREATE USER analytics WITH PASSWORD 'analytics';
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
