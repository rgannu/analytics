--
-- Create `schema_version` table
--
CREATE TABLE skybridge.schema_version(installed_rank SERIAL PRIMARY KEY, version VARCHAR(50), installed_on timestamp without time zone default now());

INSERT INTO schema_version(version) VALUES('3.0.0.x');

GRANT SELECT,INSERT,DELETE,UPDATE ON ALL TABLES IN SCHEMA skybridge TO analytics;
GRANT USAGE ON SCHEMA skybridge TO analytics;
