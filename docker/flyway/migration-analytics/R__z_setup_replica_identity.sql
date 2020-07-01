-- REPLICA IDENTITY is a PostgreSQL specific table-level setting which determines the amount
--   of information that is available to logical decoding in case of UPDATE and DELETE events.
-- FULL - UPDATE and DELETE events will contain the previous values of all the table’s columns.
--   This is needed so that tables with no PK/toast columns are updated with previous values
--   during the processing of the UPDATE WAL message.
CREATE OR REPLACE FUNCTION add_replica_identity_full() RETURNS VOID AS $$
DECLARE
    rec record;
BEGIN
  FOR rec IN
    select table_name from information_schema.tables where table_schema = current_schema()
      and table_type = 'BASE TABLE'
  LOOP
    EXECUTE format('ALTER TABLE %I REPLICA IDENTITY FULL', rec.table_name);
  END LOOP;
END
$$ LANGUAGE plpgsql;

select add_replica_identity_full();
