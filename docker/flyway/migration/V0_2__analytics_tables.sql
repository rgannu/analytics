--
-- Create `test_table` table
--
CREATE TABLE test_table(id SERIAL, uuid varchar(255) NOT NULL UNIQUE, VERSION INTEGER NOT NULL, PRIMARY KEY(id));
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE test_table TO services;
GRANT USAGE, SELECT ON SEQUENCE test_table_id_seq TO services;

INSERT INTO test_table(uuid, version) VALUES(uuid_generate_v4(), 0);
--
-- Create `postgis_table` table
--
CREATE TABLE postgis_table (id SERIAL, p GEOMETRY(POINT,3187), ml GEOGRAPHY(MULTILINESTRING), PRIMARY KEY(id));
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE postgis_table TO services;
GRANT USAGE, SELECT ON SEQUENCE postgis_table_id_seq TO services;

INSERT INTO postgis_table(p, ml) values
('SRID=3187;POINT(174.9479 -36.7208)'::geometry, 'MULTILINESTRING((169.1321 -44.7032, 167.8974 -44.6414))'::geography);
