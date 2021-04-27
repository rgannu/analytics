
--
-- Create `postgis_table` table
--
CREATE TABLE skybridge.postgis_table (id SERIAL, rev SERIAL, stringColumn varchar(255), p GEOMETRY(POINT,3187), ml GEOGRAPHY(MULTILINESTRING), PRIMARY KEY(id, rev));

INSERT INTO postgis_table(stringColumn, p, ml) values
('new table', 'SRID=3187;POINT(174.9479 -36.7208)'::geometry, 'MULTILINESTRING((169.1321 -44.7032, 167.8974 -44.6414))'::geography);

GRANT SELECT,INSERT,DELETE,UPDATE ON ALL TABLES IN SCHEMA skybridge TO analytics;
GRANT USAGE ON SCHEMA skybridge TO analytics;
