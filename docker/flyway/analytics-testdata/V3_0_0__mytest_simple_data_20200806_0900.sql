--
-- Create `test_table` table
--
CREATE TABLE skybridge.test_table(id SERIAL PRIMARY KEY, uuid varchar(255) NOT NULL UNIQUE, VERSION INTEGER NOT NULL);

INSERT INTO test_table(uuid, version) VALUES(uuid_generate_v4(), 0);

GRANT SELECT,INSERT,DELETE,UPDATE ON ALL TABLES IN SCHEMA skybridge TO analytics;
GRANT USAGE ON SCHEMA skybridge TO analytics;
