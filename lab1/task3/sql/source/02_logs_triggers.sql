CREATE OR REPLACE FUNCTION log_changes() RETURNS trigger AS $$
DECLARE
    row_data JSONB;
BEGIN
    IF TG_OP = 'DELETE' THEN
        row_data := to_jsonb(OLD);
    ELSE
        row_data := to_jsonb(NEW);
    END IF;

    INSERT INTO logs (object_type, object_id, operation, payload)
    VALUES (TG_TABLE_NAME, row_data ->> TG_ARGV[0], TG_OP, row_data);

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER category_log
    AFTER INSERT OR UPDATE OR DELETE ON category
    FOR EACH ROW EXECUTE FUNCTION log_changes('category_id');

CREATE TRIGGER dish_log
    AFTER INSERT OR UPDATE OR DELETE ON dish
    FOR EACH ROW EXECUTE FUNCTION log_changes('dish_id');

CREATE TRIGGER client_log
    AFTER INSERT OR UPDATE OR DELETE ON client
    FOR EACH ROW EXECUTE FUNCTION log_changes('client_id');
